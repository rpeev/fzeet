require 'fzeet'

include Fzeet

class LifeCycle1Window < Window
	def initialize
		on :create, &method(:onCreate)
		on :close, &method(:onClose)
		on :destroy, &method(:onDestroy)

		super
	end

	def onCreate(args)
		args[:result] = -1 if question('Create?').no?
	end

	def onClose
		dispose if question('Close?', buttons: [:yes, :No]).yes?
	end

	def onDestroy
		message __method__
	end
end

Application.run(LifeCycle1Window.new)
