require 'sinatra'

get('/') { '' }

get('/hello') {
	headers 'Access-Control-Allow-Origin' => '*'

	'Hello, world!'
}
