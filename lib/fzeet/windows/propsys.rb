require_relative 'ole'

module Fzeet
	module Windows
		ffi_lib 'propsys'
		ffi_convention :stdcall

		IPropertyStore = COM::Interface[IUnknown,
			GUID['886d8eeb-8cf2-4446-8d02-cdba1dbdcf99'],

			GetCount: [[:pointer], :long],
			GetAt: [[:ulong, :pointer], :long],
			GetValue: [[:pointer, :pointer], :long],
			SetValue: [[:pointer, :pointer], :long],
			Commit: [[], :long]
		]

		PropertyStore = COM::Instance[IPropertyStore]

		class PropertyStore
			include Enumerable

			def count; FFI::MemoryPointer.new(:ulong) { |pc| GetCount(pc); return pc.get_ulong(0) } end
			alias :size :count
			alias :length :count

			def key(i) PROPERTYKEY.new.tap { |k| GetAt(i, k) } end

			# superclass.superclass is FFI::Struct, so do NOT touch [] and []=
			def get(k) PROPVARIANT.new.tap { |v| GetValue(k, v) } end
			def set(k, v) SetValue(k, v); self end

			def prop(*args)
				case args.length
				when 1; get(*args)
				when 2; set(*args)
				else raise ArgumentError
				end
			end

			def commit; Commit(); self end

			def each; length.times { |i| v = get(k = key(i)); yield k, v }; self end
		end
	end
end
