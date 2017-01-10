require 'fzeet'

include Fzeet

Dialog.new(nil, modal: true, style: [:overlappedwindow, :center]) { |args|
	dialog = Application.window = args[:window]

	dialog.menu = Menu.new.
		append(:popup, 'Menu&1', PopupMenu.new.
			append(:string, 'Item&1', :item1).

			append(:separator).

			append(:string, 'E&xit', :exit)
		)

	Button.new(dialog, :button1, caption: '&Button1', position: [10, 10, 76, 24])

	dialog.
		on(:command, :exit) { dialog.end(:ok) }.
		on(:command, :cancel) { dialog.end(:cancel) if question('Close?').yes? }.

		on(:command, :item1) { message 'on(:command, :item1)' }.
		on(:command, :button1) { message 'on(:command, :button1)' }
}
