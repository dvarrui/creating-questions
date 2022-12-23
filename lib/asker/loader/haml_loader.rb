require 'haml'

module HamlLoader
  def self.load(filename)
    template = File.read(filename)
    begin
      # INFO <haml 5.1>
      #   haml_engine = Haml::Engine.new(template)
      #   return haml_engine.render
      return Haml::Template.new { template }.render
    rescue StandardError => e
      puts "[ERROR] HamlLoader: Can't load <#{filename}> file!"
      puts "  => #{e}"
      exit 0
    end
  end
end
