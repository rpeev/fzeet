require_relative 'Common'

module Fzeet
	module Windows
		class OSVERSIONINFOEX < FFI::Struct
			layout \
				:dwOSVersionInfoSize, :ulong,
				:dwMajorVersion, :ulong,
				:dwMinorVersion, :ulong,
				:dwBuildNumber, :ulong,
				:dwPlatformId, :ulong,
				:szCSDVersion, [:char, 128],
				:wServicePackMajor, :ushort,
				:wServicePackMinor, :ushort,
				:wSuiteMask, :ushort,
				:wProductType, :uchar,
				:wReserved, :uchar

			def get!; tap { |ovi| ovi[:dwOSVersionInfoSize] = size; Windows.DetonateLastError(0, :GetVersionEx, ovi) } end

			def major; self[:dwMajorVersion] end
			def minor; self[:dwMinorVersion] end
			def build; self[:dwBuildNumber] end
			def sp; self[:wServicePackMajor] end

			def hex; (major << 8) + minor end

			def <=>(version)
				hex <=> case version
				when '2000', 2000; 0x0500
				when 'xp', :xp; 0x0501
				when 'vista', :vista; 0x0600
				when '7', 7; 0x0601
				else raise ArgumentError
				end
			end

			include Comparable

			def name
				case hex
				when 0x0500...0x0501; 'Windows 2000'
				when 0x0501...0x0600; 'Windows XP'
				when 0x0600...0x0601; 'Windows Vista'
				when 0x0601...0x0700; 'Windows 7'
				else 'Unknown'
				end
			end

			def to_s; "#{major}.#{minor}.#{build} SP#{sp} (#{name})" end
		end

		attach_function :GetVersionEx, :GetVersionExA, [:pointer], :int

		Version = OSVERSIONINFOEX.new.get!
	end
end
