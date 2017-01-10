require File.expand_path('../lib/fzeet', __FILE__) # require_relative doesn't work here in ruby 1.9
require 'rake'

Gem::Specification.new do |s|
  s.name = 'fzeet'
  s.version = Fzeet::VERSION

  s.summary = 'Ruby-FFI (x86) bindings to (plus rubyesque APIs on top) GUI/COM-related Windows APIs'
  s.description = 'Ruby-FFI (x86) bindings to (plus rubyesque APIs on top) GUI/COM-related Windows APIs'
  s.homepage = 'https://github.com/rpeev/fzeet'

  s.authors = ['Radoslav Peev']
  s.email = ['rpeev@ymail.com']
  s.licenses = ['MIT']

  s.files = FileList[
    'LICENSE', 'LICENSE_Scintilla',
    'README.md', 'screenshot.png',
    'RELNOTES.md',
    'lib/fzeet.rb',
    'lib/fzeet/*.rb',
    'lib/fzeet/windows/*.rb',
    'lib/fzeet/windows/core/*.rb',
    'lib/fzeet/windows/kernel/*.rb',
    'lib/fzeet/windows/gdi/*.rb',
    'lib/fzeet/windows/user/*.rb',
    'lib/fzeet/windows/user/Window/*.rb',
    'lib/fzeet/windows/user/Control/*.rb',
    'lib/fzeet/windows/comctl/*.rb',
    'lib/fzeet/windows/comdlg/*.rb',
    'lib/fzeet/windows/com/*.rb',
    'lib/fzeet/windows/ole/*.rb',
    'lib/fzeet/windows/oleaut/*.rb',
    'lib/fzeet/windows/shell/*.rb',
    'lib/fzeet/windows/mshtml/*.rb',
    'lib/fzeet/windows/scintilla/*.*',
    'examples/*.*', 'examples/res/*.*',
    'examples/Raw/*.*', 'examples/Raw/UIRibbon/*.*',
    'examples/Menu/*.*',
    'examples/Control/*.*', 'examples/Control/WebBrowser/*.*',
    'examples/Dialog/*.*',
    'examples/UIRibbon/*.*', 'examples/UIRibbon/Control/*.*'
  ]
  s.require_paths = ['lib']
  s.add_runtime_dependency('ffi', '~> 1')
end
