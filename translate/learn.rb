require './lib/app_configurator'

module Translate
  class Learn
    attr_reader :logger
    attr_reader :input
    attr_reader :user

    EMOJI = '\u{2754}'

    def initialize(input, user)
      @input = input
      @user  = user
      @logger = AppConfigurator.new.get_logger
    end

    def check_word
      result = expected_words.include?(input_word)
      if result == true
        waiting_word.increment!(:learn_correct)
      else
        waiting_word.increment!(:learn_wrong)
      end
      { message: result, right_answer: expected_words.join(' - ') }
    end

    def push_word
      user.words.update_all(waiting: false) # reset all waiting
      sample_word.update(waiting: true)
      sample_word.increment!(:learn_views)

      { message: outcome_word, kb_answers: answer_variants.shuffle }
    end

  private
    def expected_words
      [waiting_word.translate, waiting_word.word].map(&:downcase)
    end

    def waiting_word
      user.words.waiting.first
    end

    def input_word
      input.gsub(/^[\u{2754}]/, '').strip.downcase
    end

    def sample_word
      @sample_word ||= user.words.customize_sample
    end

    def outcome_word
      sample_word.send(word_variat)
    end

    def word_variat
      @word_variat ||= word_variants.keys[randomize]
    end

    def randomize
      rand(0..1)
    end

    def word_variants
      {word: :lang_from, translate: :lang_to}
    end

    def right_answer
      sample_word.send(opposite_variant)
    end

    def opposite_variant
      if word_variants.keys.index(word_variat).zero?
        word_variants.keys[1]
      else
        word_variants.keys[0]
      end
    end

    def answer_variants
      lang = sample_word.send(word_variants[opposite_variant])
      answers = [right_answer]
      Word.similar(sample_word).each do |word|
        answers << word.word      if word.lang_from == lang
        answers << word.translate if word.lang_to  == lang
      end
      answers.compact.map{ |a| "\u{2754} #{a.capitalize}"}
    end
  end
end
