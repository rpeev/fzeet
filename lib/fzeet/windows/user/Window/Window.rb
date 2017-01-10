require_relative 'Common'

module Fzeet
	Window = BasicWindow['Fzeet.Window']

	class Window
		def initialize(opts = {})
			(opts[:style] ||= []) << :overlappedwindow << :clipsiblings << :clipchildren

			super
		end
	end
end
