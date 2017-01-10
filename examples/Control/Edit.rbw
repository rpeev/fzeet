require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Edit.new(window, :edit1, position: [10, 10, 76, 24])
	Static.new(window, :static1, position: [10, 40, 76, 24])
	Edit.new(window, :edit2, caption: '', style: :password, position: [10, 70, 76, 24]).cuebanner = 'password'

	window[:edit1].
		on(:change) { |args| window[:static1].text = args[:sender].text }.
		select.
		focus = true

	window[:edit2].on(:setfocus) { |args|
		args[:sender].showBalloontip('text', 'title')
	}
}
