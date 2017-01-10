require_relative 'Common'

module Fzeet
	module Windows
		class PROPVARIANT < FFI::Union
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
								:cVal, :char,
								:bVal, :uchar,
								:iVal, :short,
								:uiVal, :ushort,
								:lVal, :long,
								:ulVal, :ulong,
								:intVal, :int,
								:uintVal, :uint,
								:hVal, LARGE_INTEGER,
								:uhVal, ULARGE_INTEGER,
								:fltVal, :float,
								:dblVal, :double,
								:boolVal, :short,
								:bool, :short,
								:scode, :long,
								:cyVal, :long_long,
								:date, :double,
								:filetime, FILETIME,
								:puuid, :pointer,
								:pclipdata, :pointer,
								:bstrVal, :pointer,
								:bstrblobVal, BSTRBLOB,
								:blob, BLOB,
								:pszVal, :pointer,
								:pwszVal, :pointer,
								:punkVal, :pointer,
								:pdispVal, :pointer,
								:pStream, :pointer,
								:pStorage, :pointer,
								:pVersionedStream, :pointer,
								:parray, :pointer,
								:cac, CA,
								:caub, CA,
								:cai, CA,
								:caui, CA,
								:cal, CA,
								:caul, CA,
								:cah, CA,
								:cauh, CA,
								:caflt, CA,
								:cadbl, CA,
								:cabool, CA,
								:cascode, CA,
								:cacy, CA,
								:cadate, CA,
								:cafiletime, CA,
								:cauuid, CA,
								:caclipdata, CA,
								:cabstr, CA,
								:cabstrblob, CA,
								:calpstr, CA,
								:calpwstr, CA,
								:capropvar, CA,
								:pcVal, :pointer,
								:pbVal, :pointer,
								:piVal, :pointer,
								:puiVal, :pointer,
								:plVal, :pointer,
								:pulVal, :pointer,
								:pintVal, :pointer,
								:puintVal, :pointer,
								:pfltVal, :pointer,
								:pdblVal, :pointer,
								:pboolVal, :pointer,
								:pdecVal, :pointer,
								:pscode, :pointer,
								:pcyVal, :pointer,
								:pdate, :pointer,
								:pbstrVal, :pointer,
								:ppunkVal, :pointer,
								:ppdispVal, :pointer,
								:pparray, :pointer,
								:pvarVal, :pointer
						}
				},

				:decVal, DECIMAL

			def self.[](t, *v) new.tap { |var| var.send("#{t}=", *v) } end

			def bool; raise 'Wrong type tag.' unless self[:vt] == VT_BOOL; self[:boolVal] != 0 end
			def bool=(bool) self[:vt] = VT_BOOL; self[:boolVal] = (bool) ? -1 : 0 end

			def int; raise 'Wrong type tag.' unless self[:vt] == VT_I4; self[:intVal] end
			def int=(int) self[:vt] = VT_I4; self[:intVal] = int end

			def uint; raise 'Wrong type tag.' unless self[:vt] == VT_UI4; self[:uintVal] end
			def uint=(uint) self[:vt] = VT_UI4; self[:uintVal] = uint end

			def unknown
				raise 'Wrong type tag.' unless self[:vt] == VT_UNKNOWN

				yield Unknown.new(self[:punkVal])
			ensure
				Windows.PropVariantClear(self)
			end

			def unknown=(unknown) self[:vt] = VT_UNKNOWN; self[:punkVal] = unknown.pointer; unknown.AddRef end

			def wstring; raise 'Wrong type tag.' unless self[:vt] == VT_LPWSTR; Windows.WCSTOMBS(self[:pwszVal]) end

			def wstring=(string)
				self[:vt] = VT_LPWSTR

				FFI::MemoryPointer.new(:pointer) { |p|
					Windows.DetonateHresult(:SHStrDup, string, p)

					self[:pwszVal] = p.read_pointer
				}
			end

			def decimal
				raise 'Wrong type tag.' unless self[:vt] == VT_DECIMAL

				Rational(self[:decVal][:Lo64], 10 ** self[:decVal][:scale]) + self[:decVal][:Hi32]
			end

			def decimal=(decimal) self[:vt] = VT_DECIMAL; self[:decVal][:Lo64] = decimal end
		end

		attach_function :PropVariantClear, [:pointer], :long
	end

	PropVariant = Windows::PROPVARIANT
end
