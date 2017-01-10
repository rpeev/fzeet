require 'fzeet'

include Fzeet

Application.run { |window|
	(browser = WebBrowser.new(window)).
		on(:NavigateComplete) {
			SafeArray.vector(1) { |sa|
				browser.document.write(sa.put(0, Variant[:bstr, %{
<!doctype html>
<html>
	<head>
		<title>Hello</title>
	</head>
	<body>
<h1>Hello, world!</h1>
	</body>
</html>
				}]))
			}
		}.

		goto('about:blank')
}
