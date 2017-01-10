require_relative '../Common'

module Fzeet
	module WindowMethods
		include Toggle

		def message(message, opts = {})
			opts[:window] ||= self
			opts[:caption] ||= text

			Fzeet.message(message, opts)
		end

		def question(message, opts = {})
			opts[:window] ||= self
			opts[:caption] ||= text

			Fzeet.question(message, opts)
		end

		def sendmsg(msg, wParam = 0, lParam = 0)
			Windows.SendMessage(
				@handle,
				Fzeet.constant(msg, *self.class::Prefix[:message]),
				wParam.to_i,
				((lparam = lParam.to_i) > 0x7fff_ffff) ? lparam - 0x1_0000_0000 : lparam
			)
		end

		def postmsg(msg, wParam = 0, lParam = 0)
			Windows.DetonateLastError(0, :PostMessage,
				@handle,
				Fzeet.constant(msg, *self.class::Prefix[:message]),
				wParam.to_i,
				((lparam = lParam.to_i) > 0x7fff_ffff) ? lparam - 0x1_0000_0000 : lparam
			)

			self
		end

		def dialog?; Application.dialogs.include?(self) end

		def dialog=(dialog)
			if dialog
				Application.dialogs << self unless dialog?
			else
				Application.dialogs.delete(self)
			end
		end

		def dlgmsg?(msg) Windows.IsDialogMessage(@handle, msg) != 0 end

		class Long
			def initialize(window) @window = window end

			def [](c)
				Windows.SetLastError(0)

				Windows.GetWindowLong(@window.handle, Fzeet.constant(c, :gwl_, :gwlp_, :dwl_)).tap { |result|
					raise 'GetWindowLong failed.' if result == 0 && Windows.GetLastError() != 0
				}
			end

			def []=(c, l)
				Windows.SetLastError(0)

				Windows.SetWindowLong(@window.handle, Fzeet.constant(c, :gwl_, :gwlp_, :dwl_), l).tap { |result|
					raise 'SetWindowLong failed.' if result == 0 && Windows.GetLastError() != 0
				}
			end
		end

		def long; Long.new(self) end

		class Style
			def initialize(window) @window = window end

			def <<(style) @window.long[:style] = @window.long[:style] | Fzeet.constant(style, *@window.class::Prefix[:style]); self end
			def >>(style) @window.long[:style] = @window.long[:style] & ~Fzeet.constant(style, *@window.class::Prefix[:style]); self end

			def toggle(what) send((@window.style?(what)) ? :>> : :<<, what); self end
		end

		class ExStyle
			def initialize(window) @window = window end

			def <<(xstyle) @window.long[:exstyle] = @window.long[:exstyle] | Fzeet.constant(xstyle, *@window.class::Prefix[:xstyle]); self end
			def >>(xstyle) @window.long[:exstyle] = @window.long[:exstyle] & ~Fzeet.constant(xstyle, *@window.class::Prefix[:xstyle]); self end

			def toggle(what) send((@window.xstyle?(what)) ? :>> : :<<, what); self end
		end

		def style?(style) (long[:style] & (style = Fzeet.constant(style, *self.class::Prefix[:style]))) == style end
		def style; Style.new(self) end

		def xstyle?(xstyle) (long[:exstyle] & (xstyle = Fzeet.constant(xstyle, *self.class::Prefix[:xstyle]))) == xstyle end
		def xstyle; ExStyle.new(self) end

		def topmost?; xstyle?(:topmost) end

		def topmost=(topmost)
			Windows.DetonateLastError(0, :SetWindowPos,
				@handle,
				(topmost) ? Windows::HWND_TOPMOST : Windows::HWND_NOTOPMOST,
				0, 0, 0, 0,
				Windows::SWP_NOMOVE | Windows::SWP_NOSIZE
			)
		end

		def enabled?; Windows.IsWindowEnabled(@handle) != 0 end
		def enabled=(enabled) Windows.EnableWindow(@handle, (enabled) ? 1 : 0) end

		def visible?; Windows.IsWindowVisible(@handle) != 0 end
		def visible=(visible) show((visible) ? Windows::SW_SHOWNORMAL : Windows::SW_HIDE) end

		def show(cmdShow = :shownormal) Windows.ShowWindow(@handle, Fzeet.constant(cmdShow, :sw_)); self end

		def update; Windows.DetonateLastError(0, :UpdateWindow, @handle); self end

		def focus?; Windows.GetFocus().to_i == @handle.to_i end
		def focus=(focus) Windows.DetonateLastError(FFI::Pointer::NULL, :SetFocus, (focus) ? @handle : nil) end

		def textlen; Windows.GetWindowTextLength(@handle) end

		def text
			return '' if (len = textlen + 1) == 1

			''.tap { |text|
				FFI::MemoryPointer.new(:char, len) { |buf|
					Windows.DetonateLastError(0, :GetWindowText, @handle, buf, len)

					text << buf.read_string
				}
			}
		end

		def text=(text) Windows.DetonateLastError(0, :SetWindowText, @handle, text.to_s) end

		def rect; Windows.DetonateLastError(0, :GetClientRect, @handle, r = Rect.new); r end

		def position; Windows.DetonateLastError(0, :GetWindowRect, @handle, r = Rect.new); r end
		def position=(a) Windows.DetonateLastError(0, :SetWindowPos, @handle, nil, a[0], a[1], a[2], a[3], Fzeet.constant(:nozorder, :swp_)) end

		def location; position.lt end
		def location=(a) Windows.DetonateLastError(0, :SetWindowPos, @handle, nil, a[0], a[1], 0, 0, Fzeet.flags([:nosize, :nozorder], :swp_)) end

		def size; r = position; Size[r[:right] - r[:left], r[:bottom] - r[:top]] end
		def size=(a) Windows.DetonateLastError(0, :SetWindowPos, @handle, nil, 0, 0, a[0], a[1], Fzeet.flags([:nomove, :nozorder], :swp_)) end

		def reframe
			Windows.DetonateLastError(0, :SetWindowPos,
				@handle,
				nil,
				0, 0, 0, 0,
				Fzeet.flags([:nomove, :nosize, :nozorder, :framechanged], :swp_)
			)

			self
		end

		def capture?; Windows.GetCapture().to_i == @handle.to_i end
		def capture=(capture) (capture) ? Windows.SetCapture(@handle) : Windows.DetonateLastError(0, :ReleaseCapture) end

		def paint
			hdc = Windows.DetonateLastError(FFI::Pointer::NULL, :BeginPaint, @handle, ps = Windows::PAINTSTRUCT.new)

			begin
				dc = Handle.wrap(hdc, DCMethods)

				dc.instance_variable_set(:@window, self)

				class << dc
					attr_reader :window
				end

				yield dc, ps
			ensure
				Windows.EndPaint(@handle, ps)
			end

			self
		end

		def invalidate(rect = rect, erase = 1) Windows.DetonateLastError(0, :InvalidateRect, @handle, rect, erase); self end

		def menu; (Handle.instance?(handle = Windows.GetMenu(@handle))) ? Handle.instance(handle) : nil end

		def menu=(menu)
			self.menu.dispose if self.menu

			Windows.DetonateLastError(0, :SetMenu, @handle, menu.handle) if menu
		end

		def drawMenuBar; Windows.DetonateLastError(0, :DrawMenuBar, @handle); self end

		def [](id) Handle.instance(Windows.DetonateLastError(FFI::Pointer::NULL, :GetDlgItem, @handle, Command[id])) end

		EnumChildProc = FFI::Function.new(:int, [:pointer, :long], convention: :stdcall) { |hwnd, lParam|
			ObjectSpace._id2ref(lParam).call(Handle.instance(hwnd)) if Handle.instance?(hwnd); 1
		}

		def eachChild(&block) Windows.EnumChildWindows(@handle, EnumChildProc, block.object_id); self end
	end
end
