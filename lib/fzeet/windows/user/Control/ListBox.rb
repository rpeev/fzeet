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

if __FILE__ == $0
	require_relative '../Window/Common'
end
require_relative 'Common'

module Fzeet
	module Windows
		LBS_NOTIFY = 0x0001
		LBS_SORT = 0x0002
		LBS_NOREDRAW = 0x0004
		LBS_MULTIPLESEL = 0x0008
		LBS_OWNERDRAWFIXED = 0x0010
		LBS_OWNERDRAWVARIABLE = 0x0020
		LBS_HASSTRINGS = 0x0040
		LBS_USETABSTOPS = 0x0080
		LBS_NOINTEGRALHEIGHT = 0x0100
		LBS_MULTICOLUMN = 0x0200
		LBS_WANTKEYBOARDINPUT = 0x0400
		LBS_EXTENDEDSEL = 0x0800
		LBS_DISABLENOSCROLL = 0x1000
		LBS_NODATA = 0x2000
		LBS_NOSEL = 0x4000
		LBS_COMBOBOX = 0x8000
		LBS_STANDARD = LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER

		LB_CTLCODE = 0
		LB_OKAY = 0
		LB_ERR = -1
		LB_ERRSPACE = -2
		LB_ADDSTRING = 0x0180
		LB_INSERTSTRING = 0x0181
		LB_DELETESTRING = 0x0182
		LB_SELITEMRANGEEX = 0x0183
		LB_RESETCONTENT = 0x0184
		LB_SETSEL = 0x0185
		LB_SETCURSEL = 0x0186
		LB_GETSEL = 0x0187
		LB_GETCURSEL = 0x0188
		LB_GETTEXT = 0x0189
		LB_GETTEXTLEN = 0x018A
		LB_GETCOUNT = 0x018B
		LB_SELECTSTRING = 0x018C
		LB_DIR = 0x018D
		LB_GETTOPINDEX = 0x018E
		LB_FINDSTRING = 0x018F
		LB_GETSELCOUNT = 0x0190
		LB_GETSELITEMS = 0x0191
		LB_SETTABSTOPS = 0x0192
		LB_GETHORIZONTALEXTENT = 0x0193
		LB_SETHORIZONTALEXTENT = 0x0194
		LB_SETCOLUMNWIDTH = 0x0195
		LB_ADDFILE = 0x0196
		LB_SETTOPINDEX = 0x0197
		LB_GETITEMRECT = 0x0198
		LB_GETITEMDATA = 0x0199
		LB_SETITEMDATA = 0x019A
		LB_SELITEMRANGE = 0x019B
		LB_SETANCHORINDEX = 0x019C
		LB_GETANCHORINDEX = 0x019D
		LB_SETCARETINDEX = 0x019E
		LB_GETCARETINDEX = 0x019F
		LB_SETITEMHEIGHT = 0x01A0
		LB_GETITEMHEIGHT = 0x01A1
		LB_FINDSTRINGEXACT = 0x01A2
		LB_SETLOCALE = 0x01A5
		LB_GETLOCALE = 0x01A6
		LB_SETCOUNT = 0x01A7
		LB_INITSTORAGE = 0x01A8
		LB_ITEMFROMPOINT = 0x01A9
		LB_MULTIPLEADDSTRING = 0x01B1
		LB_GETLISTBOXINFO = 0x01B2
		LB_MSGMAX = 0x01B3

		LBN_ERRSPACE = -2
		LBN_SELCHANGE = 1
		LBN_DBLCLK = 2
		LBN_SELCANCEL = 3
		LBN_SETFOCUS = 4
		LBN_KILLFOCUS = 5
	end

	module ListBoxMethods
		def textlen(i) raise "GETTEXTLEN failed." if (len = sendmsg(:gettextlen, i)) == -1; len end

		def [](i)
			i = sendmsg(:getcursel) if i == :selected

			return '' if i == -1 || (len = textlen(i) + 1) == 1

			''.tap { |item|
				FFI::MemoryPointer.new(:char, len) { |buf|
					raise "GETTEXT failed." if sendmsg(:gettext, i, buf) == -1

					item << buf.read_string
				}
			}
		end

		def clear; sendmsg(:resetcontent); self end

		def append(items)
			[*items].each { |item|
				p = FFI::MemoryPointer.from_string(item.to_s)

				raise 'ADDSTRING failed.' if [-1, -2].include?(sendmsg(:addstring, 0, p).tap { p.free })
			}

			self
		end

		def selected=(i)
			i = case i
			when -1;     0xffffffff
			when :first; 0
			when :last;  length - 1
			else         i
			end

			raise 'SETCURSEL failed.' if sendmsg(:setcursel, i) == -1 && i != 0xffffffff

			self
		end

		def length; raise 'GETCOUNT failed.' if (len = sendmsg(:getcount)) == -1; len end
		def each; length.times { |i| yield self[i] }; self end
	end

	class ListBox < Control
		include ListBoxMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:lbs_, :ws_],
			message: [:lb_, :wm_],
			notification: [:lbn_]
		}

		def initialize(parent, id, opts = {}, &block)
			super('ListBox', parent, id, opts)

			@parent.on(:command, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:command, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
