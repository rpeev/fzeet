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
		PSP_DEFAULT = 0x00000000
		PSP_DLGINDIRECT = 0x00000001
		PSP_USEHICON = 0x00000002
		PSP_USEICONID = 0x00000004
		PSP_USETITLE = 0x00000008
		PSP_RTLREADING = 0x00000010
		PSP_HASHELP = 0x00000020
		PSP_USEREFPARENT = 0x00000040
		PSP_USECALLBACK = 0x00000080
		PSP_PREMATURE = 0x00000400
		PSP_HIDEHEADER = 0x00000800
		PSP_USEHEADERTITLE = 0x00001000
		PSP_USEHEADERSUBTITLE = 0x00002000
		PSP_USEFUSIONCONTEXT = 0x00004000

		callback :PSPCALLBACK, [:pointer, :uint, :pointer], :uint

		class PROPSHEETPAGE < FFI::Struct
			layout(*[
				:dwSize, :ulong,
				:dwFlags, :ulong,
				:hInstance, :pointer,
				:template, Class.new(FFI::Union) {
					layout \
						:pszTemplate, :pointer,
						:pResource, :pointer
				},
				:icon, Class.new(FFI::Union) {
					layout \
						:hIcon, :pointer,
						:pszIcon, :pointer
				},
				:pszTitle, :pointer,
				:pfnDlgProc, :DLGPROC,
				:lParam, :long,
				:pfnCallback, :PSPCALLBACK,
				:pcRefParent, :pointer,
				:pszHeaderTitle, :pointer,
				:pszHeaderSubTitle, :pointer,
				(Version >= :xp) ? [
					:hActCtx, :pointer
				] : nil,
				(Version >= :vista) ? [
					:header, Class.new(FFI::Union) {
						layout \
							:hbmHeader, :pointer,
							:pszbmHeader, :pointer
					}
				] : nil
			].flatten.compact)
		end

		attach_function :CreatePropertySheetPage, :CreatePropertySheetPageA, [:pointer], :pointer
		attach_function :DestroyPropertySheetPage, [:pointer], :int

		PSH_DEFAULT = 0x00000000
		PSH_PROPTITLE = 0x00000001
		PSH_USEHICON = 0x00000002
		PSH_USEICONID = 0x00000004
		PSH_PROPSHEETPAGE = 0x00000008
		PSH_WIZARDHASFINISH = 0x00000010
		PSH_WIZARD = 0x00000020
		PSH_USEPSTARTPAGE = 0x00000040
		PSH_NOAPPLYNOW = 0x00000080
		PSH_USECALLBACK = 0x00000100
		PSH_HASHELP = 0x00000200
		PSH_MODELESS = 0x00000400
		PSH_RTLREADING = 0x00000800
		PSH_WIZARDCONTEXTHELP = 0x00001000
		PSH_WIZARD97 = 0x01000000
		PSH_WATERMARK = 0x00008000
		PSH_USEHBMWATERMARK = 0x00010000
		PSH_USEHPLWATERMARK = 0x00020000
		PSH_STRETCHWATERMARK = 0x00040000
		PSH_HEADER = 0x00080000
		PSH_USEHBMHEADER = 0x00100000
		PSH_USEPAGELANG = 0x00200000
		PSH_WIZARD_LITE = 0x00400000
		PSH_NOCONTEXTHELP = 0x02000000
		PSH_AEROWIZARD = 0x00004000
		PSH_RESIZABLE = 0x04000000
		PSH_HEADERBITMAP = 0x08000000
		PSH_NOMARGIN = 0x10000000

		callback :PROPSHEETCALLBACK, [:pointer, :uint, :long], :int

		class  PROPSHEETHEADER < FFI::Struct
			layout \
				:dwSize, :ulong,
				:dwFlags, :ulong,
				:hwndParent, :pointer,
				:hInstance, :pointer,
				:icon, Class.new(FFI::Union) {
					layout \
						:hIcon, :pointer,
						:pszIcon, :pointer
				},
				:pszCaption, :pointer,
				:nPages, :uint,
				:start, Class.new(FFI::Union) {
					layout \
						:nStartPage, :uint,
						:pStartPage, :pointer
				},
				:pages, Class.new(FFI::Union) {
					layout \
						:ppsp, :pointer,
						:phpage, :pointer
				},
				:pfnCallback, :PROPSHEETCALLBACK,
				:watermark, Class.new(FFI::Union) {
					layout \
						:hbmWatermark, :pointer,
						:pszbmWatermark, :pointer
				},
				:hplWatermark, :pointer,
				:header, Class.new(FFI::Union) {
					layout \
						:hbmHeader, :pointer,
						:pszbmHeader, :pointer
				}
		end

		attach_function :PropertySheet, :PropertySheetA, [:pointer], :int

		PSM_SETCURSEL = WM_USER + 101
		PSM_REMOVEPAGE = WM_USER + 102
		PSM_ADDPAGE = WM_USER + 103
		PSM_CHANGED = WM_USER + 104
		PSM_RESTARTWINDOWS = WM_USER + 105
		PSM_REBOOTSYSTEM = WM_USER + 106
		PSM_CANCELTOCLOSE = WM_USER + 107
		PSM_QUERYSIBLINGS = WM_USER + 108
		PSM_UNCHANGED = WM_USER + 109
		PSM_APPLY = WM_USER + 110
		PSM_SETTITLE = WM_USER + 111
		PSM_SETWIZBUTTONS = WM_USER + 112
		PSM_PRESSBUTTON = WM_USER + 113
		PSM_SETCURSELID = WM_USER + 114
		PSM_SETFINISHTEXT = WM_USER + 115
		PSM_GETTABCONTROL = WM_USER + 116
		PSM_ISDIALOGMESSAGE = WM_USER + 117
		PSM_GETCURRENTPAGEHWND = WM_USER + 118
		PSM_INSERTPAGE = WM_USER + 119
		PSM_SETHEADERTITLE = WM_USER + 125
		PSM_SETHEADERSUBTITLE = WM_USER + 127
		PSM_HWNDTOINDEX = WM_USER + 129
		PSM_INDEXTOHWND = WM_USER + 130
		PSM_PAGETOINDEX = WM_USER + 131
		PSM_INDEXTOPAGE = WM_USER + 132
		PSM_IDTOINDEX = WM_USER + 133
		PSM_INDEXTOID = WM_USER + 134
		PSM_GETRESULT = WM_USER + 135
		PSM_RECALCPAGESIZES = WM_USER + 136
		PSM_SETNEXTTEXT = WM_USER + 137
		PSM_SHOWWIZBUTTONS = WM_USER + 138
		PSM_ENABLEWIZBUTTONS = WM_USER + 139
		PSM_SETBUTTONTEXT = WM_USER + 140

		PSWIZF_SETCOLOR = 0xffffffff

		PSWIZB_BACK = 0x00000001
		PSWIZB_NEXT = 0x00000002
		PSWIZB_FINISH = 0x00000004
		PSWIZB_DISABLEDFINISH = 0x00000008
		PSWIZB_CANCEL = 0x00000010
		PSWIZB_SHOW = 0
		PSWIZB_RESTORE = 1

		PSWIZBF_ELEVATIONREQUIRED = 0x00000001

		PSBTN_BACK = 0
		PSBTN_NEXT = 1
		PSBTN_FINISH = 2
		PSBTN_OK = 3
		PSBTN_APPLYNOW = 4
		PSBTN_CANCEL = 5
		PSBTN_HELP = 6
		PSBTN_MAX = 6

		PSN_FIRST = 0x1_0000_0000 - 200
		PSN_LAST = 0x1_0000_0000 - 299
		PSN_SETACTIVE = PSN_FIRST - 0
		PSN_KILLACTIVE = PSN_FIRST - 1
		PSN_APPLY = PSN_FIRST - 2
		PSN_RESET = PSN_FIRST - 3
		PSN_HELP = PSN_FIRST - 5
		PSN_WIZBACK = PSN_FIRST - 6
		PSN_WIZNEXT = PSN_FIRST - 7
		PSN_WIZFINISH = PSN_FIRST - 8
		PSN_QUERYCANCEL = PSN_FIRST - 9
		PSN_GETOBJECT = PSN_FIRST - 10
		PSN_TRANSLATEACCELERATOR = PSN_FIRST - 12
		PSN_QUERYINITIALFOCUS = PSN_FIRST - 13

		PSNRET_NOERROR = 0
		PSNRET_INVALID = 1
		PSNRET_INVALID_NOCHANGEPAGE = 2
		PSNRET_MESSAGEHANDLED = 3
	end

	class PropertyPage
		class PROPSHEETPAGEA1 < FFI::Struct
			layout \
				:array, [Windows::PROPSHEETPAGE, 1]
		end

		def initialize

		end
	end

	class PropertySheet
		def initialize(parent, opts = {wizard: false})
			pointers = []

			psps = PropertyPage::PROPSHEETPAGEA1.new

			dt = Windows::DLGTEMPLATE.new

			dt[:style] = Fzeet.flags([:'3dlook', :control, :child, :tabstop], :ds_, :ws_)
			dt[:x], dt[:y], dt[:cx], dt[:cy] = 100, 100, 300, 150

			psp = psps[:array][0]

			psp[:dwSize] = psp.size
			psp[:dwFlags] = Fzeet.flags([:dlgindirect, :usetitle], :psp_)
			psp[:hInstance] = Windows.GetModuleHandle(nil)
			psp[:template][:pResource] = dt
			psp[:pszTitle] = pointers.push(FFI::MemoryPointer.from_string("Page")).last

			psh = Windows::PROPSHEETHEADER.new

			psh[:dwSize] = psh.size
			psh[:dwFlags] = Fzeet.flags(:propsheetpage, :psh_)
			psh[:dwFlags] |= Windows::PSH_WIZARD if opts[:wizard]
			psh[:hwndParent] = parent.handle
			psh[:hInstance] = Windows.GetModuleHandle(nil)
			psh[:pszCaption] = pointers.push(FFI::MemoryPointer.from_string('Sheet')).last
			psh[:nPages] = 1
			psh[:start][:nStartPage] = 0
			psh[:pages][:ppsp] = psps

			Windows.DetonateLastError(-1, :PropertySheet, psh)
		ensure
			pointers.each(&:free)
		end
	end
end
