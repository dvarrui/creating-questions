# frozen_string_literal: true

require 'rainbow'
require 'rexml/document'
require_relative '../data/concept'
require_relative 'code_loader'
require_relative '../data/project_data'

# Define methods that load data from XML contents
module ContentLoader
  ##
  # Load XML content into Asker data objects
  # @param filepath (String) File path
  # @param content (String) XML plane text content
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.load(filepath, content)
    concepts = []
    codes = []
    begin
      xmlcontent = REXML::Document.new(content)
    rescue REXML::ParseException
      raise_error_with(filepath, content)
    end
    lang = read_lang_attribute(xmlcontent)
    context = read_context_attribute(xmlcontent)

    xmlcontent.root.elements.each do |xmldata|
      case xmldata.name
      when 'concept'
        concepts << read_concept(xmldata, filepath, lang, context)
      when 'code'
        codes << read_code(xmldata, filepath)
      else
        puts Rainbow("[ERROR] Unkown tag <#{xmldata.name}>").red
      end
    end

    { concepts: concepts, codes: codes }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  ##
  # Read lang attr from input XML data
  # @param xmldata (XML Object)
  private_class_method def self.read_lang_attribute(xmldata)
    begin
      lang = xmldata.root.attributes['lang']
    rescue StandardError
      lang = ProjectData.instance.lang
    end
    lang
  end

  ##
  # Read context attr from input XML data
  # @param xmldata (XML Object)
  private_class_method def self.read_context_attribute(xmldata)
    begin
      context = xmldata.root.attributes['context']
    rescue StandardError
      context = 'unknown'
    end
    context
  end

  ##
  # Read concept from input XML data
  # @param xmldata (XML Object)
  # @param filepath (String)
  # @param lang
  # @param context
  private_class_method def self.read_concept(xmldata, filepath, lang, context)
    project = ProjectData.instance
    c = Concept.new(xmldata, filepath, lang, context)
    c.process = true if [File.basename(filepath), :default].include? project.get(:process_file)
    c
  end

  ##
  # Read code from input XML data
  # @param xmldata (XML Object)
  # @param filepath (String)
  private_class_method def self.read_code(xmldata, filepath)
    project = ProjectData.instance
    c = CodeLoader.load(xmldata, filepath)
    c.process = true if [File.basename(filepath), :default].include? project.get(:process_file)
    c
  end

  ##
  # Raise error and save content into error.file
  # @param filepath (String)
  # @param content (String)
  private_class_method def self.raise_error_with(filepath, content)
    puts Rainbow("[ERROR] ContentLoader: Format error in #{filepath}").red.bright
    f = File.open('output/error.xml', 'w')
    f.write(content)
    f.close
    raise msg
  end
end
