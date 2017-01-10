require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	window.on(:draw, Control::Font) { |dc|
		dc.sms 'The quick brown fox jumps over the lazy dog. 1234567890'
	}
}
