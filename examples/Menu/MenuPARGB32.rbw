require 'fzeet'

include Fzeet

Application.run { |window|
	Application.images.tap { |images|
		images[:cut] = PARGB32.new('../res/edit-cut.bmp')
		images[:copy] = PARGB32.new('../res/edit-copy.bmp')
		images[:paste] = PARGB32.new('../res/edit-paste.bmp')
	}

	window.menu = Menu.new.
		append(:popup, '&Edit', PopupMenu.new.
			append(:string, 'Cu&t', :cut).
			append(:string, '&Copy', :copy).
			append(:string, '&Paste', :paste)
		)

	window.menu.images = Application.images

	window.stubNotImplementedCommands
}
