require 'fzeet'

include Fzeet

Application.run(Frame.new) { |window|
	window.menu.
		append(:popup, '&File', PopupMenu.new.
			append(:string, "&New\tCtrl+N", :new).
			append(:string, "&Open...\tCtrl+O", :open).
			append(:string, "&Save\tCtrl+S", :save).
			append(:string, "Save &As...\tCtrl+Shift+S", :saveAs)
		)

	Application.accelerators << AcceleratorTable.new(
		[:control, :n, :new],
		[:control, :o, :open],
		[:control, :s, :save],
		[[:control, :shift], :s, :saveAs]
	)

	window.
		on(:command, :new) {
			child = MDIChild.new(window.client, caption: 'Untitled')

			Scintilla.new(child, :sci, style: :border, position: child.rect.to_a, anchor: :ltrb)

			child[:sci].focus = true

			child[:sci].font = 'Courier New'
			child[:sci].fontSize = 10

			child[:sci].tabWidth = 2

			child.on(:close) { |args|
				if args[:sender][:sci].dirty?
					answer = args[:sender].question(%Q{
File not saved:
  #{args[:sender].text}

Press Yes to save it and close the window
Press No to close the window without saving
Press Cancel to leave the window open
					}, buttons: [:yes, :no, :Cancel], icon: :warning)

					window.sendmsg(:command, Command[:save]) if answer.yes?

					args[:result] = nil unless answer.cancel?
				else
					args[:result] = nil
				end
			}
		}.

		on(:command, :open) {
			((Windows::Version >= :vista) ? ShellFileOpenDialog : FileOpenDialog).new { |dialog|
				dialog.multiselect = true

				next unless dialog.show.ok?

				dialog.paths.each { |path|
					window.sendmsg(:command, Command[:new])

					child = window.activeChild

					child.text, child[:sci].text = path, File.read(path)

					child[:sci].toggle(:dirty).sendmsg(:emptyundobuffer)
				}
			}
		}.

		on(:command, :saveAs) {
			((Windows::Version >= :vista) ? ShellFileSaveDialog : FileSaveDialog).new { |dialog|
				next unless dialog.show.ok?

				child = window.activeChild

				File.open(child.text = dialog.path, 'w') { |f| f << child[:sci].text; child[:sci].dirty = false }
			}
		}.

		on(:command, :save) {
			child = window.activeChild

			(child.text == 'Untitled') ?
				window.sendmsg(:command, Command[:saveAs]) :
				File.open(child.text, 'w') { |f| f << child[:sci].text; child[:sci].dirty = false }
		}.

		on(:command, :saveAll) {
			window.client.eachChild { |child|
				next unless child.kind_of?(MDIChild)

				window.
					activate(child).
					sendmsg(:command, Command[:save])
			}
		}.

		on(:initmenupopup) {
			child = window.activeChild

			[:save, :saveAs].each { |command| window.menu[command].enabled = !child.nil? }
		}.

		on(:close) {
			dirties = []

			window.client.eachChild { |child|
				next unless child.kind_of?(MDIChild)

				dirties << child if child[:sci].dirty?
			}

			if dirties.length > 0
				answer = window.question(%Q{
File#{(dirties.length > 1) ? 's' : ''} not saved:
  #{dirties.map(&:text).join("\n  ")}

Press Yes to save #{(dirties.length > 1) ? 'them' : 'it'} and close the application
Press No to close the application without saving
Press Cancel to leave the application open
				}, buttons: [:yes, :no, :Cancel], icon: :warning)

				window.sendmsg(:command, Command[:saveAll]) if answer.yes?

				window.dispose unless answer.cancel?
			else
				window.dispose
			end
		}
}
