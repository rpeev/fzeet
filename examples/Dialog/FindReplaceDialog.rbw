require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&Edit', PopupMenu.new.
			append(:string, '&Find...', :find).
			append(:string, '&Replace...', :replace)
		)

	window.
		on(:command, :find) {
			dialog = FindDialog.new

			dialog.on(:initdialog) { |args| message 'on(:initdialog)'; args[:result] = 1 }

			dialog.show.
				onNotify(:findnext) { message "on(:findnext) - #{dialog.findWhat}" }.
				onNotify(:dialogterm) { [:find, :replace].each { |id| window.menu[id].enabled = true } }

			[:find, :replace].each { |id| window.menu[id].enabled = false }
		}.

		on(:command, :replace) {
			dialog = ReplaceDialog.new

			dialog.on(:initdialog) { |args| message 'on(:initdialog)'; args[:result] = 1 }

			dialog.show.
				onNotify(:findnext) { message "on(:findnext) - #{dialog.findWhat}" }.
				onNotify(:replace) { message "on(:replace) - #{dialog.findWhat} with #{dialog.replaceWith}" }.
				onNotify(:replaceall) { message "on(:replaceall) - #{dialog.findWhat} with #{dialog.replaceWith}" }.
				onNotify(:dialogterm) { [:find, :replace].each { |id| window.menu[id].enabled = true } }

			[:find, :replace].each { |id| window.menu[id].enabled = false }
		}
}
