require 'fzeet'

include Fzeet

class Window1 < Window
	message <<-MSG
class: #{self}
superclass: #{self.superclass}
WindowClass: #{self::WindowClass.name}
WindowClass.prototype: #{self::WindowClass.prototype.name}
	MSG

	def initialize
		super

		self.menu = Menu.new.
			append(:popup, 'Menu&1', PopupMenu.new.
				append(:string, 'Item&1', :item1)
			)

		on(:command, :item1, &method(:onItem1))
	end

	def onItem1(args)
		message "Window1##{__method__}"
	end
end

class Window2 < Window1
	message <<-MSG
class: #{self}
superclass: #{self.superclass}
WindowClass: #{self::WindowClass.name}
WindowClass.prototype: #{self::WindowClass.prototype.name}
	MSG

	def onItem1(args)
		message "Window2##{__method__}"

		super
	end
end

Application.run(Window2.new)
