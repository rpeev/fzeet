require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window, name: 'Minimal').
		on(:size) { window.invalidate }.
		on(CmdButton1) { message 'on(CmdButton1)' }.

	window.on(:draw, Control::Font) { |dc|
		dc.sms 'The quick brown fox jumps over the lazy dog. 1234567890'
	}
}
