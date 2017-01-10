require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window).
		on(CmdButton1) { message 'on(CmdButton1)' }

	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}
}
