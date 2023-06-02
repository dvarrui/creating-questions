# frozen_string_literal: true

require "yaml"
require_relative "../data/project_data"

module ProjectLoader
  ##
  # Load project from args
  # @param args (String or Hash)
  # rubocop:disable Metrics/MethodLength
  def self.load(args)
    project = ProjectData.instance

    if args.instance_of? Hash
      project.param.merge!(args)
      project.open
      return project
    elsif args.instance_of? String
      ProjectLoader.load_from_string(args)
      project.open
      return project
    end

    msg = "[ERROR] ProjectLoader: Configuration params format is <#{args.class}>!"
    puts Rainbow(msg).red
    raise msg
  end

  ##
  # Load project from filepath. Options:
  # * HAML filepath
  # * XML filepath
  # * YAML filepath
  # @param filepath (String)
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.load_from_string(filepath)
    project = ProjectData.instance
    unless File.exist?(filepath)
      warn Rainbow("[ERROR] ProjectLoader: #{filepath} not found!").red.bright
      exit 1
    end

    if File.extname(filepath) == ".haml" || File.extname(filepath) == ".xml"
      project.set(:inputdirs, File.dirname(filepath))
      project.set(:process_file, File.basename(filepath))
      return project
    elsif File.extname(filepath) == ".yaml"
      return load_from_yaml(filepath)
    end
    error_loading(filepath)
  end

  def self.load_from_yaml(arg)
    project = ProjectData.instance
    project.param.merge!(YAML.load(File.open(arg)))
    project.set(:configfilename, arg)
    project.set(:projectdir, File.dirname(arg))
    project
  end

  ##
  # Error found and exit application.
  def self.error_loading(arg)
    warn Rainbow("[ERROR] ProjectLoader: Loading... #{arg}").red.bright
    exit 1
  end
end
