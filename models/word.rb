require 'active_record'

class Word < ActiveRecord::Base
  SCORE_PASSED_MIN = 5

  belongs_to :user

  scope :waiting, ->{ where(waiting: true) }
  scope :de_en, -> { where(lang_from: :de) }
  scope :en_de, -> { where(lang_to: :de) }
  scope :training, -> { where("(FLOOR(#{SCORE_PASSED_MIN} + learn_wrong/2) > learn_correct)").order(created_at: :asc).limit(10) }

  def self.similar(word)
    where(word_count: word.word_count).where.not(id: word.id).sample(3)
  end

  def self.customize_sample
    self.training.sample
  end

  def passed?
    SCORE_PASSED_MIN + learn_wrong/2 >= learn_correct
  end
end
