require_relative 'Common'

module Fzeet
	module Windows
		MCS_DAYSTATE = 0x0001
		MCS_MULTISELECT = 0x0002
		MCS_WEEKNUMBERS = 0x0004
		MCS_NOTODAYCIRCLE = 0x0008
		MCS_NOTODAY = 0x0010
		MCS_NOTRAILINGDATES = 0x0040
		MCS_SHORTDAYSOFWEEK = 0x0080
		MCS_NOSELCHANGEONNAV = 0x0100

		MCM_FIRST = 0x1000
		MCM_GETCURSEL = MCM_FIRST + 1
		MCM_SETCURSEL = MCM_FIRST + 2
		MCM_GETMAXSELCOUNT = MCM_FIRST + 3
		MCM_SETMAXSELCOUNT = MCM_FIRST + 4
		MCM_GETSELRANGE = MCM_FIRST + 5
		MCM_SETSELRANGE = MCM_FIRST + 6
		MCM_GETMONTHRANGE = MCM_FIRST + 7
		MCM_SETDAYSTATE = MCM_FIRST + 8
		MCM_GETMINREQRECT = MCM_FIRST + 9
		MCM_SETCOLOR = MCM_FIRST + 10
		MCM_GETCOLOR = MCM_FIRST + 11
		MCM_SETTODAY = MCM_FIRST + 12
		MCM_GETTODAY = MCM_FIRST + 13
		MCM_HITTEST = MCM_FIRST + 14
		MCM_SETFIRSTDAYOFWEEK = MCM_FIRST + 15
		MCM_GETFIRSTDAYOFWEEK = MCM_FIRST + 16
		MCM_GETRANGE = MCM_FIRST + 17
		MCM_SETRANGE = MCM_FIRST + 18
		MCM_GETMONTHDELTA = MCM_FIRST + 19
		MCM_SETMONTHDELTA = MCM_FIRST + 20
		MCM_GETMAXTODAYWIDTH = MCM_FIRST + 21
		MCM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		MCM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		MCM_GETCURRENTVIEW = MCM_FIRST + 22
		MCM_GETCALENDARCOUNT = MCM_FIRST + 23
		MCM_GETCALENDARGRIDINFO = MCM_FIRST + 24
		MCM_GETCALID = MCM_FIRST + 27
		MCM_SETCALID = MCM_FIRST + 28
		MCM_SIZERECTTOMIN = MCM_FIRST + 29
		MCM_SETCALENDARBORDER = MCM_FIRST + 30
		MCM_GETCALENDARBORDER = MCM_FIRST + 31
		MCM_SETCURRENTVIEW = MCM_FIRST + 32

		MCN_FIRST = 0x1_0000_0000 - 746
		MCN_LAST = 0x1_0000_0000 - 752
		MCN_SELCHANGE = MCN_FIRST - 3
		MCN_GETDAYSTATE = MCN_FIRST - 1
		MCN_SELECT = MCN_FIRST
		MCN_VIEWCHANGE = MCN_FIRST - 4

		class NMSELCHANGE < FFI::Struct
			layout \
				:nmhdr, NMHDR,
				:stSelStart, SYSTEMTIME,
				:stSelEnd, SYSTEMTIME
		end
	end

	module MonthCalendarMethods

	end

	class MonthCalendar < Control
		include MonthCalendarMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:mcs_, :ws_],
			message: [:mcm_, :ccm_, :wm_],
			notification: [:mcn_, :nm_]
		}

		def self.crackNotification(args)
			case args[:notification]
			when Windows::MCN_SELCHANGE
				args[:sc] = Windows::NMSELCHANGE.new(FFI::Pointer.new(args[:lParam]))
				args[:st1], args[:st2] = args[:sc][:stSelStart], args[:sc][:stSelEnd]
			end
		end

		def initialize(parent, id, opts = {}, &block)
			super('SysMonthCal32', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
