Dir["#{File.dirname(path = File.expand_path(__FILE__))}/*.rb"].
	each { |test| next if test == path || test =~ /_test.rb$/; require test }
