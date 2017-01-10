require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window)

	backgroundhsb = window.ribbon.background
	colorhsb = window.ribbon.color
	highlighthsb = window.ribbon.highlight

	window.ribbon.
		on(:preview, CmdPicker1) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.background = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}.

		on(:cancelPreview, CmdPicker1) {
			window.ribbon.background = backgroundhsb
		}.

		on(:execute, CmdPicker1) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.background = backgroundhsb = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}.

		on(:preview, CmdPicker2) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.color = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}.

		on(:cancelPreview, CmdPicker2) {
			window.ribbon.color = colorhsb
		}.

		on(:execute, CmdPicker2) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.color = colorhsb = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}.

		on(:preview, CmdPicker3) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.highlight = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}.

		on(:cancelPreview, CmdPicker3) {
			window.ribbon.highlight = highlighthsb
		}.

		on(:execute, CmdPicker3) { |args|
			next unless args[:value].uint == Windows::UI_SWATCHCOLORTYPE_RGB

			colorref = args[:props].uiprop(:Color).uint

			window.ribbon.highlight = highlighthsb = Windows.UI_RGB2HSB(
				Windows.GetRValue(colorref), Windows.GetGValue(colorref), Windows.GetBValue(colorref)
			)
		}

	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}
}
