require_relative 'Common'

module Fzeet
	module Windows
		class SAFEARRAYBOUND < FFI::Struct
			layout \
				:cElements, :ulong,
				:lLbound, :long
		end

		class SAFEARRAY < FFI::Struct
			include Enumerable

			layout \
				:cDims, :ushort,
				:fFeatures, :ushort,
				:cbElements, :ulong,
				:cLocks, :ulong,
				:pvData, :pointer,
				:rgsabound, [SAFEARRAYBOUND, 1]

			def self.vector(length, vt = :variant)
				raise 'Not implemented.' if vt != :variant

				raise 'SafeArrayCreateVector failed.' if
					(psa = Windows.SafeArrayCreateVector(Windows.const_get("VT_#{vt.upcase}"), 0, length)).null?

				sa = new(psa)

				if block_given?
					yield sa; sa.dispose; return nil
				end

				sa
			end

			def length(dim = 0) raise 'Not implemented.' if dim != 0; self[:rgsabound][dim][:cElements] end

			def vt
				FFI::MemoryPointer.new(:ushort) { |pvt|
					Windows.DetonateHresult(:SafeArrayGetVartype, self, pvt)

					return pvt.get_ushort(0)
				}
			end

			alias old_get []

			def [](i)
				return old_get(i) if i.kind_of?(Symbol)

				FFI::MemoryPointer.new(:long) { |pi|
					pi.put_long(0, i)

					Windows.DetonateHresult(:SafeArrayGetElement, self, pi, v = VARIANT.new)

					return v
				}
			end

			alias get []

			alias old_put []=

			def []=(i, v)
				return old_put(i, v) if i.kind_of?(Symbol)

				FFI::MemoryPointer.new(:long) { |pi|
					pi.put_long(0, i)

					Windows.DetonateHresult(:SafeArrayPutElement, self, pi, v)
				}

				self
			end

			alias put []=

			def destroy; Windows.DetonateHresult(:SafeArrayDestroy, self) end
			alias dispose destroy

			def each; length.times { |i| yield self[i] }; self end
		end

		attach_function :SafeArrayCreateVector, [:ushort, :long, :uint], :pointer
		attach_function :SafeArrayCreate, [:ushort, :uint, :pointer], :pointer
		attach_function :SafeArrayDestroy, [:pointer], :long

		attach_function :SafeArrayGetVartype, [:pointer, :pointer], :long

		attach_function :SafeArrayGetElement, [:pointer, :pointer, :pointer], :long
		attach_function :SafeArrayPutElement, [:pointer, :pointer, :pointer], :long

		attach_function :SafeArrayLock, [:pointer], :long
		attach_function :SafeArrayUnlock, [:pointer], :long

		attach_function :SafeArrayPtrOfIndex, [:pointer, :pointer, :pointer], :long

		attach_function :SafeArrayAccessData, [:pointer, :pointer], :long
		attach_function :SafeArrayUnaccessData, [:pointer], :long
	end

	SafeArray = Windows::SAFEARRAY
end
