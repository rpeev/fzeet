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

require_relative 'fzeet/windows'

FZEET_VERSION = '0.7.0'

module Fzeet
	module Windows
		DetonateLastError(0, :InitCommonControlsEx,
			INITCOMMONCONTROLSEX.new.tap { |icc|
				icc[:dwSize] = icc.size
				icc[:dwICC] = \
					ICC_WIN95_CLASSES |
					ICC_DATE_CLASSES |
					ICC_USEREX_CLASSES |
					ICC_COOL_CLASSES |
					ICC_INTERNET_CLASSES |
					ICC_PAGESCROLLER_CLASS
			}
		)

		EnableVisualStyles()

		DetonateLastError(0, :SetProcessDPIAware) if Version >= :vista

		InitializeOle()
	end
end
