require 'fzeet'

include Fzeet::Windows

Fzeet::Application.run { |window|
	def onItem1(*args)
		Fzeet.message __method__

		UIF.SetUICommandProperty(CmdButton1, UI_PKEY_Enabled, PROPVARIANT[:bool, true])
		UIF.SetUICommandProperty(CmdItem1, UI_PKEY_Enabled, PROPVARIANT[:bool, false])
	end

	def onButton1(*args)
		Fzeet.message __method__

		UIF.SetUICommandProperty(CmdItem1, UI_PKEY_Enabled, PROPVARIANT[:bool, true])
		UIF.SetUICommandProperty(CmdButton1, UI_PKEY_Enabled, PROPVARIANT[:bool, false])
	end

	UICH = UICommandHandler.new

	def UICH.Execute(*args)
		case args[0]
		when CmdItem1
			onItem1(*args)
		when CmdButton1
			onButton1(*args)
		end

		S_OK
	end

	UIA = UIApplication.new

	def UIA.OnCreateUICommand(*args)
		UICH.QueryInterface(UICH.class::IID, args[-1])

		S_OK
	end

	UIF = UIFramework.new

	UIF.Initialize(window.handle, UIA)
	UIF.LoadUI(LoadRibbonDll(), "APPLICATION_RIBBON\0".encode('utf-16le'))

	window.on(:destroy) {
		raise unless UIF.Destroy == S_OK; raise unless UIF.Release == 0
		raise unless UIA.Release == 0
		raise unless UICH.Release == 0
	}
}
