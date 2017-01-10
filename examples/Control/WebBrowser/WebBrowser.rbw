require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&View', PopupMenu.new.
			append(:string, '&Refresh', :refresh)
		).

		append(:popup, '&Go To', PopupMenu.new.
			append(:string, '&Back', :back).
			append(:string, '&Forward', :forward).
			append(:string, '&Home', :home).
			append(:string, '&Search', :search)
		)

	(browser = WebBrowser.new(window)).
		on(:NavigateComplete) { |dispParams|
			next if dispParams[:cArgs] < 1 || (arg1 = Variant.new(dispParams[:rgvarg]))[:vt] != Windows::VT_BSTR

			message arg1.string

			browser.document.
				on(:click) { message 'on(:click)' }.
				on(:click) { message 'on(:click2)' }
		}.

		search

	window.
		on(:command, :refresh, &browser.method(:refresh)).

		on(:command, :back, &browser.method(:back)).
		on(:command, :forward, &browser.method(:forward)).
		on(:command, :home, &browser.method(:home)).
		on(:command, :search, &browser.method(:search))
}
