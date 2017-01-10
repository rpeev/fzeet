require_relative '../kernel'
require_relative '../gdi'

module Fzeet
	module Windows
		ffi_lib 'user32'
		ffi_convention :stdcall

		if Version >= :vista
			attach_function :SetProcessDPIAware, [], :int
		end

		IMAGE_BITMAP = 0
		IMAGE_ICON = 1
		IMAGE_CURSOR = 2
		IMAGE_ENHMETAFILE = 3

		LR_DEFAULTCOLOR = 0x00000000
		LR_MONOCHROME = 0x00000001
		LR_COLOR = 0x00000002
		LR_COPYRETURNORG = 0x00000004
		LR_COPYDELETEORG = 0x00000008
		LR_LOADFROMFILE = 0x00000010
		LR_LOADTRANSPARENT = 0x00000020
		LR_DEFAULTSIZE = 0x00000040
		LR_VGACOLOR = 0x00000080
		LR_LOADMAP3DCOLORS = 0x00001000
		LR_CREATEDIBSECTION = 0x00002000
		LR_COPYFROMRESOURCE = 0x00004000
		LR_SHARED = 0x00008000

		attach_function :LoadImage, :LoadImageA, [:pointer, :string, :uint, :int, :int, :uint], :pointer
	end
end
