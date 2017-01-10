require_relative '../com'

module Fzeet
	module Windows
		ffi_lib 'ole32'
		ffi_convention :stdcall

		attach_function :OleInitialize, [:pointer], :long
		attach_function :OleUninitialize, [], :void

		def InitializeOle
			DetonateHresult(:OleInitialize, nil)

			at_exit { OleUninitialize() }
		end

		module_function :InitializeOle

		attach_function :CoTaskMemAlloc, [:ulong], :pointer
		attach_function :CoTaskMemFree, [:pointer], :void

		class LARGE_INTEGER < FFI::Union
			include AnonymousSupport

			layout \
				:_, Class.new(FFI::Struct) {
					layout \
						:LowPart, :ulong,
						:HighPart, :long
				},

				:QuadPart, :long_long
		end

		class ULARGE_INTEGER < FFI::Union
			include AnonymousSupport

			layout \
				:_, Class.new(FFI::Struct) {
					layout \
						:LowPart, :ulong,
						:HighPart, :ulong
				},

				:QuadPart, :ulong_long
		end

		class FILETIME < FFI::Struct
			layout \
				:dwLowDateTime, :ulong,
				:dwHighDateTime, :ulong
		end

		class BSTRBLOB < FFI::Struct
			layout \
				:cbSize, :ulong,
				:pData, :pointer
		end

		class BLOB < FFI::Struct
			layout \
				:cbSize, :ulong,
				:pBlobData, :pointer
		end

		class CA < FFI::Struct
			layout \
				:cElems, :ulong,
				:pElems, :pointer
		end

		class DECIMAL < FFI::Struct
			layout \
				:wReserved, :ushort,
				:scale, :uchar,
				:sign, :uchar,
				:Hi32, :ulong,
				:Lo64, :ulong_long

			def self.[](value)
				new.tap { |decimal|
					case value
					when Integer; Windows.DetonateHresult(:VarDecFromI8, value, decimal)
					when Float; Windows.DetonateHresult(:VarDecFromR8, value, decimal)
					else raise ArgumentError
					end
				}
			end

			def i8
				FFI::MemoryPointer.new(:long_long) { |pi8|
					Windows.DetonateHresult(:VarI8FromDec, self, pi8)

					return pi8.get_long_long(0)
				}
			end

			def r8
				FFI::MemoryPointer.new(:double) { |pr8|
					Windows.DetonateHresult(:VarR8FromDec, self, pr8)

					return pr8.get_double(0)
				}
			end

			alias longlong i8; alias int longlong
			alias double r8; alias float double
		end
	end

	Decimal = Windows::DECIMAL
end
