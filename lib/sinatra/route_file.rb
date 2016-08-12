
module Sinatra
  module SinatraFrontEnd
    module RouteFile

      def self.registered(app)
        app.get '/file/show/*.*' do |path,ext|
          @filename = path+"."+ext
          filepath = File.join( Project.instance.inputbasedir , @filename)
          content = load_file filepath
#          @filecontent = CodeRay.scan(content, ext.to_sym).div(:line_numbers => :table)
          @filecontent = "<pre>#{content}</pre>"
          @concepts = session['concepts']
          @current = File.dirname(filepath)
          erb :"file/show"
        end
      end

    end
  end
end
