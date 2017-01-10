require 'fzeet'

include Fzeet

Application.run { |window|
	(browser = WebBrowser.new(window)).
		on(:NavigateComplete) {
			browser.document.on(:ready) {
				all = browser.document.all

				all.get('html').get(0).
					css(overflow: 'auto')

				all.get('body').get(0).
					css(overflow: 'auto', margin: '0', padding: '0', background: '#cedefa')

				(tab1 = all.get('#tab1')).
					on(:click) { message tab1.attr('href').split('#').last }

				(tab2 = all.get('#tab2')).
					on(:click) { message tab2.attr('href').split('#').last }
			}
		}.

		goto("file:///#{File.expand_path('jQueryUI.html')}")
}
