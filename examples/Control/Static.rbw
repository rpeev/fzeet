require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Application.images[:image] = image = PARGB32.new('../res/go-next.bmp')

	Static.new(window, :static1, position: [10, 10, 76, 24])
	Static.new(window, :static2, style: [:notify, :bitmap], position: [10, 40, 76, 24]).image = image
	Static.new(window, :static3, style: :grayframe, position: [90, 10, 76, 1])
	Static.new(window, :static4, style: :grayframe, position: [90, 40, 76, 76])

	window[:static2].on(:clicked) { message 'on(:command, :static2, :clicked)' }
}
