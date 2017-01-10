require 'fzeet'

include Fzeet

Application.run { |window|
	(browser = WebBrowser.new(window)).
		on(:NavigateComplete) {
			browser.document.on(:ready) {
				all = browser.document.all

				(head = all.get('head').get(0)).
					node.
						appendChild(browser.document.createElement("<meta http-equiv='MSThemeCompatible' content='yes' />"))

				(body = all.get('body').get(0)).
					css(overflow: 'auto').
					innerHTML = <<-HTML
<div>
	<button id='button1'>Button1</button> <span id='span1'></span>
</div>
					HTML

				button1 = nil

				(xrequest = browser.document.xrequest).
					on(:load) {
						all.get('#span1').innerText = xrequest.responseText

						button1.attr(:disabled, false)
					}.

					on(:timeout) {
						all.get('#span1').innerText = 'Timeout'

						button1.attr(:disabled, false)
					}.

					on(:error) {
						all.get('#span1').innerText = 'Error'

						button1.attr(:disabled, false)
					}

				(button1 = all.get('#button1')).
					on(:click) {
						xrequest.
							open('http://localhost:4567/hello').
							send(Variant.new)

						button1.attr(:disabled, true)
					}
			}
		}.

		goto("http://#{ENV['ComputerName']}:4567/")
}
