if __FILE__ == $0
	require_relative '../Window/Common'
end
require_relative 'ListBox'

module Fzeet
	module Windows
		CBS_SIMPLE = 0x0001
		CBS_DROPDOWN = 0x0002
		CBS_DROPDOWNLIST = 0x0003
		CBS_OWNERDRAWFIXED = 0x0010
		CBS_OWNERDRAWVARIABLE = 0x0020
		CBS_AUTOHSCROLL = 0x0040
		CBS_OEMCONVERT = 0x0080
		CBS_SORT = 0x0100
		CBS_HASSTRINGS = 0x0200
		CBS_NOINTEGRALHEIGHT = 0x0400
		CBS_DISABLENOSCROLL = 0x0800
		CBS_UPPERCASE = 0x2000
		CBS_LOWERCASE = 0x4000

		CB_OKAY = 0
		CB_ERR = -1
		CB_ERRSPACE = -2
		CB_GETEDITSEL = 0x0140
		CB_LIMITTEXT = 0x0141
		CB_SETEDITSEL = 0x0142
		CB_ADDSTRING = 0x0143
		CB_DELETESTRING = 0x0144
		CB_DIR = 0x0145
		CB_GETCOUNT = 0x0146
		CB_GETCURSEL = 0x0147
		CB_GETLBTEXT = 0x0148
		CB_GETLBTEXTLEN = 0x0149
		CB_INSERTSTRING = 0x014A
		CB_RESETCONTENT = 0x014B
		CB_FINDSTRING = 0x014C
		CB_SELECTSTRING = 0x014D
		CB_SETCURSEL = 0x014E
		CB_SHOWDROPDOWN = 0x014F
		CB_GETITEMDATA = 0x0150
		CB_SETITEMDATA = 0x0151
		CB_GETDROPPEDCONTROLRECT = 0x0152
		CB_SETITEMHEIGHT = 0x0153
		CB_GETITEMHEIGHT = 0x0154
		CB_SETEXTENDEDUI = 0x0155
		CB_GETEXTENDEDUI = 0x0156
		CB_GETDROPPEDSTATE = 0x0157
		CB_FINDSTRINGEXACT = 0x0158
		CB_SETLOCALE = 0x0159
		CB_GETLOCALE = 0x015A
		CB_GETTOPINDEX = 0x015b
		CB_SETTOPINDEX = 0x015c
		CB_GETHORIZONTALEXTENT = 0x015d
		CB_SETHORIZONTALEXTENT = 0x015e
		CB_GETDROPPEDWIDTH = 0x015f
		CB_SETDROPPEDWIDTH = 0x0160
		CB_INITSTORAGE = 0x0161
		CB_MULTIPLEADDSTRING = 0x0163
		CB_GETCOMBOBOXINFO = 0x0164
		CB_MSGMAX = 0x0165

		CBN_ERRSPACE = -1
		CBN_SELCHANGE = 1
		CBN_DBLCLK = 2
		CBN_SETFOCUS = 3
		CBN_KILLFOCUS = 4
		CBN_EDITCHANGE = 5
		CBN_EDITUPDATE = 6
		CBN_DROPDOWN = 7
		CBN_CLOSEUP = 8
		CBN_SELENDOK = 9
		CBN_SELENDCANCEL = 10
	end

	module ComboBoxMethods
		include ListBoxMethods

		def textlen(i) raise "GETLBTEXTLEN failed." if (len = sendmsg(:getlbtextlen, i)) == -1; len end

		def [](i)
			i = sendmsg(:getcursel) if i == :selected

			return '' if i == -1 || (len = textlen(i) + 1) == 1

			''.tap { |item|
				FFI::MemoryPointer.new(:char, len) { |buf|
					raise "GETLBTEXT failed." if sendmsg(:getlbtext, i, buf) == -1

					item << buf.read_string
				}
			}
		end
	end

	class ComboBox < Control
		include ComboBoxMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:cbs_, :ws_],
			message: [:cb_, :wm_],
			notification: [:cbn_]
		}

		def initialize(parent, id, opts = {}, &block)
			super('ComboBox', parent, id, opts)

			@parent.on(:command, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:command, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
