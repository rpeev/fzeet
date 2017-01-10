require 'fzeet'

include Fzeet

Application.run { |window|
	r = UIRibbon.new(window, name: 'Minimal').
		on(CmdButton1) { message 'on(CmdButton1)' }

	r.background.darken(20).bleach(50)
	r.color.saturate(100).lighten(20)
	r.highlight.shift(-20).darken(20)
}
