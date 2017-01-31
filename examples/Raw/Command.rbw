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

require 'fzeet/windows'

include Fzeet::Windows

EnableVisualStyles()

APPNAME = File.basename(__FILE__, '.rbw')

CMD_ITEM1 = WM_APP + 1
CTL_BUTTON1 = CMD_ITEM1 + 1

def onCreate(hwnd, cs)
	bar = CreateMenu()
		menu1 = CreatePopupMenu()
			AppendMenu(menu1, MF_STRING, CMD_ITEM1, "Item&1\tAlt+I")
		AppendMenu(bar, MF_POPUP, menu1.to_i, 'Menu&1')
	SetMenu(hwnd, bar)

	accels = [
		[FALT | FVIRTKEY, 'I'.ord, CMD_ITEM1]
	]

	FFI::MemoryPointer.new(ACCEL, accels.size) { |paccels|
		accels.each_with_index { |data, i|
			accel = ACCEL.new(paccels + i * ACCEL.size)

			accel.members.each_with_index { |k, i| accel[k] = data[i] }
		}

		@haccel = CreateAcceleratorTable(paccels, accels.size)
	}

	hbtn = CreateWindowEx(0, 'Button', '&Button1', WS_CHILD | WS_VISIBLE, 10, 10, 76, 24, hwnd, FFI::Pointer.new(CTL_BUTTON1), GetModuleHandle(nil), nil)
	SendMessage(hbtn, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT).to_i, 1)

	0
end

def onDestroy(hwnd)
	DestroyAcceleratorTable(@haccel)

	PostQuitMessage(0); 0
end

def onItem1(hwnd, notification)
	MessageBox(hwnd, __method__.to_s, APPNAME, MB_ICONINFORMATION)

	EnableWindow(GetDlgItem(hwnd, CTL_BUTTON1), 1)
	EnableMenuItem(GetMenu(hwnd), CMD_ITEM1, MF_GRAYED)

	0
end

def onButton1(hwnd, notification, hctl)
	MessageBox(hwnd, __method__.to_s, APPNAME, MB_ICONINFORMATION)

	EnableMenuItem(GetMenu(hwnd), CMD_ITEM1, MF_ENABLED)
	EnableWindow(hctl, 0)

	0
end

WindowProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
	result = case uMsg
	when WM_CREATE
		onCreate(hwnd, CREATESTRUCT.new(FFI::Pointer.new(lParam)))
	when WM_DESTROY
		onDestroy(hwnd)
	when WM_COMMAND; command, notification, hctl = LOWORD(wParam), HIWORD(wParam), FFI::Pointer.new(lParam)
		case command
		when CMD_ITEM1
			onItem1(hwnd, notification)
		when CTL_BUTTON1
			onButton1(hwnd, notification, hctl)
		end
	end

	result || DefWindowProc(hwnd, uMsg, wParam, lParam)
}

wc = WNDCLASSEX.new

wc[:cbSize] = wc.size
wc[:lpfnWndProc] = WindowProc
wc[:hInstance] = GetModuleHandle(nil)
wc[:hIcon] = LoadIcon(nil, IDI_APPLICATION)
wc[:hCursor] = LoadCursor(nil, IDC_ARROW)
wc[:hbrBackground] = FFI::Pointer.new(COLOR_WINDOW + 1)
wc[:lpszClassName] = className = FFI::MemoryPointer.from_string(APPNAME)

if RegisterClassEx(wc).tap { className.free } == 0
	MessageBox(nil, 'RegisterClassEx failed.', APPNAME, MB_ICONERROR); exit(0)
end

hwnd = CreateWindowEx(
	0, APPNAME, APPNAME, WS_OVERLAPPEDWINDOW,
	CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
	nil, nil, GetModuleHandle(nil), nil
)

if hwnd.null?
	MessageBox(nil, 'CreateWindowEx failed.', APPNAME, MB_ICONERROR); exit(0)
end

ShowWindow(hwnd, SW_SHOWNORMAL)
UpdateWindow(hwnd)

msg = MSG.new

while (get = GetMessage(msg, nil, 0, 0)) != 0
	if get == -1
		MessageBox(nil, 'GetMessage failed.', APPNAME, MB_ICONERROR); exit(0)
	end

	if TranslateAccelerator(hwnd, @haccel, msg) == 0
		TranslateMessage(msg)
		DispatchMessage(msg)
	end
end

exit(msg[:wParam])
