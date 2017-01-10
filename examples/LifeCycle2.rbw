require 'fzeet'

Fzeet::Application.run(deferCreateWindow: true) do |window|
	window.on :create do |args|
		args[:result] = -1 if Fzeet.question('Create?').no?
	end

	window.on :close do
		window.dispose if Fzeet.question('Close?', buttons: [:yes, :No]).yes?
	end

	window.on :destroy do
		Fzeet.message 'on(:destroy)'
	end
end
