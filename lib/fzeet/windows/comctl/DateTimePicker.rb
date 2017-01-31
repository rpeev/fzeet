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
		DTS_UPDOWN = 0x0001
		DTS_SHOWNONE = 0x0002
		DTS_SHORTDATEFORMAT = 0x0000
		DTS_LONGDATEFORMAT = 0x0004
		DTS_SHORTDATECENTURYFORMAT = 0x000C
		DTS_TIMEFORMAT = 0x0009
		DTS_APPCANPARSE = 0x0010
		DTS_RIGHTALIGN = 0x0020

		DTM_FIRST = 0x1000
		DTM_GETSYSTEMTIME = DTM_FIRST + 1
		DTM_SETSYSTEMTIME = DTM_FIRST + 2
		DTM_GETRANGE = DTM_FIRST + 3
		DTM_SETRANGE = DTM_FIRST + 4
		DTM_SETFORMAT = DTM_FIRST + 5
		DTM_SETMCCOLOR = DTM_FIRST + 6
		DTM_GETMCCOLOR = DTM_FIRST + 7
		DTM_GETMONTHCAL = DTM_FIRST + 8
		DTM_SETMCFONT = DTM_FIRST + 9
		DTM_GETMCFONT = DTM_FIRST + 10
		DTM_SETMCSTYLE = DTM_FIRST + 11
		DTM_GETMCSTYLE = DTM_FIRST + 12
		DTM_CLOSEMONTHCAL = DTM_FIRST + 13
		DTM_GETDATETIMEPICKERINFO = DTM_FIRST + 14
		DTM_GETIDEALSIZE = DTM_FIRST + 15

		DTN_FIRST = 0x1_0000_0000 - 740
		DTN_LAST = 0x1_0000_0000 - 745
		DTN_FIRST2 = 0x1_0000_0000 - 753
		DTN_LAST2 = 0x1_0000_0000 - 799
		DTN_DATETIMECHANGE = DTN_FIRST2 - 6
		DTN_USERSTRING = DTN_FIRST2 - 5
		DTN_WMKEYDOWN = DTN_FIRST2 - 4
		DTN_FORMAT = DTN_FIRST2 - 3
		DTN_FORMATQUERY = DTN_FIRST2 - 2
		DTN_DROPDOWN = DTN_FIRST2 - 1
		DTN_CLOSEUP = DTN_FIRST2

		GDT_ERROR = -1
		GDT_VALID = 0
		GDT_NONE = 1

		class NMDATETIMECHANGE < FFI::Struct
			layout \
				:nmhdr, NMHDR,
				:dwFlags, :ulong,
				:st, SYSTEMTIME
		end
	end

	module DateTimePickerMethods

	end

	class DateTimePicker < Control
		include DateTimePickerMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:dts_, :ws_],
			message: [:dtm_, :ccm_, :wm_],
			notification: [:dtn_, :nm_]
		}

		def self.crackNotification(args)
			case args[:notification]
			when Windows::DTN_DATETIMECHANGE
				args[:dtc] = Windows::NMDATETIMECHANGE.new(FFI::Pointer.new(args[:lParam]))
				args[:st] = args[:dtc][:st] if args[:dtc][:dwFlags] == Windows::GDT_VALID
			end
		end

		def initialize(parent, id, opts = {}, &block)
			super('SysDateTimePick32', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
