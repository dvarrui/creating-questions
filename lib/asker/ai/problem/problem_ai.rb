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
    make_questions_with_aswers
    make_questions_with_steps
    @problem.questions = @questions
  end

  private

  def counter
    @counter += 1
  end

  def customize(text:, custom:)
    output = text.clone
    custom.each_pair { |oldvalue, newvalue| output.gsub!(oldvalue, newvalue) }
    output
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

  def lines_to_s(lines)
    output = ""
    lines.each_with_index do |line, index|
      output << "%2d: #{line}\n" % (index + 1)
    end
    output
  end

  def make_questions_with_aswers
    name = @problem.name
    lang = @problem.lang

    @customs.each do |custom|
      desc = customize(text: @problem.desc, custom: custom)

      @problem.asks.each do |ask|
        next if ask[:text].nil?
        asktext = customize(text: ask[:text], custom: custom)
        next if ask[:answer].nil?
        correct_answer = customize(text: ask[:answer], custom: custom)

        # Question boolean => true
        q = Question.new(:boolean)
        q.name = "#{name}-#{counter}-pa1true1"
        q.text = lang.text_for(:pa1, desc, asktext, correct_answer)
        q.good = "TRUE"
        @questions << q

        # Locate incorrect answers
        incorrect_answers = []
        @customs.each do |aux|
          next if aux == custom
          incorrect = customize(text: ask[:answer], custom: aux)
          incorrect_answers << incorrect if incorrect != correct_answer
        end

        # Question boolean => true
        if incorrect_answers.size > 0
          q = Question.new(:boolean)
          q.name = "#{name}-#{counter}-pa2false2"
          q.text = lang.text_for(:pa1, desc, asktext, incorrect_answers.first)
          q.good = "FALSE"
          @questions << q
        end

        # Question choice NONE
        if incorrect_answers.size > 2
          q = Question.new(:choice)
          q.name = "#{name}-#{counter}-pa2-choice-none3"
          q.text = lang.text_for(:pa2, desc, asktext)
          q.good = lang.text_for(:none)
          incorrect_answers.shuffle!
          q.bads << incorrect_answers[0]
          q.bads << incorrect_answers[1]
          q.bads << incorrect_answers[2]
          q.feedback = "Correct answer is #{correct_answer}."
          @questions << q
        end

        # Question choice OK
        if incorrect_answers.size > 2
          q = Question.new(:choice)
          q.name = "#{name}-#{counter}-pa2choice4"
          q.text = lang.text_for(:pa2, desc, asktext)
          q.good = correct_answer
          incorrect_answers.shuffle!
          q.bads << incorrect_answers[0]
          q.bads << incorrect_answers[1]
          q.bads << incorrect_answers[2]
          q.feedback = "Correct answer is #{correct_answer}."
          @questions << q
        end

        if incorrect_answers.size > 1
          q = Question.new(:choice)
          q.name = "#{name}-#{counter}-pa2choice5"
          q.text = lang.text_for(:pa2, desc, asktext)
          q.good = correct_answer
          incorrect_answers.shuffle!
          q.bads << incorrect_answers[0]
          q.bads << incorrect_answers[1]
          q.bads << lang.text_for(:none)
          q.feedback = "Correct answer is #{correct_answer}."
          @questions << q
        end

        # Question short
        q = Question.new(:short)
        q.name = "#{name}-#{counter}-pa2short6"
        q.text = lang.text_for(:pa2, desc, asktext)
        q.shorts << correct_answer
        q.feedback = "Correct answer is #{correct_answer}."
        @questions << q
      end
    end

    def make_questions_with_steps
      name = @problem.name
      lang = @problem.lang

      @customs.each do |custom|
        desc = customize(text: @problem.desc, custom: custom)

        @problem.asks.each do |ask|
          next if ask[:text].nil?
          asktext = customize(text: ask[:text], custom: custom)
          next if ask[:steps].nil? || ask[:steps].empty?
          steps = ask[:steps].map { |step| customize(text: step, custom: custom) }

          # Question steps ok
          q = Question.new(:short)
          q.name = "#{name}-#{counter}-ps3short7"
          q.text = lang.text_for(:ps3, desc, asktext, lines_to_s(steps))
          q.shorts << 0
          @questions << q

          if steps.size > 3
            q = Question.new(:ordering)
            q.name = "#{name}-#{counter}-ps6ordering8"
            q.text = lang.text_for(:ps6, desc, asktext, lines_to_s(steps))
            steps.each { |step| q.ordering << step }
            @questions << q
          end

          # Using diferents wrong steps sequences
          max = steps.size - 1
          (0..max).each do |index|
            change = rand(max + 1)
            bads = steps.clone

            minor = index
            major = change
            if minor > major
              minor, major = major, minor
            elsif minor == major
              next
            end
            bads[minor], bads[major] = bads[major], bads[minor]

            # Question steps error
            q = Question.new(:short)
            q.name = "#{name}-#{counter}-ps3short-error9"
            q.text = lang.text_for(:ps3, desc, asktext, lines_to_s(bads))
            q.shorts << minor + 1
            q.feedback = lang.text_for(:ps4, minor + 1, major + 1)
            @questions << q
          end

          # Match questions
          indexes = (0..(steps.size - 1)).to_a.shuffle
          (0..(steps.size - 4)).each do |first|
            incomplete_steps = steps.clone
            incomplete_steps[indexes[first]] = "?"
            incomplete_steps[indexes[first + 1]] = "?"
            incomplete_steps[indexes[first + 2]] = "?"
            incomplete_steps[indexes[first + 3]] = "?"

            q = Question.new(:match)
            q.name = "#{name}-#{counter}-ps5match10"
            q.text = lang.text_for(:ps5, desc,  asktext, lines_to_s(incomplete_steps))
            q.matching << [steps[indexes[first]], (indexes[first] + 1).to_s]
            q.matching << [steps[indexes[first + 1]], (indexes[first + 1] + 1).to_s]
            q.matching << [steps[indexes[first + 2]], (indexes[first + 2] + 1).to_s]
            q.matching << [steps[indexes[first + 3]], (indexes[first + 3] + 1).to_s]
            q.matching << ["", lang.text_for(:error)]
            @questions << q

            q = Question.new(:ddmatch)
            q.name = "#{name}-#{counter}-ps5ddmatch11"
            q.text = lang.text_for(:ps5, desc,  asktext, lines_to_s(incomplete_steps))
            q.matching << [(indexes[first] + 1).to_s, steps[indexes[first]]]
            q.matching << [(indexes[first + 1] + 1).to_s, steps[indexes[first + 1]]]
            q.matching << [(indexes[first + 2] + 1).to_s, steps[indexes[first + 2]]]
            q.matching << [(indexes[first + 3] + 1).to_s, steps[indexes[first + 3]]]
            q.matching << ["", lang.text_for(:error)]
            @questions << q
          end
        end
      end
    end
  end
end
