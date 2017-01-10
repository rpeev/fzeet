require 'fzeet'

include Fzeet

Application.run { |window|
	UIRibbon.new(window).
		on(CmdButton1) { message 'on(CmdButton1)' }
}
