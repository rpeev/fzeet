require_relative 'Point'

module Fzeet
	module Windows
		class RECT < FFI::Struct
			layout \
				:left, :long,
				:top, :long,
				:right, :long,
				:bottom, :long

			def self.[](*args)
				case args.length
				when 2 # location, size
					new.set(args[0][:x], args[0][:y], args[0][:x] + args[1][:cx], args[0][:y] + args[1][:cy])
				when 4 # left, top, right, bottom
					new.set(*args)
				else raise ArgumentError
				end
			end

			class << self
				alias from []
				alias wrap new
			end

			def dup; self.class[self[:left], self[:top], self[:right], self[:bottom]] end

			def get; [self[:left], self[:top], self[:right], self[:bottom]] end
			alias to_a get

			def set(l, t, r, b) tap { |rect| rect[:left], rect[:top], rect[:right], rect[:bottom] = l, t, r, b } end

			def clear; set(0, 0, 0, 0) end

			def lt; POINT[self[:left], self[:top]] end
			def lt=(pt) self[:left], self[:top] = pt[:x], pt[:y] end
			alias location lt
			alias location= lt=

			def lb; POINT[self[:left], self[:bottom]] end
			def lb=(pt) self[:left], self[:bottom] = pt[:x], pt[:y] end

			def rt; POINT[self[:right], self[:top]] end
			def rt=(pt) self[:right], self[:top] = pt[:x], pt[:y] end

			def rb; POINT[self[:right], self[:bottom]] end
			def rb=(pt) self[:right], self[:bottom] = pt[:x], pt[:y] end

			def width; self[:right] - self[:left] end
			def width=(width) self[:right] = self[:left] + width end

			def height; self[:bottom] - self[:top] end
			def height=(height) self[:bottom] = self[:top] + height end

			alias structSize size

			def size; SIZE[width, height] end
			def size=(s) self.width, self.height = s[:cx], s[:cy] end

			def ==(other) Windows.EqualRect(self, other) != 0 end
			def empty?; Windows.IsRectEmpty(self) != 0 end

			def include?(*args)
				return args.all? { |arg| include?(arg) } if args.length > 1

				case args[0]
				when POINT; Windows.PtInRect(self, args[0]) != 0
				when RECT; [args[0].lt, args[0].lb, args[0].rt, args[0].rb].all? { |pt| include?(pt) }
				else raise ArgumentError
				end
			end

			def exclude?(arg) !include?(arg) end

			def normalized?; self[:left] <= self[:right] && self[:top] <= self[:bottom] end

			def normalize; dup.normalize! end

			def normalize!
				self[:left], self[:right] = self[:right], self[:left] if self[:left] > self[:right]
				self[:top], self[:bottom] = self[:bottom], self[:top] if self[:top] > self[:bottom]

				self
			end

			def offset(dx, dy) dup.offset!(dx, dy) end
			def offset!(dx, dy) tap { |r| Windows.Detonate(0, :OffsetRect, r, dx, dy) } end

			def inflate(dx, dy) dup.inflate!(dx, dy) end
			def inflate!(dx, dy) tap { |r| Windows.Detonate(0, :InflateRect, r, dx, dy) } end

			def |(other) self.class.new.tap { |r| Windows.UnionRect(r, self, other) } end
			def &(other) self.class.new.tap { |r| Windows.IntersectRect(r, self, other) } end
			def -(other) self.class.new.tap { |r| Windows.SubtractRect(r, self, other) } end
		end

		ffi_lib 'user32'
		ffi_convention :stdcall

		attach_function :EqualRect, [:pointer, :pointer], :int
		attach_function :IsRectEmpty, [:pointer], :int
		attach_function :PtInRect, [:pointer, POINT.by_value], :int

		attach_function :OffsetRect, [:pointer, :int, :int], :int
		attach_function :InflateRect, [:pointer, :int, :int], :int

		attach_function :UnionRect, [:pointer, :pointer, :pointer], :int
		attach_function :IntersectRect, [:pointer, :pointer, :pointer], :int
		attach_function :SubtractRect, [:pointer, :pointer, :pointer], :int
	end

	Rect = Windows::RECT
end
