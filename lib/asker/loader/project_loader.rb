# frozen_string_literal: true

require 'yaml'
require_relative '../data/project_data'

# Load params into Project class using arg input
# * load
# * load_from_string
# * load_from_yaml
# * load_from_directory
# * load_error
module ProjectLoader
  ##
  # Load project from args
  # @param args (String or Hash)
  # rubocop:disable Metrics/MethodLength
  def self.load(args)
    project = ProjectData.instance

    if args.class == Hash
      project.param.merge!(args)
      project.open
      return project
    elsif args.class == String
      ProjectLoader.load_from_string(args)
      project.open
      return project
    end

    msg = '[ERROR] ProjectLoader:'
    msg += "Configuration params format is <#{pArgs.class}>!"
    puts Rainbow(msg).red
    raise msg
  end
  # rubocop:enable Metrics/MethodLength

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
      msg = Rainbow("[ERROR] #{filepath} not found!").red.bright
      puts msg
      exit 1
    end

    if File.extname(filepath) == '.haml' || File.extname(filepath) == '.xml'
      project.set(:inputdirs, File.dirname(filepath))
      project.set(:process_file, File.basename(filepath))
      return project
    elsif File.extname(filepath) == '.yaml'
      return load_from_yaml(filepath)
    end
    error_loading(filepath)
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Security/YAMLLoad
  def self.load_from_yaml(arg)
    project = ProjectData.instance
    project.param.merge!(YAML.load(File.open(arg)))
    project.set(:configfilename, arg)
    project.set(:projectdir, File.dirname(arg))
    project
  end
  # rubocop:enable Security/YAMLLoad

  ##
  # Error found and exit application.
  def self.error_loading(arg)
    msg = Rainbow("[ERROR] Loading... #{arg}").red.bright
    puts msg
    exit 1
  end
end
