require 'fzeet'

include Fzeet

Application.run { |window|
	UIRibbon.new(window).
		on(CmdItem1) { |args|
			message 'on(CmdItem1)'

			window.ribbon[CmdButton1].enabled = true
			args[:sender].enabled = false
		}.

		on(CmdButton1) { |args|
			message 'on(CmdButton1)'

			window.ribbon[CmdItem1].enabled = true
			args[:sender].enabled = false
		}
}
