require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args| using(
			PopupMenu.new.
				append(:string, 'Item&1', :item1)
		) { |popup|
			popup.track(window, args[:x], args[:y])
		}}.

		on(:command, :item1) { message 'on(:command, :item1)' }
}
