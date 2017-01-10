require_relative 'core'

module Fzeet
	module Windows
		ffi_lib FFI::Library::LIBC
		ffi_convention :cdecl

		attach_function :memcmp, [:pointer, :pointer, :uint], :int

		attach_function :wcslen, [:buffer_in], :uint
		attach_function :mbstowcs, [:pointer, :string, :uint], :uint
		attach_function :wcstombs, [:pointer, :buffer_in, :uint], :uint
	end
end
