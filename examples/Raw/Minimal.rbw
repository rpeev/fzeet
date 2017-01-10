require 'fzeet/windows'

include Fzeet::Windows

EnableVisualStyles()

APPNAME = File.basename(__FILE__, '.rbw')

def onDestroy(hwnd)
	PostQuitMessage(0); 0
end

WindowProc = FFI::Function.new(:long, [:pointer, :uint, :uint, :long], convention: :stdcall) { |hwnd, uMsg, wParam, lParam|
	result = case uMsg
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
