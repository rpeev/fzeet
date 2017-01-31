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

require_relative 'Common'

module Fzeet
	module Windows
		PDERR_PRINTERCODES = 0x1000
		PDERR_SETUPFAILURE = 0x1001
		PDERR_PARSEFAILURE = 0x1002
		PDERR_RETDEFFAILURE = 0x1003
		PDERR_LOADDRVFAILURE = 0x1004
		PDERR_GETDEVMODEFAIL = 0x1005
		PDERR_INITFAILURE = 0x1006
		PDERR_NODEVICES = 0x1007
		PDERR_NODEFAULTPRN = 0x1008
		PDERR_DNDMMISMATCH = 0x1009
		PDERR_CREATEICFAILURE = 0x100A
		PDERR_PRINTERNOTFOUND = 0x100B
		PDERR_DEFAULTDIFFERENT = 0x100C

		PSD_DEFAULTMINMARGINS = 0x00000000
		PSD_INWININIINTLMEASURE = 0x00000000
		PSD_MINMARGINS = 0x00000001
		PSD_MARGINS = 0x00000002
		PSD_INTHOUSANDTHSOFINCHES = 0x00000004
		PSD_INHUNDREDTHSOFMILLIMETERS = 0x00000008
		PSD_DISABLEMARGINS = 0x00000010
		PSD_DISABLEPRINTER = 0x00000020
		PSD_NOWARNING = 0x00000080
		PSD_DISABLEORIENTATION = 0x00000100
		PSD_RETURNDEFAULT = 0x00000400
		PSD_DISABLEPAPER = 0x00000200
		PSD_SHOWHELP = 0x00000800
		PSD_ENABLEPAGESETUPHOOK = 0x00002000
		PSD_ENABLEPAGESETUPTEMPLATE = 0x00008000
		PSD_ENABLEPAGESETUPTEMPLATEHANDLE = 0x00020000
		PSD_ENABLEPAGEPAINTHOOK = 0x00040000
		PSD_DISABLEPAGEPAINTING = 0x00080000
		PSD_NONETWORKBUTTON = 0x00200000

		callback :PAGESETUPHOOK, [:pointer, :uint, :uint, :long], :uint
		callback :PAGEPAINTHOOK, [:pointer, :uint, :uint, :long], :uint

		class PAGESETUPDLG < FFI::Struct
			layout \
			:lStructSize, :ulong,
			:hwndOwner, :pointer,
			:hDevMode, :pointer,
			:hDevNames, :pointer,
			:Flags, :ulong,
			:ptPaperSize, POINT,
			:rtMinMargin, RECT,
			:rtMargin, RECT,
			:hInstance, :pointer,
			:lCustData, :long,
			:lpfnPageSetupHook, :PAGESETUPHOOK,
			:lpfnPagePaintHook, :PAGEPAINTHOOK,
			:lpPageSetupTemplateName, :pointer,
			:hPageSetupTemplate, :pointer
		end

		attach_function :PageSetupDlg, :PageSetupDlgA, [:pointer], :int

		WM_PSD_PAGESETUPDLG = WM_USER
		WM_PSD_FULLPAGERECT = WM_USER + 1
		WM_PSD_MINMARGINRECT = WM_USER + 2
		WM_PSD_MARGINRECT = WM_USER + 3
		WM_PSD_GREEKTEXTRECT = WM_USER + 4
		WM_PSD_ENVSTAMPRECT = WM_USER + 5
		WM_PSD_YAFULLPAGERECT = WM_USER + 6

		DN_DEFAULTPRN = 0x0001

		class DEVNAMES < FFI::Struct
			layout \
				:wDriverOffset, :ushort,
				:wDeviceOffset, :ushort,
				:wOutputOffset, :ushort,
				:wDefault, :ushort
		end

		PD_ALLPAGES = 0x00000000
		PD_SELECTION = 0x00000001
		PD_PAGENUMS = 0x00000002
		PD_NOSELECTION = 0x00000004
		PD_NOPAGENUMS = 0x00000008
		PD_COLLATE = 0x00000010
		PD_PRINTTOFILE = 0x00000020
		PD_PRINTSETUP = 0x00000040
		PD_NOWARNING = 0x00000080
		PD_RETURNDC = 0x00000100
		PD_RETURNIC = 0x00000200
		PD_RETURNDEFAULT = 0x00000400
		PD_SHOWHELP = 0x00000800
		PD_ENABLEPRINTHOOK = 0x00001000
		PD_ENABLESETUPHOOK = 0x00002000
		PD_ENABLEPRINTTEMPLATE = 0x00004000
		PD_ENABLESETUPTEMPLATE = 0x00008000
		PD_ENABLEPRINTTEMPLATEHANDLE = 0x00010000
		PD_ENABLESETUPTEMPLATEHANDLE = 0x00020000
		PD_USEDEVMODECOPIES = 0x00040000
		PD_USEDEVMODECOPIESANDCOLLATE = 0x00040000
		PD_DISABLEPRINTTOFILE = 0x00080000
		PD_HIDEPRINTTOFILE = 0x00100000
		PD_NONETWORKBUTTON = 0x00200000
		PD_CURRENTPAGE = 0x00400000
		PD_NOCURRENTPAGE = 0x00800000
		PD_EXCLUSIONFLAGS = 0x01000000
		PD_USELARGETEMPLATE = 0x10000000

		callback :PRINTHOOKPROC, [:pointer, :uint, :uint, :long], :uint
		callback :SETUPHOOKPROC, [:pointer, :uint, :uint, :long], :uint

		class PRINTDLG < FFI::Struct
			layout \
				:lStructSize, :ulong, # Set to 66 explicitly, NOT to struct.size
				:hwndOwner, :pointer,
				:hDevMode, :pointer,
				:hDevNames, :pointer,
				:hDC, :pointer,
				:Flags, :ulong,
				:nFromPage, :ushort,
				:nToPage, :ushort,
				:nMinPage, :ushort,
				:nMaxPage, :ushort,
				:nCopies, :ushort,
				:hInstance, :pointer, 34,
				:lCustData, :long, 38,
				:lpfnPrintHook, :PRINTHOOKPROC, 42,
				:lpfnSetupHook, :SETUPHOOKPROC, 46,
				:lpPrintTemplateName, :pointer, 50,
				:lpSetupTemplateName, :pointer, 54,
				:hPrintTemplate, :pointer, 58,
				:hSetupTemplate, :pointer, 62
		end

		attach_function :PrintDlg, :PrintDlgA, [:pointer], :int

		#PD_EXCL_COPIESANDCOLLATE = DM_COPIES | DM_COLLATE

		class PRINTPAGERANGE < FFI::Struct
			layout \
				:nFromPage, :ulong,
				:nToPage, :ulong
		end

		IPrintDialogCallback = COM::Interface[IUnknown,
			GUID['5852A2C3-6530-11D1-B6A3-0000F8757BF9'],

			InitDone: [[], :long],
			SelectionChange: [[], :long],
			HandleMessage: [[:pointer, :uint, :uint, :long, :pointer], :long]
		]

		PrintDialogCallback = COM::Callback[IPrintDialogCallback]

		IPrintDialogServices = COM::Interface[IUnknown,
			GUID['509AAEDA-5639-11D1-B6A1-0000F8757BF9'],

			GetCurrentDevMode: [[:pointer, :pointer], :long],
			GetCurrentPrinterName: [[:buffer_out, :pointer], :long],
			GetCurrentPortName: [[:buffer_out, :pointer], :long]
		]

		PrintDialogServices = COM::Instance[IPrintDialogServices]

		START_PAGE_GENERAL = 0xffffffff

		PD_RESULT_CANCEL = 0
		PD_RESULT_PRINT = 1
		PD_RESULT_APPLY = 2

		class PRINTDLGEX < FFI::Struct
			layout \
				:lStructSize, :ulong,
				:hwndOwner, :pointer,
				:hDevMode, :pointer,
				:hDevNames, :pointer,
				:hDC, :pointer,
				:Flags, :ulong,
				:Flags2, :ulong,
				:ExclusionFlags, :ulong,
				:nPageRanges, :ulong,
				:nMaxPageRanges, :ulong,
				:lpPageRanges, :pointer,
				:nMinPage, :ulong,
				:nMaxPage, :ulong,
				:nCopies, :ulong,
				:hInstance, :pointer,
				:lpPrintTemplateName, :pointer,
				:lpCallback, :pointer,
				:nPropertyPages, :ulong,
				:lphPropertyPages, :pointer,
				:nStartPage, :ulong,
				:dwResultAction, :ulong
		end

		attach_function :PrintDlgEx, :PrintDlgExA, [:pointer], :long
	end

	class PageSetupDialog
		def initialize(opts = {})
			_opts = {

			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = Windows::PAGESETUPDLG.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:Flags] = Fzeet.flags(0, :psd_)
		end

		attr_reader :struct

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.PageSetupDlg(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end
	end

	class PrintDialog
		def initialize(opts = {})
			_opts = {

			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = Windows::PRINTDLG.new

			@struct[:lStructSize] = 66
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:Flags] = Fzeet.flags([:returndc, :usedevmodecopiesandcollate], :pd_)
		end

		attr_reader :struct

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.PrintDlg(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end
	end

	class PrintDialogEx
		def initialize(opts = {})
			_opts = {

			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = Windows::PRINTDLGEX.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:Flags] = Fzeet.flags([:returndc, :usedevmodecopiesandcollate], :pd_)
		end

		attr_reader :struct

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.PrintDlgEx(@struct) != Windows::S_OK) ? Windows::IDCANCEL : Windows::IDOK)
		end
	end
end
