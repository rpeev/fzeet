require 'fzeet'

include Fzeet

Application.name += " - #{name = ARGV[0] || 'Minimal'}.xml"

Application.run { |window|
	UIRibbon.new(window, name: name)
}
