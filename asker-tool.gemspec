require_relative 'lib/asker/application'

Gem::Specification.new do |s|
  s.name        = Application::GEM
  s.version     = Application::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Asker generates questions from input definitions file."
  s.description = "ASKER helps trainers to create a huge amount of questions, from a definitions input file."

  s.extra_rdoc_files = [ 'README.md', 'LICENSE' ]

  s.license     = 'GPL-3.0'
  s.authors     = ['David Vargas Ruiz']
  s.email       = 'teuton.software@protonmail.com'
  s.homepage    = 'https://github.com/teuton-software/asker/tree/v2.2'

  s.executables << 'asker'

  s.files       = Dir.glob(File.join('lib','**','*.*'))

  s.required_ruby_version = '>= 2.6.9'

  s.add_runtime_dependency 'haml', '~> 5.1'
  s.add_runtime_dependency 'inifile', '~> 3.0'
  s.add_runtime_dependency 'rainbow', '~> 3.0'
  s.add_runtime_dependency 'terminal-table', '~> 1.8'
  s.add_runtime_dependency 'thor', '~> 0.20'

  s.add_development_dependency 'minitest', '~> 5.11'
  s.add_development_dependency 'pry-byebug', '~> 3.9'
  s.add_development_dependency 'rubocop', '~> 0.74'
end
