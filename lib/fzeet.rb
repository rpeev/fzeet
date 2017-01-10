require_relative 'fzeet/windows'

module Fzeet
	VERSION = '0.6.7'

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

if __FILE__ == $0
	puts Fzeet::VERSION
end
