require 'ffi'

module Fzeet
	module Windows
		extend FFI::Library

		ffi_lib 'kernel32'
		ffi_convention :stdcall

		INVALID_HANDLE_VALUE = FFI::Pointer.new(-1)
		INVALID_FILE_SIZE = 0xFFFFFFFF
		INVALID_SET_FILE_POINTER = 0xFFFFFFFF
		INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
		INVALID_ATOM = 0

		attach_function :GetLastError, [], :ulong
		attach_function :SetLastError, [:ulong], :void

		def Detonate(on, name, *args)
			raise "#{name} failed." if (failed = [*on].include?(result = send(name, *args)))

			result
		ensure
			yield failed if block_given?
		end

		def DetonateLastError(on, name, *args)
			raise "#{name} failed (last error #{GetLastError()})." if (failed = [*on].include?(result = send(name, *args)))

			result
		ensure
			yield failed if block_given?
		end

		module_function :Detonate, :DetonateLastError

		def LOBYTE(w) w & 0xff end
		def HIBYTE(w) (w >> 8) & 0xff end
		def MAKEWORD(low, high) (low & 0xff) | ((high & 0xff) << 8) end

		def LOWORD(l) l & 0xffff end
		def HIWORD(l) (l >> 16) & 0xffff end
		def MAKELONG(low, high) (low & 0xffff) | ((high & 0xffff) << 16) end

		def GET_X_LPARAM(l) ((w = LOWORD(l)) > 0x7fff) ? w - 0x1_0000 : w end
		def GET_Y_LPARAM(l) ((w = HIWORD(l)) > 0x7fff) ? w - 0x1_0000 : w end

		def LPWSTR(s)
			p = FFI::MemoryPointer.new(:uchar, (s.length + 2) * 2)

			"#{s}\0".encode('utf-16le').each_byte.with_index { |b, i| p.put_char(i, b) }

			begin
				yield p; return nil
			ensure
				p.free
			end if block_given?

			p
		end

		def WCSTOMBS(p)
			result = ''

			FFI::MemoryPointer.new(:uchar, len = wcslen(p) + 1) { |buf|
				raise 'wcstombs failed.' if wcstombs(buf, p, len) == 0xffffffff

				result << buf.read_string
			}

			result
		end

		module_function \
			:LOBYTE, :HIBYTE, :MAKEWORD,
			:LOWORD, :HIWORD, :MAKELONG,
			:GET_X_LPARAM, :GET_Y_LPARAM,
			:LPWSTR, :WCSTOMBS

		module AnonymousSupport
			def [](k)
				if members.include?(k)
					super
				elsif self[:_].members.include?(k)
					self[:_][k]
				else
					self[:_][:_][k]
				end
			end

			def []=(k, v)
				if members.include?(k)
					super
				elsif self[:_].members.include?(k)
					self[:_][k] = v
				else
					self[:_][:_][k] = v
				end
			end
		end

		class HANDLE
			@@instances = {}

			def self.instance?(handle) @@instances.include?(handle.to_i) end
			def self.instance(handle) raise "#{self}.#{__method__} failed." unless (instance = @@instances[handle.to_i]); instance end

			def self.wrap(handle, *ifaces)
				Object.new.tap { |o|
					o.instance_variable_set(:@handle, handle)
					o.class.send(:attr_reader, :handle)
					ifaces.each { |iface| o.class.send(:include, iface) }
				}
			end

			attr_reader :handle

			def attach; @@instances[@handle.to_i] = self end
			def detach; @@instances.delete(@handle.to_i) end

			def dup; raise "#{self}.#{__method__} is not implemented." end
		end
	end

	Handle = Windows::HANDLE

	module Toggle
		def toggle(what)
			send("#{what}=", !send("#{what}?"))

			begin
				yield self
			ensure
				toggle(what)
			end if block_given?

			self
		end
	end

	def constant(c, *prefixes)
		return c if c.kind_of?(Integer) || c.kind_of?(FFI::Pointer)

		c = c.upcase

		prefixes.map! { |prefix|
			prefix = prefix.upcase

			"#{prefix}#{c}".tap { |name|
				return Windows.const_get(name) if Windows.const_defined?(name)
			}
		}

		raise "Constant not found: #{c} (tried: #{prefixes.join(', ')})."
	end

	def flags(flags, *prefixes)
		return flags if flags.kind_of?(Integer)

		[*flags].inject(0) { |flags, flag| flags |= constant(flag, *prefixes) }
	end

	module_function :constant, :flags

	def using(o, cleanup = :dispose)
		yield o
	ensure
		o.send(cleanup)
	end

	module_function :using

	module IconMethods

	end

	class SystemIcon < Handle
		include IconMethods

		def initialize(id)
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :LoadIcon, nil, @id = Fzeet.constant(id, :idi_)); attach
		end

		attr_reader :id

		def dispose; detach end
	end

	module CursorMethods

	end

	class SystemCursor < Handle
		include CursorMethods

		def initialize(id)
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :LoadCursor, nil, @id = Fzeet.constant(id, :idc_)); attach
		end

		attr_reader :id

		def dispose; detach end
	end

	module BrushMethods

	end

	class SystemBrush < Handle
		include BrushMethods

		def initialize(id)
			@handle = FFI::Pointer.new((@id = Fzeet.constant(id, :color_, :ctlcolor_)) + 1); attach
		end

		attr_reader :id

		def dispose; detach end
	end

	module FontMethods

	end

	class IndirectFont < Handle
		include FontMethods

		def initialize(logfont)
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :CreateFontIndirect, @logfont = logfont); attach
		end

		attr_reader :logfont

		def dispose; Windows.DeleteObject(@handle); detach end
	end

	module BitmapMethods

	end

	class PARGB32 < Handle
		include BitmapMethods

		def initialize(path, width = 0, height = 0)
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :LoadImage,
				nil,
				@path = path,
				Windows::IMAGE_BITMAP,
				width,
				height,
				Windows::LR_LOADFROMFILE | Windows::LR_CREATEDIBSECTION
			)

			attach
		end

		attr_reader :path

		def dispose; Windows.DeleteObject(@handle); detach end
	end

	module DCMethods
		def select(*objects)
			holds = []

			objects.each { |object|
				holds << Windows.DetonateLastError(FFI::Pointer::NULL, :SelectObject, @handle, object.handle)
			}

			yield self

			self
		ensure
			holds.each { |hold| Windows.SelectObject(@handle, hold) }
		end

		def textExtent(text) Windows.DetonateLastError(0, :GetTextExtentPoint, @handle, text, text.length, s = Size.new); s end

		def color; Windows.GetTextColor(@handle) end
		def color=(color) Windows.SetTextColor(@handle, color) end

		def background; Windows.GetBkColor(@handle) end
		def background=(background) Windows.SetBkColor(@handle, background) end

		def fillRect(rect, brush) Windows.DetonateLastError(0, :FillRect, @handle, rect, (brush.kind_of?(FFI::Pointer)) ? brush : brush.handle); self end

		def text(text, rect, flags = 0) Windows.DetonateLastError(0, :DrawText, @handle, text, -1, rect, Fzeet.flags(flags, :dt_)); self end

		def sms(message)
			r = window.rect

			r[:top] += window.ribbon.height if window.ribbon

			text(message, r, [:singleline, :center, :vcenter])

			self
		end

		def move(x, y) Windows.DetonateLastError(0, :MoveToEx, @handle, x, y, nil); self end
		def line(x, y) Windows.DetonateLastError(0, :LineTo, @handle, x, y); self end
	end

	class ClientDC < Handle
		include DCMethods

		def initialize(window)
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :GetDC, (@window = window).handle); attach
		end

		attr_reader :window

		def dispose; Windows.ReleaseDC(@window.handle, @handle); detach end
	end

	class ScreenDC < Handle
		include DCMethods

		def initialize
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :GetDC, nil); attach
		end

		def dispose; Windows.ReleaseDC(nil, @handle); detach end
	end
end
