require 'fzeet'

include Fzeet

Application.run { |window|
	UIRibbon.new(window).
		on(CmdPrintPreview) {
			window.ribbon.uif.SetModes(Windows.UI_MAKEAPPMODE(1))
		}.

		on(CmdClosePrintPreview) {
			window.ribbon.uif.SetModes(Windows.UI_MAKEAPPMODE(0))
		}
}
