require_relative 'Common'

module Fzeet
	module Windows
		CFERR_CHOOSEFONTCODES = 0x2000
		CFERR_NOFONTS = 0x2001
		CFERR_MAXLESSTHANMIN = 0x2002

		CF_SCREENFONTS = 0x00000001
		CF_PRINTERFONTS = 0x00000002
		CF_BOTH = CF_SCREENFONTS | CF_PRINTERFONTS
		CF_SHOWHELP = 0x00000004
		CF_ENABLEHOOK = 0x00000008
		CF_ENABLETEMPLATE = 0x00000010
		CF_ENABLETEMPLATEHANDLE = 0x00000020
		CF_INITTOLOGFONTSTRUCT = 0x00000040
		CF_USESTYLE = 0x00000080
		CF_EFFECTS = 0x00000100
		CF_APPLY = 0x00000200
		CF_ANSIONLY = 0x00000400
		CF_SCRIPTSONLY = CF_ANSIONLY
		CF_NOVECTORFONTS = 0x00000800
		CF_NOOEMFONTS = CF_NOVECTORFONTS
		CF_NOSIMULATIONS = 0x00001000
		CF_LIMITSIZE = 0x00002000
		CF_FIXEDPITCHONLY = 0x00004000
		CF_WYSIWYG = 0x00008000
		CF_FORCEFONTEXIST = 0x00010000
		CF_SCALABLEONLY = 0x00020000
		CF_TTONLY = 0x00040000
		CF_NOFACESEL = 0x00080000
		CF_NOSTYLESEL = 0x00100000
		CF_NOSIZESEL = 0x00200000
		CF_SELECTSCRIPT = 0x00400000
		CF_NOSCRIPTSEL = 0x00800000
		CF_NOVERTFONTS = 0x01000000
		CF_INACTIVEFONTS = 0x02000000

		callback :CFHOOKPROC, [:pointer, :uint, :uint, :long], :uint

		SIMULATED_FONTTYPE = 0x8000
		PRINTER_FONTTYPE = 0x4000
		SCREEN_FONTTYPE = 0x2000
		BOLD_FONTTYPE = 0x0100
		ITALIC_FONTTYPE = 0x0200
		REGULAR_FONTTYPE = 0x0400
		PS_OPENTYPE_FONTTYPE = 0x10000
		TT_OPENTYPE_FONTTYPE = 0x20000
		TYPE1_FONTTYPE = 0x40000
		SYMBOL_FONTTYPE = 0x80000

		class CHOOSEFONT < FFI::Struct
			layout \
				:lStructSize, :ulong,
				:hwndOwner, :pointer,
				:hDC, :pointer,
				:lpLogFont, :pointer,
				:iPointSize, :int,
				:Flags, :ulong,
				:rgbColors, :ulong,
				:lCustData, :long,
				:lpfnHook, :CFHOOKPROC,
				:lpTemplateName, :pointer,
				:hInstance, :pointer,
				:lpszStyle, :pointer,
				:nFontType, :ushort,
				:___MISSING_ALIGNMENT__, :ushort,
				:nSizeMin, :int,
				:nSizeMax, :int
		end

		attach_function :ChooseFont, :ChooseFontA, [:pointer], :int

		WM_CHOOSEFONT_GETLOGFONT = WM_USER + 1
		WM_CHOOSEFONT_SETLOGFONT = WM_USER + 101
		WM_CHOOSEFONT_SETFLAGS = WM_USER + 102
	end

	class FontDialog < CommonDialog
		DialogStruct = Windows::CHOOSEFONT

		HookProc = -> *args { CommonDialog::HookProc.(*args.unshift(DialogStruct)) }

		def initialize(opts = {})
			_opts = {
				font: Control::Font,
				color: 0
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = DialogStruct.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:lpLogFont] = _opts[:font].logfont.pointer
			@struct[:Flags] = Fzeet.flags([:enablehook, :both, :inittologfontstruct, :effects], :cf_)
			@struct[:rgbColors] = _opts[:color]
			@struct[:lCustData] = object_id
			@struct[:lpfnHook] = HookProc

			super()
		end

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.ChooseFont(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end

		def font; IndirectFont.new(Windows::LOGFONT.new(@struct[:lpLogFont])) end
		def color; @struct[:rgbColors] end
	end
end
