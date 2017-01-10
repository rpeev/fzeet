require_relative 'Common'

module Fzeet
	module Windows
		TCS_SCROLLOPPOSITE = 0x0001
		TCS_BOTTOM = 0x0002
		TCS_RIGHT = 0x0002
		TCS_MULTISELECT = 0x0004
		TCS_FLATBUTTONS = 0x0008
		TCS_FORCEICONLEFT = 0x0010
		TCS_FORCELABELLEFT = 0x0020
		TCS_HOTTRACK = 0x0040
		TCS_VERTICAL = 0x0080
		TCS_TABS = 0x0000
		TCS_BUTTONS = 0x0100
		TCS_SINGLELINE = 0x0000
		TCS_MULTILINE = 0x0200
		TCS_RIGHTJUSTIFY = 0x0000
		TCS_FIXEDWIDTH = 0x0400
		TCS_RAGGEDRIGHT = 0x0800
		TCS_FOCUSONBUTTONDOWN = 0x1000
		TCS_OWNERDRAWFIXED = 0x2000
		TCS_TOOLTIPS = 0x4000
		TCS_FOCUSNEVER = 0x8000

		TCS_EX_FLATSEPARATORS = 0x00000001
		TCS_EX_REGISTERDROP = 0x00000002

		TCM_FIRST = 0x1300
		TCM_GETIMAGELIST = TCM_FIRST + 2
		TCM_SETIMAGELIST = TCM_FIRST + 3
		TCM_GETITEMCOUNT = TCM_FIRST + 4
		TCM_GETITEM = TCM_FIRST + 5
		TCM_SETITEM = TCM_FIRST + 6
		TCM_INSERTITEM = TCM_FIRST + 7
		TCM_DELETEITEM = TCM_FIRST + 8
		TCM_DELETEALLITEMS = TCM_FIRST + 9
		TCM_GETITEMRECT = TCM_FIRST + 10
		TCM_GETCURSEL = TCM_FIRST + 11
		TCM_SETCURSEL = TCM_FIRST + 12
		TCM_HITTEST = TCM_FIRST + 13
		TCM_SETITEMEXTRA = TCM_FIRST + 14
		TCM_ADJUSTRECT = TCM_FIRST + 40
		TCM_SETITEMSIZE = TCM_FIRST + 41
		TCM_REMOVEIMAGE = TCM_FIRST + 42
		TCM_SETPADDING = TCM_FIRST + 43
		TCM_GETROWCOUNT = TCM_FIRST + 44
		TCM_GETTOOLTIPS = TCM_FIRST + 45
		TCM_SETTOOLTIPS = TCM_FIRST + 46
		TCM_GETCURFOCUS = TCM_FIRST + 47
		TCM_SETCURFOCUS = TCM_FIRST + 48
		TCM_SETMINTABWIDTH = TCM_FIRST + 49
		TCM_DESELECTALL = TCM_FIRST + 50
		TCM_HIGHLIGHTITEM = TCM_FIRST + 51
		TCM_SETEXTENDEDSTYLE = TCM_FIRST + 52
		TCM_GETEXTENDEDSTYLE = TCM_FIRST + 53
		TCM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		TCM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT

		TCN_FIRST = 0x1_0000_0000 - 550
		TCN_LAST = 0x1_0000_0000 - 580
		TCN_KEYDOWN = TCN_FIRST - 0
		TCN_SELCHANGE = TCN_FIRST - 1
		TCN_SELCHANGING = TCN_FIRST - 2
		TCN_GETOBJECT = TCN_FIRST - 3
		TCN_FOCUSCHANGE = TCN_FIRST - 4

		TCIF_TEXT = 0x0001
		TCIF_IMAGE = 0x0002
		TCIF_RTLREADING = 0x0004
		TCIF_PARAM = 0x0008
		TCIF_STATE = 0x0010

		TCIS_BUTTONPRESSED = 0x0001
		TCIS_HIGHLIGHTED = 0x0002

		class TCITEM < FFI::Struct
			layout \
				:mask, :uint,
				:dwState, :ulong,
				:dwStateMask, :ulong,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iImage, :int,
				:lParam, :long
		end
	end

	module TabMethods
		class Item
			def initialize(tab, i) @tab, @index = tab, i end

			attr_reader :tab, :index
		end

		def [](i) Item.new(self, i) end

		def count; sendmsg(:getitemcount) end
		alias :size :count
		alias :length :count

		def insert(text, i = count)
			tci = Windows::TCITEM.new

			tci[:mask] = Fzeet.flags(:text, :tcif_)
			tci[:pszText] = ptext = FFI::MemoryPointer.from_string(text)

			sendmsg(:insertitem, i, tci.pointer)

			self
		ensure
			ptext.free
		end

		def current; self[sendmsg(:getcursel)] end
	end

	class Tab < Control
		include TabMethods

		Prefix = {
			xstyle: [:tcs_ex_, :ws_ex_],
			style: [:tcs_, :ws_],
			message: [:tcm_, :ccm_, :wm_],
			notification: [:tcn_, :nm_]
		}

		def self.crackNotification(args) end

		def initialize(parent, id, opts = {}, &block)
			super('SysTabControl32', parent, id, opts)

			style << :clipsiblings

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
