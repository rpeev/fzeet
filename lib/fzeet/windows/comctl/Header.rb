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
		HDS_HORZ = 0x0000
		HDS_BUTTONS = 0x0002
		HDS_HOTTRACK = 0x0004
		HDS_HIDDEN = 0x0008
		HDS_DRAGDROP = 0x0040
		HDS_FULLDRAG = 0x0080
		HDS_FILTERBAR = 0x0100
		HDS_FLAT = 0x0200
		HDS_CHECKBOXES = 0x0400
		HDS_NOSIZING = 0x0800
		HDS_OVERFLOW = 0x1000

		HDM_FIRST = 0x1200
		HDM_GETITEMCOUNT = HDM_FIRST + 0
		HDM_INSERTITEM = HDM_FIRST + 1
		HDM_DELETEITEM = HDM_FIRST + 2
		HDM_GETITEM = HDM_FIRST + 3
		HDM_SETITEM = HDM_FIRST + 4
		HDM_LAYOUT = HDM_FIRST + 5
		HDM_HITTEST = HDM_FIRST + 6
		HDM_GETITEMRECT = HDM_FIRST + 7
		HDM_SETIMAGELIST = HDM_FIRST + 8
		HDM_GETIMAGELIST = HDM_FIRST + 9
		HDM_ORDERTOINDEX = HDM_FIRST + 15
		HDM_CREATEDRAGIMAGE = HDM_FIRST + 16
		HDM_GETORDERARRAY = HDM_FIRST + 17
		HDM_SETORDERARRAY = HDM_FIRST + 18
		HDM_SETHOTDIVIDER = HDM_FIRST + 19
		HDM_SETBITMAPMARGIN = HDM_FIRST + 20
		HDM_GETBITMAPMARGIN = HDM_FIRST + 21
		HDM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		HDM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		HDM_SETFILTERCHANGETIMEOUT = HDM_FIRST + 22
		HDM_EDITFILTER = HDM_FIRST + 23
		HDM_CLEARFILTER = HDM_FIRST + 24
		HDM_GETITEMDROPDOWNRECT = HDM_FIRST + 25
		HDM_GETOVERFLOWRECT = HDM_FIRST + 26
		HDM_GETFOCUSEDITEM = HDM_FIRST + 27
		HDM_SETFOCUSEDITEM = HDM_FIRST + 28

		HDN_FIRST = 0x1_0000_0000 - 300
		HDN_LAST = 0x1_0000_0000 - 399
		HDN_ITEMCHANGING = HDN_FIRST - 0
		HDN_ITEMCHANGED = HDN_FIRST - 1
		HDN_ITEMCLICK = HDN_FIRST - 2
		HDN_ITEMDBLCLICK = HDN_FIRST - 3
		HDN_DIVIDERDBLCLICK = HDN_FIRST - 5
		HDN_BEGINTRACK = HDN_FIRST - 6
		HDN_ENDTRACK = HDN_FIRST - 7
		HDN_TRACK = HDN_FIRST - 8
		HDN_GETDISPINFO = HDN_FIRST - 9
		HDN_BEGINDRAG = HDN_FIRST - 10
		HDN_ENDDRAG = HDN_FIRST - 11
		HDN_FILTERCHANGE = HDN_FIRST - 12
		HDN_FILTERBTNCLICK = HDN_FIRST - 13
		HDN_BEGINFILTEREDIT = HDN_FIRST - 14
		HDN_ENDFILTEREDIT = HDN_FIRST - 15
		HDN_ITEMSTATEICONCLICK = HDN_FIRST - 16
		HDN_ITEMKEYDOWN = HDN_FIRST - 17
		HDN_DROPDOWN = HDN_FIRST - 18
		HDN_OVERFLOWCLICK = HDN_FIRST - 19

		HDI_WIDTH = 0x0001
		HDI_HEIGHT = HDI_WIDTH
		HDI_TEXT = 0x0002
		HDI_FORMAT = 0x0004
		HDI_LPARAM = 0x0008
		HDI_BITMAP = 0x0010
		HDI_IMAGE = 0x0020
		HDI_DI_SETITEM = 0x0040
		HDI_ORDER = 0x0080
		HDI_FILTER = 0x0100
		HDI_STATE = 0x0200

		HDF_LEFT = 0x0000
		HDF_RIGHT = 0x0001
		HDF_CENTER = 0x0002
		HDF_JUSTIFYMASK = 0x0003
		HDF_RTLREADING = 0x0004
		HDF_BITMAP = 0x2000
		HDF_STRING = 0x4000
		HDF_OWNERDRAW = 0x8000
		HDF_IMAGE = 0x0800
		HDF_BITMAP_ON_RIGHT = 0x1000
		HDF_SORTUP = 0x0400
		HDF_SORTDOWN = 0x0200
		HDF_CHECKBOX = 0x0040
		HDF_CHECKED = 0x0080
		HDF_FIXEDWIDTH = 0x0100
		HDF_SPLITBUTTON = 0x1000000

		HDFT_ISSTRING = 0x0000
		HDFT_ISNUMBER = 0x0001
		HDFT_ISDATE = 0x0002
		HDFT_HASNOVALUE = 0x8000

		HDIS_FOCUSED = 0x00000001

		class HDITEM < FFI::Struct
			layout(*[
				:mask, :uint,
				:cxy, :int,
				:pszText, :pointer,
				:hbm, :pointer,
				:cchTextMax, :int,
				:fmt, :int,
				:lParam, :long,
				:iImage, :int,
				:iOrder, :int,
				:type, :uint,
				:pvFilter, :pointer,
				(Version >= :vista) ? [:state, :uint] : nil
			].flatten.compact)
		end

		class NMHEADER < FFI::Struct
			layout \
				:hdr, NMHDR,
				:iItem, :int,
				:iButton, :int,
				:pitem, :pointer
		end
	end

	module HeaderMethods
		Prefix = {
			xstyle: [:ws_ex_],
			style: [:hds_, :ws_],
			message: [:hdm_, :ccm_, :wm_],
			notification: [:hdn_, :nm_]
		}

		def count; sendmsg(:getitemcount) end

		def insertItem(i, text, width)
			hdi = Windows::HDITEM.new

			hdi[:mask] = Fzeet.flags([:width, :text, :format, :order], :hdi_)
			hdi[:cxy] = width
			hdi[:pszText] = ptext = FFI::MemoryPointer.from_string(text)
			hdi[:fmt] = Fzeet.flags([:left, :string], :hdf_)
			hdi[:iOrder] = i

			sendmsg(:insertitem, 0, hdi.pointer)

			self
		ensure
			ptext.free
		end

		def modifyItem(i, text, style = 0)
			hdi = Windows::HDITEM.new

			hdi[:mask] = Fzeet.flags([:text, :format], :hdi_)
			hdi[:pszText] = ptext = FFI::MemoryPointer.from_string(text)
			hdi[:fmt] = Fzeet.flags([:left, :string], :hdf_)
			hdi[:fmt] |= Fzeet.flags([*style].compact, :hdf_)

			sendmsg(:setitem, i, hdi.pointer)

			self
		ensure
			ptext.free
		end
	end

	class Header < Control
		include HeaderMethods

		def self.crackNotification(args) end

		def initialize(parent, id, opts = {}, &block)
			super('SysHeader32', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
