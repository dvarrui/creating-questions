
require_relative "../../lang/lang_factory"
require_relative "../question"

class ProblemAI
  attr_accessor :problem

  def call(problem)
    @problem = problem
    make_questions
    @problem
  end

  def make_questions
    @counter = 0
    @questions = []
    @customs = get_customs(@problem)
    make_boolean_questions
    @problem.questions = @questions
  end

  private

  def counter
    @counter += 1
  end

  def get_customs(problem)
    customs = []
    vars = problem.varnames
    problem.cases.each do |acase|
      custom = {}
      vars.each_with_index { |varname, index| custom[varname] = acase[index] }
      customs << custom
    end
    customs
  end

  def customize(text:, custom:)
    output = text.clone
    custom.each_pair { |oldvalue, newvalue| output.gsub!(oldvalue, newvalue) }
    output
  end

  def make_boolean_questions
    name = @problem.name
    lang = @problem.lang

    @customs.each do |custom|
      desc = customize(text: @problem.desc, custom: custom)

      @problem.asks.each do |ask|
        next if ask[:text].nil?
        asktext = customize(text: ask[:text], custom: custom)
        next if ask[:answer].nil?
        answer = customize(text: ask[:answer], custom: custom)

        # Question boolean => true
        q = Question.new(:boolean)
        q.name = "#{name}-#{counter}-problem1a-true"
        q.text = lang.text_for(:problem1a, desc, asktext, answer)
        q.good = 'TRUE'
        @questions << q
      end
    end
  end
end
