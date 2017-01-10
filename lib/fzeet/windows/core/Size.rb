require_relative 'Common'

module Fzeet
	module Windows
		class SIZE < FFI::Struct
			layout \
				:cx, :long,
				:cy, :long

			def self.[](cx, cy) new.set(cx, cy) end

			class << self
				alias from []
				alias wrap new
			end

			def dup; self.class[self[:cx], self[:cy]] end

			def get; [self[:cx], self[:cy]] end
			alias to_a get

			def set(cx, cy) tap { |s| s[:cx], s[:cy] = cx, cy } end

			def clear; set(0, 0) end

			def ==(other) self[:cx] == other[:cx] && self[:cy] == other[:cy] end

			def inflate(dx, dy) dup.inflate!(dx, dy) end
			def inflate!(dx, dy) tap { |s| s[:cx] += dx; s[:cy] += dy } end
		end
	end

	Size = Windows::SIZE
end
