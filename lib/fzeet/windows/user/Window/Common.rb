if __FILE__ == $0
	require 'ffi'

	# FIXME: dirty fix to propagate FFI structs layout down the inheritance hierarchy
	# TODO: switch to composition instead inheriting FFI structs
	module PropagateFFIStructLayout
		def inherited(child_class)
			child_class.instance_variable_set '@layout', layout
		end
	end

	class FFI::Struct
		def self.inherited(child_class)
			child_class.extend PropagateFFIStructLayout
		end
	end
	# END FIXME
end

require_relative 'WindowMethods'

module Fzeet
	module Windows
		CS_VREDRAW = 0x0001
		CS_HREDRAW = 0x0002
		CS_DBLCLKS = 0x0008
		CS_OWNDC = 0x0020
		CS_CLASSDC = 0x0040
		CS_PARENTDC = 0x0080
		CS_NOCLOSE = 0x0200
		CS_SAVEBITS = 0x0800
		CS_BYTEALIGNCLIENT = 0x1000
		CS_BYTEALIGNWINDOW = 0x2000
		CS_GLOBALCLASS = 0x4000
		CS_IME = 0x00010000
		CS_DROPSHADOW = 0x00020000

		callback :WNDPROC, [:pointer, :uint, :uint, :long], :long

		attach_function :DefWindowProc, :DefWindowProcA, [:pointer, :uint, :uint, :long], :long
		attach_function :DefFrameProc, :DefFrameProcA, [:pointer, :pointer, :uint, :uint, :long], :long
		attach_function :DefMDIChildProc, :DefMDIChildProcA, [:pointer, :uint, :uint, :long], :long

		callback :DLGPROC, [:pointer, :uint, :uint, :long], :int

		attach_function :DefDlgProc, :DefDlgProcA, [:pointer, :uint, :uint, :long], :long

		IDI_APPLICATION = FFI::Pointer.new(32512)
		IDI_HAND = FFI::Pointer.new(32513)
		IDI_QUESTION = FFI::Pointer.new(32514)
		IDI_EXCLAMATION = FFI::Pointer.new(32515)
		IDI_ASTERISK = FFI::Pointer.new(32516)
		IDI_WINLOGO = FFI::Pointer.new(32517)
		IDI_SHIELD = FFI::Pointer.new(32518)
		IDI_WARNING = IDI_EXCLAMATION
		IDI_ERROR = IDI_HAND
		IDI_INFORMATION = IDI_ASTERISK

		attach_function :LoadIcon, :LoadIconA, [:pointer, :pointer], :pointer

		IDC_ARROW = FFI::Pointer.new(32512)
		IDC_IBEAM = FFI::Pointer.new(32513)
		IDC_WAIT = FFI::Pointer.new(32514)
		IDC_CROSS = FFI::Pointer.new(32515)
		IDC_UPARROW = FFI::Pointer.new(32516)
		IDC_SIZE = FFI::Pointer.new(32640)
		IDC_ICON = FFI::Pointer.new(32641)
		IDC_SIZENWSE = FFI::Pointer.new(32642)
		IDC_SIZENESW = FFI::Pointer.new(32643)
		IDC_SIZEWE = FFI::Pointer.new(32644)
		IDC_SIZENS = FFI::Pointer.new(32645)
		IDC_SIZEALL = FFI::Pointer.new(32646)
		IDC_NO = FFI::Pointer.new(32648)
		IDC_HAND = FFI::Pointer.new(32649)
		IDC_APPSTARTING = FFI::Pointer.new(32650)
		IDC_HELP = FFI::Pointer.new(32651)

		attach_function :LoadCursor, :LoadCursorA, [:pointer, :pointer], :pointer

		COLOR_SCROLLBAR = 0
		COLOR_BACKGROUND = 1
		COLOR_ACTIVECAPTION = 2
		COLOR_INACTIVECAPTION = 3
		COLOR_MENU = 4
		COLOR_WINDOW = 5
		COLOR_WINDOWFRAME = 6
		COLOR_MENUTEXT = 7
		COLOR_WINDOWTEXT = 8
		COLOR_CAPTIONTEXT = 9
		COLOR_ACTIVEBORDER = 10
		COLOR_INACTIVEBORDER = 11
		COLOR_APPWORKSPACE = 12
		COLOR_HIGHLIGHT = 13
		COLOR_HIGHLIGHTTEXT = 14
		COLOR_BTNFACE = 15
		COLOR_BTNSHADOW = 16
		COLOR_GRAYTEXT = 17
		COLOR_BTNTEXT = 18
		COLOR_INACTIVECAPTIONTEXT = 19
		COLOR_BTNHIGHLIGHT = 20
		COLOR_3DDKSHADOW = 21
		COLOR_3DLIGHT = 22
		COLOR_INFOTEXT = 23
		COLOR_INFOBK = 24
		COLOR_HOTLIGHT = 26
		COLOR_GRADIENTACTIVECAPTION = 27
		COLOR_GRADIENTINACTIVECAPTION = 28
		COLOR_MENUHILIGHT = 29
		COLOR_MENUBAR = 30
		COLOR_DESKTOP = COLOR_BACKGROUND
		COLOR_3DFACE = COLOR_BTNFACE
		COLOR_3DSHADOW = COLOR_BTNSHADOW
		COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT
		COLOR_3DHILIGHT = COLOR_BTNHIGHLIGHT
		COLOR_BTNHILIGHT = COLOR_BTNHIGHLIGHT

		CTLCOLOR_MSGBOX = 0
		CTLCOLOR_EDIT = 1
		CTLCOLOR_LISTBOX = 2
		CTLCOLOR_BTN = 3
		CTLCOLOR_DLG = 4
		CTLCOLOR_SCROLLBAR = 5
		CTLCOLOR_STATIC = 6
		CTLCOLOR_MAX = 7

		class WNDCLASSEX < FFI::Struct
			layout \
				:cbSize, :uint,
				:style, :uint,
				:lpfnWndProc, :WNDPROC,
				:cbClsExtra, :int,
				:cbWndExtra, :int,
				:hInstance, :pointer,
				:hIcon, :pointer,
				:hCursor, :pointer,
				:hbrBackground, :pointer,
				:lpszMenuName, :pointer,
				:lpszClassName, :pointer,
				:hIconSm, :pointer
		end

		attach_function :RegisterClassEx, :RegisterClassExA, [:pointer], :ushort

		GCL_MENUNAME = -8
		GCL_HBRBACKGROUND = -10
		GCL_HCURSOR = -12
		GCL_HICON = -14
		GCL_HMODULE = -16
		GCL_CBWNDEXTRA = -18
		GCL_CBCLSEXTRA = -20
		GCL_WNDPROC = -24
		GCL_STYLE = -26
		GCL_HICONSM = -34

		GCLP_MENUNAME = -8
		GCLP_HBRBACKGROUND = -10
		GCLP_HCURSOR = -12
		GCLP_HICON = -14
		GCLP_HMODULE = -16
		GCLP_WNDPROC = -24
		GCLP_HICONSM = -34

		attach_function :GetClassLong, :GetClassLongA, [:pointer, :int], :ulong
		attach_function :SetClassLong, :SetClassLongA, [:pointer, :int, :long], :ulong

		HWND_BROADCAST = FFI::Pointer.new(0xffff)
		HWND_MESSAGE = FFI::Pointer.new(-3)
		HWND_DESKTOP = FFI::Pointer.new(0)
		HWND_TOP = FFI::Pointer.new(0)
		HWND_BOTTOM = FFI::Pointer.new(1)
		HWND_TOPMOST = FFI::Pointer.new(-1)
		HWND_NOTOPMOST = FFI::Pointer.new(-2)

		WS_OVERLAPPED = 0x00000000
		WS_POPUP = 0x80000000
		WS_CHILD = 0x40000000
		WS_MINIMIZE = 0x20000000
		WS_VISIBLE = 0x10000000
		WS_DISABLED = 0x08000000
		WS_CLIPSIBLINGS = 0x04000000
		WS_CLIPCHILDREN = 0x02000000
		WS_MAXIMIZE = 0x01000000
		WS_CAPTION = 0x00C00000
		WS_BORDER = 0x00800000
		WS_DLGFRAME = 0x00400000
		WS_VSCROLL = 0x00200000
		WS_HSCROLL = 0x00100000
		WS_SYSMENU = 0x00080000
		WS_THICKFRAME = 0x00040000
		WS_GROUP = 0x00020000
		WS_TABSTOP = 0x00010000
		WS_MINIMIZEBOX = 0x00020000
		WS_MAXIMIZEBOX = 0x00010000
		WS_TILED = WS_OVERLAPPED
		WS_ICONIC = WS_MINIMIZE
		WS_SIZEBOX = WS_THICKFRAME
		WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX
		WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW
		WS_POPUPWINDOW = WS_POPUP | WS_BORDER | WS_SYSMENU
		WS_CHILDWINDOW = WS_CHILD
		WS_ACTIVECAPTION = 0x0001

		WS_EX_DLGMODALFRAME = 0x00000001
		WS_EX_NOPARENTNOTIFY = 0x00000004
		WS_EX_TOPMOST = 0x00000008
		WS_EX_ACCEPTFILES = 0x00000010
		WS_EX_TRANSPARENT = 0x00000020
		WS_EX_MDICHILD = 0x00000040
		WS_EX_TOOLWINDOW = 0x00000080
		WS_EX_WINDOWEDGE = 0x00000100
		WS_EX_CLIENTEDGE = 0x00000200
		WS_EX_CONTEXTHELP = 0x00000400
		WS_EX_RIGHT = 0x00001000
		WS_EX_LEFT = 0x00000000
		WS_EX_RTLREADING = 0x00002000
		WS_EX_LTRREADING = 0x00000000
		WS_EX_LEFTSCROLLBAR = 0x00004000
		WS_EX_RIGHTSCROLLBAR = 0x00000000
		WS_EX_CONTROLPARENT = 0x00010000
		WS_EX_STATICEDGE = 0x00020000
		WS_EX_APPWINDOW = 0x00040000
		WS_EX_OVERLAPPEDWINDOW = WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE
		WS_EX_PALETTEWINDOW = WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST
		WS_EX_LAYERED = 0x00080000
		WS_EX_NOINHERITLAYOUT = 0x00100000
		WS_EX_LAYOUTRTL = 0x00400000
		WS_EX_COMPOSITED = 0x02000000
		WS_EX_NOACTIVATE = 0x08000000

		CW_USEDEFAULT = -0x80000000

		class CREATESTRUCT < FFI::Struct
			layout \
				:lpCreateParams, :pointer,
				:hInstance, :pointer,
				:hMenu, :pointer,
				:hwndParent, :pointer,
				:cy, :int,
				:cx, :int,
				:y, :int,
				:x, :int,
				:style, :long,
				:lpszName, :pointer,
				:lpszClass, :pointer,
				:dwExStyle, :ulong
		end

		attach_function :CreateWindowEx, :CreateWindowExA, [:ulong, :string, :string, :ulong, :int, :int, :int, :int, :pointer, :pointer, :pointer, :pointer], :pointer
		attach_function :DestroyWindow, [:pointer], :int

		MDIS_ALLCHILDSTYLES = 0x0001

		class MDICREATESTRUCT < FFI::Struct
			layout \
				:szClass, :pointer,
				:szTitle, :pointer,
				:hOwner, :pointer,
				:x, :int,
				:y, :int,
				:cx, :int,
				:cy, :int,
				:style, :ulong,
				:lParam, :long
		end

		class CLIENTCREATESTRUCT < FFI::Struct
			layout \
				:hWindowMenu, :pointer,
				:idFirstChild, :uint
		end

		attach_function :CreateMDIWindow, :CreateMDIWindowA, [:string, :string, :ulong, :int, :int, :int, :int, :pointer, :pointer, :long], :pointer

		DS_ABSALIGN = 0x01
		DS_SYSMODAL = 0x02
		DS_LOCALEDIT = 0x20
		DS_SETFONT = 0x40
		DS_MODALFRAME = 0x80
		DS_NOIDLEMSG = 0x100
		DS_SETFOREGROUND = 0x200
		DS_3DLOOK = 0x0004
		DS_FIXEDSYS = 0x0008
		DS_NOFAILCREATE = 0x0010
		DS_CONTROL = 0x0400
		DS_CENTER = 0x0800
		DS_CENTERMOUSE = 0x1000
		DS_CONTEXTHELP = 0x2000
		DS_SHELLFONT = DS_SETFONT | DS_FIXEDSYS

		class DLGTEMPLATE < FFI::Struct
			layout \
				:style, :ulong,
				:dwExtendedStyle, :ulong,
				:cdit, :ushort,
				:x, :short,
				:y, :short,
				:cx, :short,
				:cy, :short,
				:menu, :ushort,
				:windowClass, :ushort,
				:title, :ushort
		end

		attach_function :CreateDialogIndirectParam, :CreateDialogIndirectParamA, [:pointer, :pointer, :pointer, :DLGPROC, :long], :pointer
		attach_function :DialogBoxIndirectParam, :DialogBoxIndirectParamA, [:pointer, :pointer, :pointer, :DLGPROC, :long], :int
		attach_function :EndDialog, [:pointer, :int], :int

		GWL_WNDPROC = -4
		GWL_HINSTANCE = -6
		GWL_HWNDPARENT = -8
		GWL_STYLE = -16
		GWL_EXSTYLE = -20
		GWL_USERDATA = -21
		GWL_ID = -12

		GWLP_WNDPROC = -4
		GWLP_HINSTANCE = -6
		GWLP_HWNDPARENT = -8
		GWLP_USERDATA = -21
		GWLP_ID = -12

		DWL_MSGRESULT = 0
		DWL_DLGPROC = 4
		DWL_USER = 8

		attach_function :GetWindowLong, :GetWindowLongA, [:pointer, :int], :long
		attach_function :SetWindowLong, :SetWindowLongA, [:pointer, :int, :long], :long

		attach_function :IsWindowEnabled, [:pointer], :int
		attach_function :EnableWindow, [:pointer, :int], :int

		attach_function :IsWindowVisible, [:pointer], :int

		SW_HIDE = 0
		SW_SHOWNORMAL = 1
		SW_NORMAL = 1
		SW_SHOWMINIMIZED = 2
		SW_SHOWMAXIMIZED = 3
		SW_MAXIMIZE = 3
		SW_SHOWNOACTIVATE = 4
		SW_SHOW = 5
		SW_MINIMIZE = 6
		SW_SHOWMINNOACTIVE = 7
		SW_SHOWNA = 8
		SW_RESTORE = 9
		SW_SHOWDEFAULT = 10
		SW_FORCEMINIMIZE = 11
		SW_MAX = 11
		SW_PARENTCLOSING = 1
		SW_OTHERZOOM = 2
		SW_PARENTOPENING = 3
		SW_OTHERUNZOOM = 4
		SW_SCROLLCHILDREN = 0x0001
		SW_INVALIDATE = 0x0002
		SW_ERASE = 0x0004
		SW_SMOOTHSCROLL = 0x0010

		attach_function :ShowWindow, [:pointer, :int], :int

		attach_function :UpdateWindow, [:pointer], :int

		attach_function :GetFocus, [], :pointer
		attach_function :SetFocus, [:pointer], :pointer

		attach_function :GetWindowTextLength, :GetWindowTextLengthA, [:pointer], :int
		attach_function :GetWindowText, :GetWindowTextA, [:pointer, :pointer, :int], :int
		attach_function :SetWindowText, :SetWindowTextA, [:pointer, :string], :int

		attach_function :GetClientRect, [:pointer, :pointer], :int
		attach_function :GetWindowRect, [:pointer, :pointer], :int

		SWP_NOSIZE = 0x0001
		SWP_NOMOVE = 0x0002
		SWP_NOZORDER = 0x0004
		SWP_NOREDRAW = 0x0008
		SWP_NOACTIVATE = 0x0010
		SWP_FRAMECHANGED = 0x0020
		SWP_SHOWWINDOW = 0x0040
		SWP_HIDEWINDOW = 0x0080
		SWP_NOCOPYBITS = 0x0100
		SWP_NOOWNERZORDER = 0x0200
		SWP_NOSENDCHANGING = 0x0400
		SWP_DRAWFRAME = SWP_FRAMECHANGED
		SWP_NOREPOSITION = SWP_NOOWNERZORDER
		SWP_DEFERERASE = 0x2000
		SWP_ASYNCWINDOWPOS = 0x4000

		attach_function :SetWindowPos, [:pointer, :pointer, :int, :int, :int, :int, :uint], :int

		attach_function :BeginDeferWindowPos, [:int], :pointer
		attach_function :DeferWindowPos, [:pointer, :pointer, :pointer, :int, :int, :int, :int, :uint], :pointer
		attach_function :EndDeferWindowPos, [:pointer], :int

		MDITILE_VERTICAL = 0x0000
		MDITILE_HORIZONTAL = 0x0001
		MDITILE_SKIPDISABLED = 0x0002
		MDITILE_ZORDER = 0x0004

		attach_function :TileWindows, [:pointer, :uint, :pointer, :uint, :pointer], :ushort

		attach_function :CascadeWindows, [:pointer, :uint, :pointer, :uint, :pointer], :ushort
		attach_function :ArrangeIconicWindows, [:pointer], :uint

		attach_function :GetCursorPos, [:pointer], :int

		attach_function :ScreenToClient, [:pointer, :pointer], :int
		attach_function :ClientToScreen, [:pointer, :pointer], :int

		attach_function :GetCapture, [], :pointer
		attach_function :SetCapture, [:pointer], :pointer
		attach_function :ReleaseCapture, [], :int

		attach_function :GetDC, [:pointer], :pointer
		attach_function :ReleaseDC, [:pointer, :pointer], :int

		class PAINTSTRUCT < FFI::Struct
			layout \
				:hdc, :pointer,
				:fErase, :int,
				:rcPaint, RECT,
				:fRestore, :int,
				:fIncUpdate, :int,
				:rgbReserved, [:uchar, 32]
		end

		attach_function :BeginPaint, [:pointer, :pointer], :pointer
		attach_function :EndPaint, [:pointer, :pointer], :int

		attach_function :InvalidateRect, [:pointer, :pointer, :int], :int

		attach_function :FillRect, [:pointer, :pointer, :pointer], :int

		DT_TOP = 0x00000000
		DT_LEFT = 0x00000000
		DT_CENTER = 0x00000001
		DT_RIGHT = 0x00000002
		DT_VCENTER = 0x00000004
		DT_BOTTOM = 0x00000008
		DT_WORDBREAK = 0x00000010
		DT_SINGLELINE = 0x00000020
		DT_EXPANDTABS = 0x00000040
		DT_TABSTOP = 0x00000080
		DT_NOCLIP = 0x00000100
		DT_EXTERNALLEADING = 0x00000200
		DT_CALCRECT = 0x00000400
		DT_NOPREFIX = 0x00000800
		DT_INTERNAL = 0x00001000
		DT_EDITCONTROL = 0x00002000
		DT_PATH_ELLIPSIS = 0x00004000
		DT_END_ELLIPSIS = 0x00008000
		DT_MODIFYSTRING = 0x00010000
		DT_RTLREADING = 0x00020000
		DT_WORD_ELLIPSIS = 0x00040000
		DT_NOFULLWIDTHCHARBREAK = 0x00080000
		DT_HIDEPREFIX = 0x00100000
		DT_PREFIXONLY = 0x00200000

		attach_function :DrawText, :DrawTextA, [:pointer, :string, :int, :pointer, :uint], :int

		attach_function :GetMenu, [:pointer], :pointer
		attach_function :SetMenu, [:pointer, :pointer], :int

		attach_function :DrawMenuBar, [:pointer], :int

		attach_function :GetDlgItem, [:pointer, :int], :pointer

		GW_HWNDFIRST = 0
		GW_HWNDLAST = 1
		GW_HWNDNEXT = 2
		GW_HWNDPREV = 3
		GW_OWNER = 4
		GW_CHILD = 5
		GW_ENABLEDPOPUP = 6
		GW_MAX = 6

		attach_function :GetWindow, [:pointer, :uint], :pointer

		callback :WNDENUMPROC, [:pointer, :long], :int

		attach_function :EnumChildWindows, [:pointer, :WNDENUMPROC, :long], :int
	end

	class WindowClass < Windows::WNDCLASSEX
		def initialize(prototype, name, opts = {})
			@prototype = prototype
			@name = name
			className = FFI::MemoryPointer.from_string(@name)

			_opts = {
				style: [],
				wndProc: BasicWindow::WindowProc,
				clsExtra: 0,
				wndExtra: 0,
				icon: SystemIcon.new(:application),
				cursor: SystemCursor.new(:arrow),
				background: SystemBrush.new(:window),
				iconSm: nil
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?

			self[:cbSize] = Windows::WNDCLASSEX.size
			self[:hInstance] = Windows.GetModuleHandle(nil)
			self[:lpszClassName] = className

			if @prototype
				self[:style] = Fzeet.flags(opts[:style] || [], :cs_) | @prototype[:style]
				self[:lpfnWndProc] = opts[:wndProc] || @prototype[:lpfnWndProc]
				self[:cbClsExtra] = (opts[:clsExtra] || 0) + @prototype[:cbClsExtra]
				self[:cbWndExtra] = (opts[:wndExtra] || 0) + @prototype[:cbWndExtra]
				self[:hIcon] = (opts[:icon] && opts[:icon].handle) || @prototype[:hIcon]
				self[:hCursor] = (opts[:cursor] && opts[:cursor].handle) || @prototype[:hCursor]
				self[:hbrBackground] = (opts[:background] && opts[:background].handle) || @prototype[:hbrBackground]
				self[:hIconSm] = (opts[:iconSm] && _opts[:iconSm].handle) || @prototype[:hIconSm]
			else
				_opts.merge(opts)

				self[:style] = Fzeet.flags(_opts[:style], :cs_)
				self[:lpfnWndProc] = _opts[:wndProc]
				self[:cbClsExtra] = _opts[:clsExtra]
				self[:cbWndExtra] = _opts[:wndExtra]
				self[:hIcon] = _opts[:icon].handle
				self[:hCursor] = _opts[:cursor].handle
				self[:hbrBackground] = _opts[:background].handle
				self[:hIconSm] = _opts[:iconSm] && _opts[:iconSm].handle
			end

			Windows.DetonateLastError(0, :RegisterClassEx, self) { className.free }
		end

		attr_reader :prototype, :name
	end

	class BasicWindow < Handle
		include WindowMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:ws_, :ds_],
			message: [:wm_],
			notification: []
		}

		WindowProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
			begin
				if uMsg == Windows::WM_NCCREATE
					@@instances[hwnd.to_i] = ObjectSpace._id2ref(
						Windows::CREATESTRUCT.new(FFI::Pointer.new(lParam))[:lpCreateParams].to_i
					)

					@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
				end

				result = @@instances[hwnd.to_i].windowProc(hwnd, uMsg, wParam, lParam) if @@instances[hwnd.to_i]
			rescue
				answer = Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, buttons: [:abort, :retry, :ignore], icon: :error

				Application.quit if answer.abort?
			ensure
				if uMsg == Windows::WM_NCDESTROY
					@@instances[hwnd.to_i].dialog = false

					@@instances.delete(hwnd.to_i)
				end
			end

			result || Windows.DefWindowProc(hwnd, uMsg, wParam, lParam)
		}

		FrameProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
			begin
				if uMsg == Windows::WM_NCCREATE
					@@instances[hwnd.to_i] = ObjectSpace._id2ref(
						Windows::CREATESTRUCT.new(FFI::Pointer.new(lParam))[:lpCreateParams].to_i
					)

					@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
				end

				if uMsg == Windows::WM_CREATE
					@@instances[hwnd.to_i].menu = Menu.new.
						append(:popup, '&Windows', PopupMenu.new.
							append(:string, 'Tile &Horizontal', :tileHorz).
							append(:string, 'Tile &Vertical', :tileVert).
							append(:string, '&Cascade', :cascade).
							append(:string, 'Arrange &Icons', :arrangeIcons)
						)

					ccs = Windows::CLIENTCREATESTRUCT.new

					ccs[:hWindowMenu] = @@instances[hwnd.to_i].menu.submenus[0].handle
					ccs[:idFirstChild] = 50000

					hwndClient = Windows.DetonateLastError(FFI::Pointer::NULL, :CreateWindowEx,
						0, 'MDIClient', nil, Fzeet.flags([:child, :clipsiblings, :clipchildren, :visible], :ws_),
						0, 0, 0, 0,
						hwnd, nil, Windows.GetModuleHandle(nil), ccs
					)

					@@instances[hwnd.to_i].instance_variable_set(:@client, Handle.wrap(hwndClient, WindowMethods))

					@@instances[hwnd.to_i].
						on(:command, :tileHorz) { Windows.TileWindows(hwndClient, Windows::MDITILE_HORIZONTAL, nil, 0, nil) }.
						on(:command, :tileVert) { Windows.TileWindows(hwndClient, Windows::MDITILE_VERTICAL, nil, 0, nil) }.
						on(:command, :cascade) { Windows.CascadeWindows(hwndClient, Windows::MDITILE_ZORDER, nil, 0, nil) }.
						on(:command, :arrangeIcons) { Windows.ArrangeIconicWindows(hwndClient) }.

						on(:initmenupopup) { |args|
							[:tileHorz, :tileVert, :cascade, :arrangeIcons].each { |command|
								@@instances[hwnd.to_i].menu[command].enabled = !Windows.GetWindow(hwndClient, Windows::GW_CHILD).null?
							}
						}
				end

				result = @@instances[hwnd.to_i].windowProc(hwnd, uMsg, wParam, lParam) if @@instances[hwnd.to_i]
			rescue
				answer = Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, buttons: [:abort, :retry, :ignore], icon: :error

				Application.quit if answer.abort?
			ensure
				if uMsg == Windows::WM_NCDESTROY
					@@instances[hwnd.to_i].dialog = false

					@@instances.delete(hwnd.to_i)
				end
			end

			hwndClient = @@instances[hwnd.to_i] && @@instances[hwnd.to_i].client && @@instances[hwnd.to_i].client.handle

			result || Windows.DefFrameProc(hwnd, hwndClient, uMsg, wParam, lParam)
		}

		MDIChildProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
			begin
				if uMsg == Windows::WM_NCCREATE
					@@instances[hwnd.to_i] = ObjectSpace._id2ref(
						Windows::MDICREATESTRUCT.new(
							Windows::CREATESTRUCT.new(FFI::Pointer.new(lParam))[:lpCreateParams]
						)[:lParam]
					)

					@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
				end

				result = @@instances[hwnd.to_i].windowProc(hwnd, uMsg, wParam, lParam) if @@instances[hwnd.to_i]
			rescue
				answer = Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, buttons: [:abort, :retry, :ignore], icon: :error

				Application.quit if answer.abort?
			ensure
				if uMsg == Windows::WM_NCDESTROY
					@@instances[hwnd.to_i].dialog = false

					@@instances.delete(hwnd.to_i)
				end
			end

			result || Windows.DefMDIChildProc(hwnd, uMsg, wParam, lParam)
		}

		DialogProc = FFI::Function.new(:int, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
			begin
				if uMsg == Windows::WM_INITDIALOG
					@@instances[hwnd.to_i] = ObjectSpace._id2ref(lParam)

					@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
				end

				result = @@instances[hwnd.to_i].windowProc(hwnd, uMsg, wParam, lParam) if @@instances[hwnd.to_i]
			rescue
				answer = Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, buttons: [:abort, :retry, :ignore], icon: :error

				Application.quit if answer.abort?
			ensure
				if uMsg == Windows::WM_NCDESTROY
					@@instances[hwnd.to_i].dialog = false

					@@instances.delete(hwnd.to_i)
				end
			end

			(result.nil?) ? 0 : 1
		}

		WindowClass = Fzeet::WindowClass.new(nil, 'Fzeet.BasicWindow')

		def self.[](name, opts = {})
			Class.new(self) {
				const_set(:WindowClass, Fzeet::WindowClass.new(self::WindowClass, name, opts))
			}
		end

		def self.crackMessage(hwnd, uMsg, wParam, lParam)
			window = @@instances[hwnd.to_i]

			args = {
				hwnd: hwnd,
				uMsg: uMsg,
				wParam: wParam,
				lParam: lParam,
				result: (window.kind_of?(Dialog)) ? 1 : 0,
				window: window,
				sender: window
			}

			case uMsg
			when Windows::WM_CREATE
				args[:cs] = Windows::CREATESTRUCT.new(FFI::Pointer.new(lParam))
			when Windows::WM_NCCREATE
				args[:result] = 1
				args[:cs] = Windows::CREATESTRUCT.new(FFI::Pointer.new(lParam))
			when Windows::WM_COMMAND
				args[:command], args[:notification], args[:hctl] = Windows.LOWORD(wParam), Windows.HIWORD(wParam), FFI::Pointer.new(lParam)
				args[:sender] = @@instances[args[:hctl].to_i] unless args[:hctl].null?
			when Windows::WM_NOTIFY
				args[:nmh] = Windows::NMHDR.new(FFI::Pointer.new(lParam))
				args[:command], args[:notification], args[:hctl] = args[:nmh][:idFrom], args[:nmh][:code], args[:nmh][:hwndFrom]
				(args[:sender] = @@instances[args[:hctl].to_i]).class.crackNotification(args)
			when \
				Windows::WM_MOUSEMOVE,
				Windows::WM_LBUTTONDOWN, Windows::WM_LBUTTONUP, Windows::WM_LBUTTONDBLCLK,
				Windows::WM_RBUTTONDOWN, Windows::WM_RBUTTONUP, Windows::WM_RBUTTONDBLCLK,
				Windows::WM_MBUTTONDOWN, Windows::WM_MBUTTONUP, Windows::WM_MBUTTONDBLCLK,
				Windows::WM_CONTEXTMENU

				args[:x], args[:y] = Windows.GET_X_LPARAM(lParam), Windows.GET_Y_LPARAM(lParam)

				if uMsg == Windows::WM_CONTEXTMENU && args[:x] == -1
					Windows.DetonateLastError(0, :GetCursorPos, pt = Point.new)

					args[:keyboard], args[:x], args[:y] = true, pt[:x], pt[:y]
				end
			end

			args
		end

		def initialize(opts = {})
			_opts = {
				xstyle: [],
				caption: Application.name,
				style: [],
				x: Windows::CW_USEDEFAULT,
				y: Windows::CW_USEDEFAULT,
				width: Windows::CW_USEDEFAULT,
				height: Windows::CW_USEDEFAULT,
				parent: nil,
				menu: nil,
				position: [],
				anchor: nil
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			yield self, _opts if block_given?

			_opts[:xstyle] = Fzeet.flags(_opts[:xstyle], *self.class::Prefix[:xstyle])
			_opts[:caption] = _opts[:caption].to_s
			_opts[:style] = Fzeet.flags(_opts[:style], *self.class::Prefix[:style])
			_opts[:x], _opts[:y], _opts[:width], _opts[:height] = _opts[:position] unless _opts[:position].empty?

			@messages ||= {}
			@commands ||= {}
			@notifies ||= {}

			@processed = [0, 0]

			@handle = Windows.CreateWindowEx(
				_opts[:xstyle],  self.class::WindowClass.name, _opts[:caption], _opts[:style],
				_opts[:x], _opts[:y], _opts[:width], _opts[:height],
				_opts[:parent] && _opts[:parent].handle, nil, Windows.GetModuleHandle(nil), FFI::Pointer.new(object_id)
			)

			if @handle.null?
				raise "CreateWindowEx failed (last error #{Windows.GetLastError()})." unless [
					[Windows::WM_NCCREATE, 0], [Windows::WM_CREATE, -1],
					[Windows::WM_DESTROY, 0], [Windows::WM_NCDESTROY, 0]
				].include?(@processed)
			else
				@parent = _opts[:parent]
				self.menu = _opts[:menu] if _opts[:menu]

				on(:destroy) {
					menu.rdetach if self.menu

					eachChild(&:dispose)
				}

				case _opts[:anchor]
				when :ltr
					@parent.on(:size) { |args|
						self.position = @parent.rect.tap { |r| r[:bottom] = _opts[:height] }.to_a

						args[:result] = nil if @parent.class == MDIChild
					}
				when :lrb
					@parent.on(:size) { |args|
						self.position = @parent.rect.tap { |r| r[:top] = r[:bottom] - _opts[:height]; r[:bottom] = _opts[:height] }.to_a

						args[:result] = nil if @parent.class == MDIChild
					}
				when :ltrb
					@parent.on(:size) { |args|
						self.position = @parent.rect.to_a

						args[:result] = nil if @parent.class == MDIChild
					}
				else raise ArgumentError, "Bad anchor spec: #{_opts[:anchor]}."
				end if _opts[:anchor] && @parent
			end
		end

		attr_reader :parent, :client, :ribbon

		def dispose; Windows.DestroyWindow(@handle) end

		def windowProc(hwnd, uMsg, wParam, lParam)
			args, result = nil, nil

			if (handlers = @messages[uMsg])
				args ||= self.class.crackMessage(hwnd, uMsg, wParam, lParam)

				handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]; @processed[0], @processed[1] = uMsg, result
				}
			end

			if uMsg == Windows::WM_COMMAND && (handlers = @commands[Windows.LOWORD(wParam)])
				args ||= self.class.crackMessage(hwnd, uMsg, wParam, lParam)

				handlers[:all].each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]; @processed[0], @processed[1] = uMsg, result
				} if handlers[:all]

				handlers[Windows.HIWORD(wParam)].each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]; @processed[0], @processed[1] = uMsg, result
				} if handlers[Windows.HIWORD(wParam)]
			end

			if uMsg == Windows::WM_NOTIFY && (handlers = @notifies[(nmh = Windows::NMHDR.new(FFI::Pointer.new(lParam)))[:idFrom]])
				args ||= self.class.crackMessage(hwnd, uMsg, wParam, lParam)

				handlers[:all].each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]; @processed[0], @processed[1] = uMsg, result
				} if handlers[:all]

				handlers[nmh[:code]].each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]; @processed[0], @processed[1] = uMsg, result
				} if handlers[nmh[:code]]
			end

			result
		end

		def onMessage(msg, &block)
			((@messages ||= {})[Fzeet.constant(msg, :wm_)] ||= []) << block

			self
		end

		def onCommand(cmd, notification = :all, &block)
			notification = Fzeet.constant(notification, *self[cmd].class::Prefix[:notification]) unless
				notification.kind_of?(Integer) || notification == :all

			(((@commands ||= {})[Command[cmd]] ||= {})[notification] ||= []) << block

			self
		end

		def onNotify(cmd, notification = :all, &block)
			notification = Fzeet.constant(notification, *self[cmd].class::Prefix[:notification]) unless
				notification.kind_of?(Integer) || notification == :all

			(((@notifies ||= {})[Command[cmd]] ||= {})[notification] ||= []) << block

			self
		end

		def on(*args, &block)
			args[0] =~ /^draw$/ and
				return onMessage(:paint) { |_args| paint { |dc| dc.select(*args[1..-1]) {
					case block.arity
					when 0; block.call
					when 1; block.call(dc)
					else block.call(dc, _args)
					end
				}}}

			case args.length
			when 1; onMessage(*args, &block)
			when 2, 3
				case Fzeet.constant(args.shift, :wm_)
				when Windows::WM_COMMAND; onCommand(*args, &block)
				when Windows::WM_NOTIFY; onNotify(*args, &block)
				else raise ArgumentError
				end
			else raise ArgumentError
			end
		end

		def stubNotImplementedCommands
			Command.instance_variable_get(:@ids).each { |command, id|
				next if @commands.find { |_id, handlers| _id == id }

				on(:command, id) { message "Not Implemented (#{command})", icon: :warning }
			}

			self
		end
	end
end
