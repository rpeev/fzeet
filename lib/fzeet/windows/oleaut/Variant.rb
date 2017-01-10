require_relative 'Common'

module Fzeet
	module Windows
		VT_EMPTY = 0
		VT_NULL = 1
		VT_I2 = 2
		VT_I4 = 3
		VT_R4 = 4
		VT_R8 = 5
		VT_CY = 6
		VT_DATE = 7
		VT_BSTR = 8
		VT_DISPATCH = 9
		VT_ERROR = 10
		VT_BOOL = 11
		VT_VARIANT = 12
		VT_UNKNOWN = 13
		VT_DECIMAL = 14
		VT_I1 = 16
		VT_UI1 = 17
		VT_UI2 = 18
		VT_UI4 = 19
		VT_I8 = 20
		VT_UI8 = 21
		VT_INT = 22
		VT_UINT = 23
		VT_VOID = 24
		VT_HRESULT = 25
		VT_PTR = 26
		VT_SAFEARRAY = 27
		VT_CARRAY = 28
		VT_USERDEFINED = 29
		VT_LPSTR = 30
		VT_LPWSTR = 31
		VT_RECORD = 36
		VT_INT_PTR = 37
		VT_UINT_PTR = 38
		VT_FILETIME = 64
		VT_BLOB = 65
		VT_STREAM = 66
		VT_STORAGE = 67
		VT_STREAMED_OBJECT = 68
		VT_STORED_OBJECT = 69
		VT_BLOB_OBJECT = 70
		VT_CF = 71
		VT_CLSID = 72
		VT_VERSIONED_STREAM = 73
		VT_BSTR_BLOB = 0xfff
		VT_VECTOR = 0x1000
		VT_ARRAY = 0x2000
		VT_BYREF = 0x4000
		VT_RESERVED = 0x8000
		VT_ILLEGAL = 0xffff
		VT_ILLEGALMASKED = 0xfff
		VT_TYPEMASK = 0xfff

		class VARIANT < FFI::Union
			include AnonymousSupport

			layout \
				:_, Class.new(FFI::Struct) {
					layout \
						:vt, :ushort,
						:wReserved1, :ushort,
						:wReserved2, :ushort,
						:wReserved3, :ushort,
						:_, Class.new(FFI::Union) {
							layout \
								:llVal, :long_long, # VT_I8
								:lVal, :long, # VT_I4
								:bVal, :uchar, # VT_UI1
								:iVal, :short, # VT_I2
								:fltVal, :float, # VT_R4
								:dblVal, :double, # VT_R8
								:boolVal, :short, # VT_BOOL
								:bool, :short, # obsolete
								:scode, :long, # VT_ERROR
								:cyVal, :long_long, # VT_CY
								:date, :double, # VT_DATE
								:bstrVal, :pointer, # VT_BSTR
								:punkVal, :pointer, # VT_UNKNOWN
								:pdispVal, :pointer, # VT_DISPATCH
								:parray, :pointer, # VT_ARRAY
								:pbVal, :pointer, # VT_BYREF | VT_UI1
								:piVal, :pointer, # VT_BYREF | VT_I2
								:plVal, :pointer, # VT_BYREF | VT_I4
								:pllVal, :pointer, # VT_BYREF | VT_I8
								:pfltVal, :pointer, # VT_BYREF | VT_R4
								:pdblVal, :pointer, # VT_BYREF | VT_R8
								:pboolVal, :pointer, # VT_BYREF | VT_BOOL
								:pbool, :pointer, # obsolete
								:pscode, :pointer, # VT_BYREF | VT_ERROR
								:pcyVal, :pointer, # VT_BYREF | VT_CY
								:pdate, :pointer, # VT_BYREF | VT_DATE
								:pbstrVal, :pointer, # VT_BYREF | VT_BSTR
								:ppunkVal, :pointer, # VT_BYREF | VT_UNKNOWN
								:ppdispVal, :pointer, # VT_BYREF | VT_DISPATCH
								:pparrayv, :pointer, # VT_BYREF | VT_ARRAY
								:pvarVal, :pointer, # VT_BYREF | VT_VARIANT
								:byref, :pointer, # VT_BYREF
								:cVal, :char, # VT_I1
								:uiVal, :ushort, # VT_UI2
								:ulVal, :ulong, # VT_UI4
								:ullVal, :ulong_long, # VT_UI8
								:intVal, :int, # VT_INT
								:uintVal, :uint, # VT_UINT
								:pdecVal, :pointer, # VT_BYREF | VT_DECIMAL
								:pcVal, :pointer, # VT_BYREF | VT_I1
								:puiVal, :pointer, # VT_BYREF | VT_UI2
								:pulVal, :pointer, # VT_BYREF | VT_UI4
								:pullVal, :pointer, # VT_BYREF | VT_UI8
								:pintVal, :pointer, # VT_BYREF | VT_INT
								:puintVal, :pointer, # VT_BYREF | VT_UINT
								:_, Class.new(FFI::Struct) { # VT_RECORD
									layout \
										:pvRecord, :pointer,
										:pRecInfo, :pointer
								}
 						}
				},

				:decVal, DECIMAL # VT_DECIMAL

			def self.[](type, value) new.tap { |variant| variant.send("#{type}=", value) } end

			def bool; raise 'Wrong type tag.' unless self[:vt] == VT_BOOL; self[:boolVal] != 0 end
			def bool=(bool) clear; self[:vt] = VT_BOOL; self[:boolVal] = (bool) ? -1 : 0 end

			%w{int    uint    i1   ui1  i2   ui2   i4   ui4   i8    ui8    error r4     r8}.zip(
			%w{intVal uintVal cVal bVal iVal uiVal lVal ulVal llVal ullVal scode fltVal dblVal}).each { |vt, val|
				define_method(vt) {
					raise 'Wrong type tag.' unless self[:vt] == Windows.const_get("VT_#{vt.upcase}"); self[val.to_sym]
				}

				define_method("#{vt}=") { |value|
					clear; self[:vt] = Windows.const_get("VT_#{vt.upcase}"); self[val.to_sym] = value
				}
			}

			alias char i1
			alias uchar ui1; alias byte uchar
			alias short i2
			alias ushort ui2; alias word ushort
			alias long i4
			alias ulong ui4; alias dword ulong
			alias longlong i8
			alias ulonglong ui8; alias qword ulonglong
			alias float r4
			alias double r8

			alias char= i1=
			alias uchar= ui1=; alias byte= uchar=
			alias short= i2=
			alias ushort= ui2=; alias word= ushort=
			alias long= i4=
			alias ulong= ui4=; alias dword= ulong=
			alias longlong= i8=
			alias ulonglong= ui8=; alias qword= ulonglong=
			alias float= r4=
			alias double= r8=

			def bstr; raise 'Wrong type tag.' unless self[:vt] == VT_BSTR; BSTR.new(self[:bstrVal]).multibyte end
			def bstr=(str) clear; self[:vt] = VT_BSTR; self[:bstrVal] = BSTR[str].pointer end

			alias string bstr
			alias string= bstr=

			def date
				raise 'Wrong type tag.' unless self[:vt] == VT_DATE

				raise 'VariantTimeToSystemTime failed.' if Windows.VariantTimeToSystemTime(self[:date], st = SYSTEMTIME.new) == 0

				st.get
			end

			def date=(date)
				clear

				self[:vt] = VT_DATE

				FFI::MemoryPointer.new(:double) { |pdate|
					raise 'SystemTimeToVariantTime failed.' if Windows.SystemTimeToVariantTime(SYSTEMTIME[date], pdate) == 0

					self[:date] = pdate.get_double(0)
				}
			end

			alias time date
			alias time= date=

			def decimal(as = :double)
				raise 'Wrong type tag.' unless self[:vt] == VT_DECIMAL

				DECIMAL.new(self[:decVal].pointer).send(as)
			end

			def decimal=(decimal)
				clear

				self[:vt] = VT_DECIMAL

				DECIMAL[decimal].tap { |dec|
					self[:decVal].members.each { |member|
						next if member == :wReserved # This is self[:vt]

						self[:decVal][member] = dec[member]
					}
				}
			end

			%w{unknown dispatch}.zip(
			%w{punkVal pdispVal}).each { |vt, val|
				define_method(vt) {
					raise 'Wrong type tag.' unless self[:vt] == Windows.const_get("VT_#{vt.upcase}")

					Windows.const_get(vt.capitalize).new(self[val.to_sym]).tap { |instance|
						instance.AddRef
					}
				}

				define_method("#{vt}=") { |instance|
					clear

					self[:vt] = Windows.const_get("VT_#{vt.upcase}")

					self[val.to_sym] = instance

					instance.AddRef
				}
			}

			def array
				raise 'Wrong type tag.' unless self[:vt] & VT_ARRAY == VT_ARRAY

				SAFEARRAY.new(self[:parray])
			end

			def array=(array) clear; self[:vt] = VT_ARRAY | VT_VARIANT; self[:parray] = array end

			def byref(deref = nil)
				raise 'Wrong type tag.' unless self[:vt] & VT_BYREF == VT_BYREF

				(deref) ? self[:byref].send("get_#{deref}", 0) : self[:byref]
			end

			def byref=(byref) clear; self[:vt] = VT_BYREF; self[:byref] = byref end

			def object; ObjectSpace._id2ref(i4) end
			def object=(object) self.i4 = object.object_id end

			def clear; Windows.DetonateHresult(:VariantClear, self); self end
		end

		attach_function :VariantInit, [:pointer], :void
		attach_function :VariantClear, [:pointer], :long

		attach_function :SystemTimeToVariantTime, [:pointer, :pointer], :int
		attach_function :VariantTimeToSystemTime, [:double, :pointer], :int

		attach_function :VarDecFromI8, [:long_long, :pointer], :long
		attach_function :VarI8FromDec, [:pointer, :pointer], :long

		attach_function :VarDecFromR8, [:double, :pointer], :long
		attach_function :VarR8FromDec, [:pointer, :pointer], :long
	end

	Variant = Windows::VARIANT
end
