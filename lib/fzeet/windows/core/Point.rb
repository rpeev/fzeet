require_relative 'Common'

module Fzeet
	module Windows
		class POINT < FFI::Struct
			layout \
				:x, :long,
				:y, :long

			def self.[](x, y) new.set(x, y) end

			class << self
				alias from []
				alias wrap new
			end

			def dup; self.class[self[:x], self[:y]] end

			def get; [self[:x], self[:y]] end
			alias to_a get

			def set(x, y) tap { |pt| pt[:x], pt[:y] = x, y } end

			def clear; set(0, 0) end

			def ==(other) self[:x] == other[:x] && self[:y] == other[:y] end
			def inside?(r) r.include?(self) end
			def outside?(r) !inside?(r) end

			def offset(dx, dy) dup.offset!(dx, dy) end
			def offset!(dx, dy) tap { |pt| pt[:x] += dx; pt[:y] += dy } end

			def client(window) dup.client!(window) end
			def client!(window) tap { |pt| Windows.Detonate(0, :ScreenToClient, window.handle, pt) } end

			def screen(window) dup.screen!(window) end
			def screen!(window) tap { |pt| Windows.Detonate(0, :ClientToScreen, window.handle, pt) } end
		end
	end

	Point = Windows::POINT
end
