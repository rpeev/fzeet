require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	font = IndirectFont.new(Control::Font.logfont.tap { |lf|
		lf.face = 'Comic Sans MS'
		lf.size = 18
		lf.bold = true
		lf.italic = true
		lf.underline = true
		lf.strikeout = true
	})

	color, background = Windows.RGB(255, 255, 255), Windows.RGB(128, 0, 0)

	(ribbon = UIRibbon.new(window)).
		invalidate(CmdFont1).invalidate(CmdFont2).invalidate(CmdFont3).

		on(:update, CmdFont1) { |args|
			ribbon.fontPropsUpdate(args) { |ps| ps.update(font.logfont) }
		}.

		on(:update, CmdFont2) { |args|
			ribbon.fontPropsUpdate(args) { |ps|
				ps.update(font.logfont)
				ps.uiprop(:FontProperties_ForegroundColor, Windows::PROPVARIANT[:uint, color])
			}
		}.

		on(:update, CmdFont3) { |args|
			ribbon.fontPropsUpdate(args) { |ps|
				ps.update(font.logfont)
				ps.uiprop(:FontProperties_ForegroundColor, Windows::PROPVARIANT[:uint, color])
				ps.uiprop(:FontProperties_BackgroundColor, Windows::PROPVARIANT[:uint, background])
			}
		}.

		on(:execute, CmdFont1) { |args|
			font.dispose

			ribbon.fontPropsChanged(args) { |ps|
				font = IndirectFont.new(font.logfont.update(ps))
			}

			window.invalidate; ribbon.invalidate(CmdFont2).invalidate(CmdFont3)
		}.

		on(:execute, CmdFont2) { |args|
			font.dispose

			ribbon.fontPropsChanged(args) { |ps|
				font = IndirectFont.new(font.logfont.update(ps))
				color = ps.uiprop(:FontProperties_ForegroundColor).uint if ps.key(0) == Windows::UI_PKEY_FontProperties_ForegroundColor
			}

			window.invalidate; ribbon.invalidate(CmdFont1).invalidate(CmdFont3)
		}.

		on(:execute, CmdFont3) { |args|
			font.dispose

			ribbon.fontPropsChanged(args) { |ps|
				font = IndirectFont.new(font.logfont.update(ps))
				color = ps.uiprop(:FontProperties_ForegroundColor).uint if ps.key(0) == Windows::UI_PKEY_FontProperties_ForegroundColor
				background = ps.uiprop(:FontProperties_BackgroundColor).uint if ps.key(0) == Windows::UI_PKEY_FontProperties_BackgroundColor
			}

			window.invalidate; ribbon.invalidate(CmdFont1).invalidate(CmdFont2)
		}

	window.
		on(:paint) { window.paint { |dc| dc.select(font) {
			dc.color, dc.background = color, background
			dc.sms 'The quick brown fox jumps over the lazy dog. 1234567890'
		}}}.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}.

		on(:destroy) { font.dispose }
}
