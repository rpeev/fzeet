require 'fzeet'

include Fzeet

Application.run { |window|
	dialog = ColorDialog.new

	dialog.on(:initdialog) { message 'on(:initdialog)' }

	window.menu = Menu.new.
		append(:popup, '&View', PopupMenu.new.
			append(:string, '&Color...', :color)
		)

	window.
		on(:command, :color) {
			message dialog.color if dialog.show.ok?
		}.

		on(:destroy) { dialog.dispose }
}
