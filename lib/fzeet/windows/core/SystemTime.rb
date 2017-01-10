require_relative 'Common'

module Fzeet
	module Windows
		class SYSTEMTIME < FFI::Struct
			layout \
				:wYear, :ushort,
				:wMonth, :ushort,
				:wDayOfWeek, :ushort,
				:wDay, :ushort,
				:wHour, :ushort,
				:wMinute, :ushort,
				:wSecond, :ushort,
				:wMilliseconds, :ushort

			def self.[](time) new.set(time) end

			class << self
				alias from []
				alias wrap new
			end

			def dup; self.class.new.tap { |st| st.members.each { |member| st[member] = self[member] } } end

			def get(as = :local)
				Time.send(as,
					self[:wYear], self[:wMonth], self[:wDay],
					self[:wHour], self[:wMinute], self[:wSecond], self[:wMilliseconds] * 1000
				)
			end

			def set(time)
				tap { |st|
					st[:wYear], st[:wMonth], st[:wDay],
					st[:wHour], st[:wMinute], st[:wSecond], st[:wMilliseconds] =
					time.year, time.month, time.day,
					time.hour, time.min, time.sec, (time.usec.to_f / 1000).round
				}
			end

			def ==(other) members.all? { |member| self[member] == other[member] } end
		end
	end

	SystemTime = Windows::SYSTEMTIME
end
