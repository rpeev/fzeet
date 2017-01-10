require 'fzeet'

include Fzeet

Application.run { |window|
	UIRibbon.new(window).
		on(:size) {
			window[:edit1].position = 10, window.ribbon.height + 10, 200, 18
		}

	Edit.new(window, :edit1, caption: '').
		on(:setfocus) { |args|
			window.ribbon.uif.SetUICommandProperty(CmdTabGroup1, Windows::UI_PKEY_ContextAvailable, Windows::PROPVARIANT[:int, 1])

			args[:sender].cuebanner = 'Now click outside...'
		}.

		cuebanner = 'Click here...'

	window.on(:lbuttondown) {
		window.ribbon.uif.SetUICommandProperty(CmdTabGroup1, Windows::UI_PKEY_ContextAvailable, Windows::PROPVARIANT[:int, 0])

		if window[:edit1].focus?
			window[:edit1].focus = false
			window[:edit1].cuebanner = 'Click here...'
		end
	}
}
