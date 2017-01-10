require 'fzeet'

include Fzeet

Application.run { |window|
	UIRibbon.new(window,
		[:update, :CmdSpinner1] => proc { |args|
			case args[:key]
			when Windows::UI_PKEY_DecimalPlaces
				args[:newValue].uint = 2
			when Windows::UI_PKEY_RepresentativeString
				args[:newValue].wstring = '00.00em'
			when Windows::UI_PKEY_FormatString
				args[:newValue].wstring = 'em'
			when Windows::UI_PKEY_MinValue
				args[:newValue].decimal = 1
			when Windows::UI_PKEY_MaxValue
				args[:newValue].decimal = 10
			when Windows::UI_PKEY_Increment
				args[:newValue].decimal = 3
			end
		}
	).
		on(:execute, CmdSpinner1) { |args|
			message args[:value].decimal.to_f
		}
}
