require_relative 'Common'

module Fzeet
	module Windows
		class BSTR
			def self.[](s)
				bstr = new(Windows.SysAllocString("#{s}\0".encode('utf-16le')))

				if block_given?
					yield bstr; bstr.dispose; return nil
				end

				bstr
			end

			class << self
				alias from []
			end

			def initialize(pointer) @pointer = pointer end

			attr_reader :pointer

			def free; Windows.SysFreeString(@pointer) end
			alias dispose free

			def length; Windows.SysStringLen(@pointer) end
			alias size length

			def multibyte; Windows.WCSTOMBS(@pointer) end
		end

		attach_function :SysAllocString, [:buffer_in], :pointer
		attach_function :SysFreeString, [:pointer], :void
		attach_function :SysStringLen, [:pointer], :uint
	end

	Bstr = Windows::BSTR
end
