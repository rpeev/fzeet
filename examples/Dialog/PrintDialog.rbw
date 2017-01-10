require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&File', PopupMenu.new.
			append(:string, 'Page Set&up...', :pageSetup).
			append(:string, '&Print...', :print).
			append(:string, 'P&rint1...', :print1)
		)

	window.
		on(:command, :pageSetup) {
			dialog = PageSetupDialog.new

			message dialog.show.ok?
		}.

		on(:command, :print) {
			dialog = PrintDialog.new

			message dialog.show.ok?
		}.

		on(:command, :print1) {
			dialog = PrintDialogEx.new

			message dialog.show.ok?
		}
}
