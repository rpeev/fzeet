require 'fzeet'

include Fzeet

Application.run { |window|
	(browser = WebBrowser.new(window)).
		on(:BeforeNavigate) { message 'on(:BeforeNavigate)' }.

		on(:NavigateComplete) {
			browser.document.on(:ready) {
				message 'DOM is ready'

				browser.document.window.on(:load) {
					message 'All assets are loaded'
				}
			}
		}.

		search
}
