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

require_relative 'windows/libc'

require_relative 'windows/kernel'
require_relative 'windows/user'
require_relative 'windows/gdi'

require_relative 'windows/comctl'
require_relative 'windows/scintilla' if Fzeet::Windows::Version >= :xp
require_relative 'windows/comdlg'

require_relative 'windows/com'

require_relative 'windows/ole'
require_relative 'windows/oleaut'
require_relative 'windows/shell'
require_relative 'windows/shlwapi'
require_relative 'windows/shdocvw'
require_relative 'windows/mshtml'
require_relative 'windows/urlmon'

require_relative 'windows/propsys' if Fzeet::Windows::Version >= :vista

require_relative 'windows/uiribbon' if Fzeet::Windows::Version >= :vista

Fzeet::Windows.DetonateLastError(FFI::Pointer::NULL,
	:LoadLibrary,
	"#{File.dirname(File.expand_path(__FILE__))}/windows/scintilla/SciLexer.dll"
).tap { |hdll| at_exit { Fzeet::Windows.FreeLibrary(hdll) } } if Fzeet::Windows::Version >= :xp

module Fzeet
	class Application
		@name = File.basename($0, '.rbw')
		@version = '0.1.0'
		@authors = []

		@quitWhenMainWindowCloses = true

		@window = nil
		@accelerators = []
		@dialogs = []
		@images = {}
		Fzeet.using(ScreenDC.new) { |dc|
			@devcaps = {
				logpixelsy: Windows.GetDeviceCaps(dc.handle, Windows::LOGPIXELSY)
			}
		}

		class << self
			attr_accessor :name, :version, :authors, :quitWhenMainWindowCloses
			attr_reader :window, :accelerators, :dialogs, :images, :devcaps
		end

		def self.window=(window)
			raise 'Application.window already set.' if @window

			@window = window
		end

		def self.run(windowOrOpts = {}, &block)
			@window = case windowOrOpts
			when BasicWindow; windowOrOpts.tap { |window| block.call(window) if block }
			when Hash
				if windowOrOpts[:deferCreateWindow].tap { windowOrOpts.delete_if { |k, v| k == :deferCreateWindow } }
					Window.new(windowOrOpts, &block)
				else
					Window.new(windowOrOpts).tap { |window| block.call(window) if block }
				end
			else raise ArgumentError
			end

			return 0 if window.handle.null?

			@window.on(:destroy) { quit } if @quitWhenMainWindowCloses

			@window.show.update

			msg = Message.new

			while msg.get!
				msg.translate.dispatch unless
					(window.client && Windows.TranslateMDISysAccel(window.client.handle, msg) != 0) ||
					accelerators.any? { |table| table.translate?(msg, @window) } ||
					dialogs.any? { |dialog| dialog.dlgmsg?(msg) }
			end

			msg[:wParam]
		rescue
			Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, icon: :error
		end

		def self.quit(code = 0)
			accelerators.each(&:dispose)
			images.values.each(&:dispose)

			Windows.PostQuitMessage(code)
		end
	end
end
