require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Edit.new(window, :edit1, style: :number, position: [10, 10, 76, 24])
	UpDown.new(window, :updown1, style: [:setbuddyint, :alignright], position: [90, 10, 76, 24]).tap { |ud|
		ud.buddy = window[:edit1]
		ud.range = 42, 45
		ud.position = 43
	}
}
