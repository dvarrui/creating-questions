# frozen_string_literal: true

require "set"

require_relative "base_stage"
require_relative "../question"

##
# range d1-d4: d1choice, d1none-misspelled, d1none
class StageD < BaseStage
  def run
    # Stage D: process every definition, I mean every <def> tag
    questions = []
    return questions unless concept.type == "text"

    lang = concept.lang
    # for every <text> do this
    concept.texts.each do |t|
      # s => concept name, none and neighbors
      s = Set.new [name(:raw), lang.text_for(:none)]
      concept.neighbors.each { |n| s.add n[:concept].name(:decorated) }
      a = s.to_a

      # Question choose between 4 options
      if s.count > 3
        q = Question.new(:choice)
        q.name = "#{name(:id)}-#{num}-d1choose"
        q.text = random_image_for(name(:raw)) + lang.text_for(:d1, t)
        q.good = name(:raw)
        q.bads << lang.text_for(:none)
        q.bads << a[2]
        q.bads << a[3]
        questions << q
      end

      # Question choose between 4 options, good none (Syntax error)
      if s.count > 3
        q = Question.new(:choice)
        q.name = "#{name(:id)}-#{num}-d1none-misspelled"
        q.text = random_image_for(name(:raw)) + lang.text_for(:d1, t)
        q.good = lang.text_for(:none)
        q.bads << lang.do_mistake_to(name(:raw))
        q.bads << a[2]
        q.bads << a[3]
        q.feedback = "Option misspelled!: #{name(:raw)}"
        questions << q
      end

      s.delete(name(:raw))
      a = s.to_a

      # Question choose between 4 options, good none
      if s.count > 3
        q = Question.new(:choice)
        q.name = "#{name(:id)}-#{num}-d1none"
        q.text = random_image_for(name(:raw)) + lang.text_for(:d1, t)
        q.good = lang.text_for(:none)
        q.bads << a[1]
        q.bads << a[2]
        q.bads << a[3]
        questions << q
      end

      # Question choice => mispelled
      q = Question.new(:choice)
      q.name = "#{name(:id)}-#{num}-d2def-misspelled"
      q.text = random_image_for(name(:raw)) + lang.text_for(:d2, name(:decorated), lang.do_mistake_to(t))
      q.good = lang.text_for(:misspelling)
      q.bads << lang.text_for(:true)
      q.bads << lang.text_for(:false)
      q.feedback = "Definition text misspelled!: #{t}"
      questions << q

      # Question choice => name mispelled
      q = Question.new(:choice)
      q.name = "#{name(:id)}-#{num}-d2name-misspelled"
      q.text = random_image_for(name(:raw)) + lang.text_for(:d2, lang.do_mistake_to(name(:raw)), t)
      q.good = lang.text_for(:misspelling)
      q.bads << lang.text_for(:true)
      q.bads << lang.text_for(:false)
      q.feedback = "Concept name misspelled!: #{name(:raw)}"
      questions << q

      # Question choice => true
      q = Question.new(:choice)
      q.name = "#{name(:id)}-#{num}-d2true-misspelled"
      q.text = random_image_for(name(:raw)) + lang.text_for(:d2, name(:raw), t)
      q.good = lang.text_for(:true)
      q.bads << lang.text_for(:misspelling)
      q.bads << lang.text_for(:false)
      questions << q

      # Question boolean => true
      q = Question.new(:boolean)
      q.name = "#{name(:id)}-#{num}-d2true"
      q.text = random_image_for(name(:raw)) + lang.text_for(:d2, name(:raw), t)
      q.good = "TRUE"
      questions << q

      # Question choice => false
      if a.size > 1
        q = Question.new(:choice)
        q.name = "#{name(:id)}-#{num}-d2false-misspelled"
        q.text = random_image_for(name(:raw)) + lang.text_for(:d2, a[1], t)
        q.good = lang.text_for(:false)
        q.bads << lang.text_for(:misspelling)
        q.bads << lang.text_for(:true)
        questions << q

        # Question boolean => false
        q = Question.new(:boolean)
        q.name = "#{name(:id)}-#{num}-d2false"
        q.text = random_image_for(name(:raw)) + lang.text_for(:d2, a[1], t)
        q.good = "FALSE"
        questions << q
      end

      # Question hidden name questions
      q = Question.new(:short)
      q.name = "#{name(:id)}-#{num}-d3hidden"
      q.text = random_image_for(name(:raw)) + lang.text_for(:d3, lang.hide_text(name(:raw)), t)
      q.shorts << name(:raw)
      q.shorts << name(:raw).tr("-", " ").tr("_", " ")
      concept.names.each { |n| q.shorts << n if n != name }
      questions << q

      # Question filtered text questions
      filtered = lang.text_with_connectors(t)
      indexes = filtered[:indexes]

      groups = indexes.combination(4).to_a.shuffle
      max = (indexes.size / 4).to_i
      groups[0, max].each do |e|
        e.sort!
        q = Question.new(:match)
        q.shuffle_off
        q.name = "#{name}-#{num}-d4filtered"
        s = lang.build_text_from_filtered(filtered, e)
        q.text = random_image_for(name(:raw)) + lang.text_for(:d4, name(:raw), s)
        e.each_with_index do |value, index|
          q.matching << [(index + 1).to_s, filtered[:words][value][:word].downcase]
        end
        questions << q        
      end
    end

    questions
  end
end
