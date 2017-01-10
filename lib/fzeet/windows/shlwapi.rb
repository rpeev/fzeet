require_relative 'core'

module Fzeet
	module Windows
		ffi_lib 'shlwapi'
		ffi_convention :stdcall

		attach_function :SHStrDup, :SHStrDupA, [:string, :pointer], :long
	end
end
