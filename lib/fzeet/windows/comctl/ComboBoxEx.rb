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
		CBES_EX_NOEDITIMAGE = 0x00000001
		CBES_EX_NOEDITIMAGEINDENT = 0x00000002
		CBES_EX_PATHWORDBREAKPROC = 0x00000004
		CBES_EX_NOSIZELIMIT = 0x00000008
		CBES_EX_CASESENSITIVE = 0x00000010
		CBES_EX_TEXTENDELLIPSIS = 0x00000020

		CBEM_INSERTITEM = WM_USER + 1
		CBEM_SETIMAGELIST = WM_USER + 2
		CBEM_GETIMAGELIST = WM_USER + 3
		CBEM_GETITEM = WM_USER + 4
		CBEM_SETITEM = WM_USER + 5
		CBEM_DELETEITEM = CB_DELETESTRING
		CBEM_GETCOMBOCONTROL = WM_USER + 6
		CBEM_GETEDITCONTROL = WM_USER + 7
		CBEM_SETEXSTYLE = WM_USER + 8
		CBEM_SETEXTENDEDSTYLE = WM_USER + 14
		CBEM_GETEXSTYLE = WM_USER + 9
		CBEM_GETEXTENDEDSTYLE = WM_USER + 9
		CBEM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		CBEM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		CBEM_HASEDITCHANGED = WM_USER + 10
		CBEM_SETWINDOWTHEME = CCM_SETWINDOWTHEME

		CBEN_FIRST = 0x1_0000_0000 - 800
		CBEN_LAST = 0x1_0000_0000 - 830
		CBEN_GETDISPINFO = CBEN_FIRST - 0
		CBEN_INSERTITEM = CBEN_FIRST - 1
		CBEN_DELETEITEM = CBEN_FIRST - 2
		CBEN_BEGINEDIT = CBEN_FIRST - 4
		CBEN_ENDEDIT = CBEN_FIRST - 5
		CBEN_DRAGBEGIN = CBEN_FIRST - 8

		CBEIF_TEXT = 0x00000001
		CBEIF_IMAGE = 0x00000002
		CBEIF_SELECTEDIMAGE = 0x00000004
		CBEIF_OVERLAY = 0x00000008
		CBEIF_INDENT = 0x00000010
		CBEIF_LPARAM = 0x00000020
		CBEIF_DI_SETITEM = 0x10000000

		class COMBOBOXEXITEM < FFI::Struct
			layout \
				:mask, :uint,
				:iItem, :int,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iImage, :int,
				:iSelectedImage, :int,
				:iOverlay, :int,
				:iIndent, :int,
				:lParam, :long
		end

		class NMCOMBOBOXEX < FFI::Struct
			layout \
				:hdr, NMHDR,
				:ceItem, COMBOBOXEXITEM
		end
	end

	module ComboBoxExMethods
		include ComboBoxMethods

	end

	class ComboBoxEx < Control
		include ComboBoxExMethods

		Prefix = {
			xstyle: [:cbes_ex_, :ws_ex_],
			style: [:cbs_, :ws_],
			message: [:cb_, :cbem_, :ccm_, :wm_],
			notification: [:cbn_, :cben_, :nm_]
		}

		def initialize(parent, id, opts = {}, &block)
			super('ComboBoxEx32', parent, id, opts)

			@parent.on(:command, @id, &block) if block
		end

		def on(notification, &block)
			if (notification = Fzeet.constant(notification, *self.class::Prefix[:notification])) < Windows::CBEN_LAST
				@parent.on(:command, @id, notification, &block)
			else
				@parent.on(:notify, @id, notification, &block)
			end

			self
		end
	end
end
