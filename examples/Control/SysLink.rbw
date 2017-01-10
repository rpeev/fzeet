require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	SysLink.new(window, :syslink1, caption: '<a href="http://www.ruby-lang.org/">Ruby</a>', position: [10, 10, 76, 24])

	window[:syslink1].on(:click) { |args| shell(args[:url]) }
}
