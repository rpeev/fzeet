require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	window.menu = Menu.new.
		append(:popup, 'Menu&1', PopupMenu.new.
			append(:string, "Item&1\tAlt+I", :item1)
		)

	Application.accelerators << AcceleratorTable.new(
		[:alt, :I, :item1]
	)

	Button.new(window, :button1, position: [10, 10, 76, 24])

	window.
		on(:command, :item1) {
			message 'on(:command, :item1)'

			window[:button1].enabled = true
			window.menu[:item1].enabled = false
		}.

		on(:command, :button1) { |args|
			message 'on(:command, :button1)'

			window.menu[:item1].enabled = true
			args[:sender].enabled = false
		}
}
