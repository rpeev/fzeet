require 'fzeet'

include Fzeet

Application.run { |window|
	window.style >> :thickframe << :hscroll << :vscroll

	window.reframe

	window.menu = Menu.new.
		append(:popup, '&View', PopupMenu.new.
			append(:string, 'Always on &Top', :alwaysOnTop)
		)

	window.on(:command, :alwaysOnTop) {
		window.toggle(:topmost).
			menu[:alwaysOnTop].toggle(:checked)
	}
}
