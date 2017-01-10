require_relative '../core'

module Fzeet
	module Windows
		ffi_lib 'ole32'
		ffi_convention :stdcall

		S_OK = 0
		S_FALSE = 1

		E_UNEXPECTED = 0x8000FFFF - 0x1_0000_0000
		E_NOTIMPL = 0x80004001 - 0x1_0000_0000
		E_OUTOFMEMORY = 0x8007000E - 0x1_0000_0000
		E_INVALIDARG = 0x80070057 - 0x1_0000_0000
		E_NOINTERFACE = 0x80004002 - 0x1_0000_0000
		E_POINTER = 0x80004003 - 0x1_0000_0000
		E_HANDLE = 0x80070006 - 0x1_0000_0000
		E_ABORT = 0x80004004 - 0x1_0000_0000
		E_FAIL = 0x80004005 - 0x1_0000_0000
		E_ACCESSDENIED = 0x80070005 - 0x1_0000_0000
		E_PENDING = 0x8000000A - 0x1_0000_0000

		FACILITY_WIN32 = 7

		ERROR_CANCELLED = 1223

		def SUCCEEDED(hr) hr >= 0 end
		def FAILED(hr) hr < 0 end
		def HRESULT_FROM_WIN32(x) (x <= 0) ? x : (x & 0x0000FFFF) | (FACILITY_WIN32 << 16) | 0x80000000 end

		module_function \
			:SUCCEEDED,
			:FAILED,
			:HRESULT_FROM_WIN32

		def DetonateHresult(name, *args)
			failed = FAILED(result = send(name, *args)) and raise "#{name} failed (hresult #{format('%#08x', result)})."

			result
		ensure
			yield failed if block_given?
		end

		module_function :DetonateHresult

		class GUID < FFI::Struct
			layout \
				:Data1, :ulong,
				:Data2, :ushort,
				:Data3, :ushort,
				:Data4, [:uchar, 8]

			def self.[](s)
				raise 'Bad GUID format.' unless s =~ /^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$/i

				new.tap { |guid|
					guid[:Data1] = s[0, 8].to_i(16)
					guid[:Data2] = s[9, 4].to_i(16)
					guid[:Data3] = s[14, 4].to_i(16)
					guid[:Data4][0] = s[19, 2].to_i(16)
					guid[:Data4][1] = s[21, 2].to_i(16)
					s[24, 12].split('').each_slice(2).with_index { |a, i|
						guid[:Data4][i + 2] = a.join('').to_i(16)
					}
				}
			end

			def ==(other) Windows.memcmp(other, self, size) == 0 end
		end

		CLSCTX_INPROC_SERVER = 0x1
		CLSCTX_INPROC_HANDLER = 0x2
		CLSCTX_LOCAL_SERVER = 0x4
		CLSCTX_INPROC_SERVER16 = 0x8
		CLSCTX_REMOTE_SERVER = 0x10
		CLSCTX_INPROC_HANDLER16 = 0x20
		CLSCTX_RESERVED1 = 0x40
		CLSCTX_RESERVED2 = 0x80
		CLSCTX_RESERVED3 = 0x100
		CLSCTX_RESERVED4 = 0x200
		CLSCTX_NO_CODE_DOWNLOAD = 0x400
		CLSCTX_RESERVED5 = 0x800
		CLSCTX_NO_CUSTOM_MARSHAL = 0x1000
		CLSCTX_ENABLE_CODE_DOWNLOAD = 0x2000
		CLSCTX_NO_FAILURE_LOG = 0x4000
		CLSCTX_DISABLE_AAA = 0x8000
		CLSCTX_ENABLE_AAA = 0x10000
		CLSCTX_FROM_DEFAULT_CONTEXT = 0x20000
		CLSCTX_ACTIVATE_32_BIT_SERVER = 0x40000
		CLSCTX_ACTIVATE_64_BIT_SERVER = 0x80000
		CLSCTX_ENABLE_CLOAKING = 0x100000
		CLSCTX_PS_DLL = -0x80000000
		CLSCTX_INPROC = CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER
		CLSCTX_ALL = CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER | CLSCTX_LOCAL_SERVER | CLSCTX_REMOTE_SERVER
		CLSCTX_SERVER = CLSCTX_INPROC_SERVER | CLSCTX_LOCAL_SERVER | CLSCTX_REMOTE_SERVER

		attach_function :CoCreateInstance, [:pointer, :pointer, :ulong, :pointer, :pointer], :long

		module COM
			module Interface
				def self.[](*args)
					spec, iid, *ifaces = args.reverse

					spec.each { |name, signature| signature[0].unshift(:pointer) }

					Class.new(FFI::Struct) {
						const_set(:IID, iid)

						const_set(:VTBL, Class.new(FFI::Struct) {
							const_set(:SPEC, Hash[(ifaces.map { |iface| iface::VTBL::SPEC.to_a } << spec.to_a).flatten(1)])

							layout \
								*self::SPEC.map { |name, signature| [name, callback(*signature)] }.flatten
						})

						layout \
							:lpVtbl, :pointer
					}
				end
			end

			module Helpers
				def QueryInstance(klass)
					instance = nil

					FFI::MemoryPointer.new(:pointer) { |ppv|
						QueryInterface(klass::IID, ppv)

						instance = klass.new(ppv.read_pointer)
					}

					begin
						yield instance; return self
					ensure
						instance.Release
					end if block_given?

					instance
				end

				def UseInstance(klass, name, *args)
					instance = nil

					FFI::MemoryPointer.new(:pointer) { |ppv|
						send(name, *args, klass::IID, ppv)

						yield instance = klass.new(ppv.read_pointer)
					}

					self
				ensure
					instance.Release if instance
				end
			end

			module Instance
				def self.[](iface)
					Class.new(iface) {
						send(:include, Helpers)

						def initialize(pointer)
							self.pointer = pointer

							@vtbl = self.class::VTBL.new(self[:lpVtbl])
						end

						attr_reader :vtbl

						self::VTBL.members.each { |name|
							define_method(name) { |*args|
								raise "#{self}.#{name} failed." if Windows.FAILED(result = @vtbl[name].call(self, *args)); result
							}
						}
					}
				end
			end

			module Factory
				def self.[](iface, clsid)
					Class.new(iface) {
						send(:include, Helpers)

						const_set(:CLSID, clsid)

						def initialize(opts = {})
							@opts = opts

							@opts[:clsctx] ||= CLSCTX_INPROC_SERVER

							FFI::MemoryPointer.new(:pointer) { |ppv|
								raise "CoCreateInstance failed (#{self.class})." if
									Windows.FAILED(Windows.CoCreateInstance(self.class::CLSID, nil, @opts[:clsctx], self.class::IID, ppv))

								self.pointer = ppv.read_pointer
							}

							@vtbl = self.class::VTBL.new(self[:lpVtbl])
						end

						attr_reader :vtbl

						self::VTBL.members.each { |name|
							define_method(name) { |*args|
								raise "#{self}.#{name} failed." if Windows.FAILED(result = @vtbl[name].call(self, *args)); result
							}
						}
					}
				end
			end

			module Callback
				def self.[](iface)
					Class.new(iface) {
						send(:include, Helpers)

						def initialize(opts = {})
							@vtbl, @refc = self.class::VTBL.new, 1

							@vtbl.members.each { |name|
								@vtbl[name] = instance_variable_set("@fn#{name}",
									FFI::Function.new(*@vtbl.class::SPEC[name].reverse, convention: :stdcall) { |*args|
										send(name, *args[1..-1])
									}
								)
							}

							self[:lpVtbl] = @vtbl

							begin
								yield self
							ensure
								Release()
							end if block_given?
						end

						attr_reader :vtbl, :refc

						def QueryInterface(riid, ppv)
							if [IUnknown::IID, self.class::IID].any? { |iid| Windows.memcmp(riid, iid, iid.size) == 0 }
								ppv.write_pointer(self)
							else
								ppv.write_pointer(0); return E_NOINTERFACE
							end

							AddRef(); S_OK
						end

						def AddRef
							@refc += 1
						end

						def Release
							@refc -= 1
						end

						(self::VTBL.members - IUnknown::VTBL.members).each { |name|
							define_method(name) { |*args|
								E_NOTIMPL
							}
						}
					}
				end
			end
		end

		IUnknown = COM::Interface[
			GUID['00000000-0000-0000-C000-000000000046'],

			QueryInterface: [[:pointer, :pointer], :long],
			AddRef: [[], :ulong],
			Release: [[], :ulong]
		]

		Unknown = COM::Instance[IUnknown]

		IDispatch = COM::Interface[IUnknown,
			GUID['00020400-0000-0000-C000-000000000046'],

			GetTypeInfoCount: [[:pointer], :long],
			GetTypeInfo: [[:uint, :ulong, :pointer], :long],
			GetIDsOfNames: [[:pointer, :pointer, :uint, :ulong, :pointer], :long],
			Invoke: [[:long, :pointer, :ulong, :ushort, :pointer, :pointer, :pointer, :pointer], :long]
		]

		Dispatch = COM::Instance[IDispatch]
		DCallback = COM::Callback[IDispatch]

		IConnectionPointContainer = COM::Interface[IUnknown,
			GUID['B196B284-BAB4-101A-B69C-00AA00341D07'],

			EnumConnectionPoints: [[:pointer], :long],
			FindConnectionPoint: [[:pointer, :pointer], :long]
		]

		ConnectionPointContainer = COM::Instance[IConnectionPointContainer]

		IConnectionPoint = COM::Interface[IUnknown,
			GUID['B196B286-BAB4-101A-B69C-00AA00341D07'],

			GetConnectionInterface: [[:pointer], :long],
			GetConnectionPointContainer: [[:pointer], :long],
			Advise: [[:pointer, :pointer], :long],
			Unadvise: [[:ulong], :long],
			EnumConnections: [[:pointer], :long]
		]

		ConnectionPoint = COM::Instance[IConnectionPoint]

		IObjectWithSite = COM::Interface[IUnknown,
			GUID['FC4801A3-2BA9-11CF-A229-00AA003D7352'],

			SetSite: [[:pointer], :long],
			GetSite: [[:pointer, :pointer], :long]
		]

		ObjectWithSite = COM::Callback[IObjectWithSite]
	end
end
