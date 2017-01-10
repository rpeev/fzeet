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
	<button id='button1'>Button1</button>
	<input type='checkbox' id='check1' /> <label id='label1' for='check1'>Check1</label>
</div>
					HTML

				(button1 = all.get('#button1')).
					on(:click) { message button1.className }.
					className = 'Foo'

				(check1 = all.get('#check1')).
					on(:click) { message check1.attr(:checked) }.
					attr(:checked, true)

				(label1 = all.get('#label1')).
					css(border: '1px dotted red', cursor: 'hand')
			}
		}.

		goto('about:blank')
}
