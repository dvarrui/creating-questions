# encoding: utf-8

require_relative '../lang/lang'
require_relative '../ia/ia'
require_relative 'question'

class ConceptIA
  include IA

  attr_reader :concept, :questions

  def initialize(concept)
    @concept = concept
    @questions={}
  end

  def method_missing(m, *args, &block)
    return @concept.data[m]
  end

  def lang
    return @concept.lang
  end

  def name
    return @concept.name
  end

  def neighbours
    return @concept.neighbours
  end

  def tables
    return @concept.tables
  end
end
