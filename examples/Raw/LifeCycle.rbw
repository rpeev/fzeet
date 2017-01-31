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

def onCreate(hwnd, cs)
	answer = MessageBox(nil, 'Create?', cs[:lpszName].read_string, MB_YESNO | MB_ICONQUESTION)

	return -1 if answer == IDNO

	0
end

def onClose(hwnd)
	answer = MessageBox(hwnd, 'Close?', APPNAME, MB_YESNO | MB_DEFBUTTON2 | MB_ICONQUESTION)

	DestroyWindow(hwnd) if answer == IDYES

	0
end

def onDestroy(hwnd)
	MessageBox(nil, __method__.to_s, APPNAME, MB_ICONINFORMATION)

	PostQuitMessage(0); 0
end

WindowProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
	result = case uMsg
	when WM_CREATE
		onCreate(hwnd, CREATESTRUCT.new(FFI::Pointer.new(lParam)))
	when WM_CLOSE
		onClose(hwnd)
	when WM_DESTROY
		onDestroy(hwnd)
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

	TranslateMessage(msg)
	DispatchMessage(msg)
end

exit(msg[:wParam])
