# frozen_string_literal: true

require_relative '../formatter/question_moodle_formatter'
require_relative '../version'

# Export ConceptIA data to gift to moodlefile
module ConceptAIMoodleExporter
  ##
  # Export an array of ConceptAI objects from Project into Moodle format file
  # @param concepts_ai (Array)
  # @param project (Project)
  def self.export_all(concepts_ai, project)
    file = File.open(project.get(:moodlepath), 'w')
    file.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    file.write("<quiz>\n")
    file.write("<!--\n#{('=' * 50)}\n")
    file.write(" Created by : #{Asker::NAME}")
    file.write(" (version #{Asker::VERSION})\n")
    file.write(" File       : #{project.get(:moodlename)}\n")
    file.write(" Time       : #{Time.new}\n")
    file.write(" Author     : David Vargas Ruiz\n")
    file.write("#{('=' * 50)}\n-->\n\n")

    concepts_ai.each { |concept_ai| export(concept_ai, file) }

    file.write("</quiz>\n")
    file.close
  end

  ##
  # Export 1 concept_ai from project
  # @param concept_ai (ConceptAI)
  # @param file (File)
  private_class_method def self.export(concept_ai, file)
    return unless concept_ai.concept.process?

    Application.instance.config['questions']['stages'].each do |stage|
      concept_ai.questions[stage].each do |question|
        file.write(QuestionMoodleFormatter.to_s(question))
      end
    end
  end
end
