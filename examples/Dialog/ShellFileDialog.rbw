require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&File', PopupMenu.new.
			append(:string, '&Open...', :open).
			append(:string, 'Open &Multiple...', :openMultiple).
			append(:string, 'Save &As...', :saveAs).

			append(:separator).

			append(:string, 'Select &Folder...', :selectFolder)
		)

	window.
		on(:command, :open) {
			ShellFileOpenDialog.new { |dialog|
				message dialog.path if dialog.show.ok?
			}
		}.

		on(:command, :openMultiple) {
			ShellFileOpenDialog.new { |dialog|
				dialog.SetOptions(Windows::FOS_ALLOWMULTISELECT)

				message dialog.paths.join("\n") if dialog.show.ok?
			}
		}.

		on(:command, :saveAs) {
			ShellFileSaveDialog.new { |dialog|
				message dialog.path if dialog.show.ok?
			}
		}.

		on(:command, :selectFolder) {
			ShellFolderDialog.new { |dialog|
				message dialog.path if dialog.show.ok?
			}
		}
}
