require 'fzeet'

include Fzeet

Window1 = Window['X.Window1',
	background: SystemBrush.new(:appworkspace)
]

class Window1
	message <<-MSG
class: #{self}
superclass: #{self.superclass}
WindowClass: #{self::WindowClass.name}
WindowClass.prototype: #{self::WindowClass.prototype.name}
	MSG

	def initialize(opts = {})
		(opts[:style] ||= []) << :hscroll

		super
	end
end

Window2 = Window1['X.Window2',
	cursor: SystemCursor.new(:hand)
]

class Window2
	message <<-MSG
class: #{self}
superclass: #{self.superclass}
WindowClass: #{self::WindowClass.name}
WindowClass.prototype: #{self::WindowClass.prototype.name}
	MSG

	def initialize(opts = {})
		(opts[:style] ||= []) << :vscroll

		super
	end
end

Application.run(Window2.new)
