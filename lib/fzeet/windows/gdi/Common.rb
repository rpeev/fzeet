require_relative '../core'

module Fzeet
	module Windows
		ffi_lib 'gdi32'
		ffi_convention :stdcall

		def GetRValue(rgb) LOBYTE(rgb) end
		def GetGValue(rgb) LOBYTE(rgb >> 8) end
		def GetBValue(rgb) LOBYTE(rgb >> 16) end
		def RGB(r, g, b) r | (g << 8) | (b << 16) end

		module_function \
			:GetRValue, :GetGValue, :GetBValue, :RGB

		LOGPIXELSX = 88
		LOGPIXELSY = 90

		attach_function :GetDeviceCaps, [:pointer, :int], :int

		DEFAULT_GUI_FONT = 17

		attach_function :GetStockObject, [:int], :pointer

		attach_function :DeleteObject, [:pointer], :int

		attach_function :SelectObject, [:pointer, :pointer], :pointer

		attach_function :GetTextExtentPoint, :GetTextExtentPointA, [:pointer, :string, :int, :pointer], :int

		attach_function :GetTextColor, [:pointer], :ulong
		attach_function :SetTextColor, [:pointer, :ulong], :ulong

		attach_function :GetBkColor, [:pointer], :ulong
		attach_function :SetBkColor, [:pointer, :ulong], :ulong

		attach_function :MoveToEx, [:pointer, :int, :int, :pointer], :int
		attach_function :LineTo, [:pointer, :int, :int], :int
	end
end
