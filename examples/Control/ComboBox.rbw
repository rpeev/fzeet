require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Static.new(window, :static1, position: [10, 10, 200, 24])
	ComboBox.new(window, :combobox1, style: :dropdownlist, position: [10, 40, 200, 200])
	Edit.new(window, :edit1, position: [220, 10, 200, 24])
	Button.new(window, :add, caption: '&Add', position: [220, 40, 76, 24])
	Button.new(window, :clear, caption: '&Clear', position: [300, 40, 76, 24])

	window[:combobox1].
		on(:selchange) { |args| window[:static1].text = args[:sender][:selected] }.
		append(%w{Item1 Item2}).
		selected = 1

	window[:edit1].select.focus = true

	window[:add].on(:clicked) {
		window[:combobox1].append(window[:edit1].text).selected = :last

		window[:edit1].select.focus = true
	}

	window[:clear].on(:clicked) {
		[window[:combobox1], window[:static1], window[:edit1]].each(&:clear)

		window[:edit1].focus = true
	}
}
