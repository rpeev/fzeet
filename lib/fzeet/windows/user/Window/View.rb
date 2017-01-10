require_relative 'Common'

module Fzeet
	View = BasicWindow['Fzeet.View',
		style: [:hredraw, :vredraw]
	]

	class View
		def initialize(opts = {})
			(opts[:style] ||= []) << :overlappedwindow << :clipsiblings << :clipchildren

			super
		end
	end
end
