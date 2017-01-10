require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Application.images[:image] = image = PARGB32.new('../res/go-jump-small.bmp')

	Button.new(window, :button1, position: [10, 10, 76, 24])
	Button.new(window, :button2, style: :notify, position: [10, 40, 76, 24])
	Button.new(window, :button3, style: [:splitbutton, :bitmap], position: [10, 70, 40, 24]).image = image
	Button.new(window, :button4, style: :commandlink, position: [10, 100, 200, 60]).note = 'Description...'
	Button.new(window, :check1, style: :autocheckbox, position: [90, 10, 76, 24])
	Static.new(window, :static1, position: [170, 10, 76, 24]).text = window[:check1].checked?
	Button.new(window, :check2, style: :auto3state, position: [90, 40, 76, 24])
	Static.new(window, :static2, position: [170, 40, 76, 24]).text = window[:check2].checked?
	Static.new(window, :static3, position: [250, 40, 76, 24]).text = window[:check2].indeterminate?
	Button.new(window, :radio1, style: [:autoradiobutton, :group], position: [330, 10, 76, 24])
	Button.new(window, :radio2, style: :autoradiobutton, position: [330, 40, 76, 24]).checked = true
	Button.new(window, :radio3, style: [:autoradiobutton, :group], position: [330, 70, 76, 24])
	Button.new(window, :radio4, style: :autoradiobutton, position: [330, 100, 76, 24]).checked = true
	Button.new(window, :groupbox1, style: :groupbox, position: [410, 10, 150, 110])

	window[:button1].on(:clicked) { message 'on(:command, :button1, :clicked)' }
	window[:button2].on(:doubleclicked) { message 'on(:command, :button2, :doubleclicked)' }
	window[:button3].
		on(:clicked) { message 'on(:command, :button3, :clicked)' }.
		on(:dropdown) { |args| using(
			PopupMenu.new.
				append(:string, 'Item&1', :item1)
		) { |popup|
			popup.track(window, *args[:sender].position.lb.to_a)
		}}
	window[:button4].on(:clicked) { message 'on(:command, :button4, :clicked)' }
	window[:check1].on(:clicked) { |args| window[:static1].text = args[:sender].checked? }
	window[:check2].on(:clicked) { |args|
		window[:static2].text = args[:sender].checked?
		window[:static3].text = args[:sender].indeterminate?
	}

	window.on(:command, :item1) { message 'on(:command, :item1)' }
}
