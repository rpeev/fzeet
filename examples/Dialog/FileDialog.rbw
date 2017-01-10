require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&File', PopupMenu.new.
			append(:string, '&Open...', :open).
			append(:string, 'Open &Multiple...', :openMultiple).
			append(:string, 'Save &As...', :saveAs).

			append(:separator).

			append(:string, 'Browse For &Folder...', :browseForFolder)
		)

	window.
		on(:command, :open) {
			FileOpenDialog.new { |dialog|
				dialog.on(:initdialog) { message 'on(:initdialog)' }

				message dialog.path if dialog.show.ok?
			}
		}.

		on(:command, :openMultiple) {
			FileOpenDialog.new { |dialog|
				dialog.multiselect = true

				message dialog.paths.join("\n") if dialog.show.ok?
			}
		}.

		on(:command, :saveAs) {
			FileSaveDialog.new { |dialog|
				dialog.on(:initdialog) { message 'on(:initdialog)' }

				message dialog.path if dialog.show.ok?
			}
		}.

		on(:command, :browseForFolder) {
			dialog = FolderDialog.new

			dialog.on(Windows::BFFM_IUNKNOWN) { message 'Windows::BFFM_IUNKNOWN' }

			message dialog.path if dialog.show.ok?
		}
}
