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

require_relative 'comctl/Button'
require_relative 'comctl/SysLink' if Fzeet::Windows::Version >= :xp
require_relative 'comctl/Edit'
require_relative 'comctl/UpDown'
require_relative 'comctl/MonthCalendar'
require_relative 'comctl/DateTimePicker'
require_relative 'comctl/ComboBox'
require_relative 'comctl/ComboBoxEx'
require_relative 'comctl/Header'
require_relative 'comctl/ListView'
require_relative 'comctl/TreeView'
require_relative 'comctl/ProgressBar'
require_relative 'comctl/PropertySheet'
require_relative 'comctl/Tab'
