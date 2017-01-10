require_relative 'Common'

module Fzeet
	module Windows
		MB_OK = 0x00000000
		MB_OKCANCEL = 0x00000001
		MB_ABORTRETRYIGNORE = 0x00000002
		MB_YESNOCANCEL = 0x00000003
		MB_YESNO = 0x00000004
		MB_RETRYCANCEL = 0x00000005
		MB_CANCELTRYCONTINUE = 0x00000006
		MB_ICONHAND = 0x00000010
		MB_ICONQUESTION = 0x00000020
		MB_ICONEXCLAMATION = 0x00000030
		MB_ICONASTERISK = 0x00000040
		MB_USERICON = 0x00000080
		MB_ICONWARNING = MB_ICONEXCLAMATION
		MB_ICONERROR = MB_ICONHAND
		MB_ICONINFORMATION = MB_ICONASTERISK
		MB_ICONSTOP = MB_ICONHAND
		MB_DEFBUTTON1 = 0x00000000
		MB_DEFBUTTON2 = 0x00000100
		MB_DEFBUTTON3 = 0x00000200
		MB_DEFBUTTON4 = 0x00000300
		MB_APPLMODAL = 0x00000000
		MB_SYSTEMMODAL = 0x00001000
		MB_TASKMODAL = 0x00002000
		MB_HELP = 0x00004000
		MB_NOFOCUS = 0x00008000
		MB_SETFOREGROUND = 0x00010000
		MB_DEFAULT_DESKTOP_ONLY = 0x00020000
		MB_TOPMOST = 0x00040000
		MB_RIGHT = 0x00080000
		MB_RTLREADING = 0x00100000
		MB_SERVICE_NOTIFICATION = 0x00200000
		MB_SERVICE_NOTIFICATION_NT3X = 0x00040000
		MB_TYPEMASK = 0x0000000F
		MB_ICONMASK = 0x000000F0
		MB_DEFMASK = 0x00000F00
		MB_MODEMASK = 0x00003000
		MB_MISCMASK = 0x0000C000

		IDOK = 1
		IDCANCEL = 2
		IDABORT = 3
		IDRETRY = 4
		IDIGNORE = 5
		IDYES = 6
		IDNO = 7
		IDCLOSE = 8
		IDHELP = 9
		IDTRYAGAIN = 10
		IDCONTINUE = 11
		IDTIMEOUT = 32000

		attach_function :MessageBox, :MessageBoxA, [:pointer, :string, :string, :uint], :int
	end

	class DialogResult
		def initialize(id)
			@id = id
		end

		attr_reader :id

		Windows.constants.grep(/^ID[A-Z]{2,}$/).each { |c|
			define_method("#{c[2..-1].downcase}?") {
				@id == Windows.const_get(c)
			}
		}
	end

	def message(message, opts = {})
		_opts = {
			window: Application.window,
			caption: Application.name,
			buttons: [:ok],
			icon: :information
		}
		badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
		_opts.merge!(opts)

		defbutton = nil
		defbutton = if [*_opts[:buttons]].find.with_index { |button, i| defbutton = i + 1; button =~ /^[A-Z]/ }
			constant(defbutton.to_s, :mb_defbutton)
		else
			0
		end

		flags = constant([*_opts[:buttons]].join(''), :mb_) | defbutton | constant(_opts[:icon], :mb_icon)

		DialogResult.new(
			Windows.DetonateLastError(0, :MessageBox, _opts[:window] && _opts[:window].handle, message.to_s, _opts[:caption].to_s, flags)
		)
	end

	def question(message, opts = {})
		opts[:buttons] ||= [:yes, :no]
		opts[:icon] ||= :question

		message(message, opts)
	end

	module_function :message, :question
end
