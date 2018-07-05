require 'active_record'

class Word < ActiveRecord::Base
  SCORE_PASSED_MIN = 5

  belongs_to :user

  scope :waiting, ->{ where(waiting: true) }
  scope :de_en, -> { where(lang_from: :de) }
  scope :en_de, -> { where(lang_to: :de) }
  scope :smart_update, ->{ where('updated_at < ?', Time.now - 60*2 ) }

  def self.smart_training
    where("(FLOOR(#{SCORE_PASSED_MIN} + learn_wrong/2) > learn_correct)")
    .smart_update
    .order(created_at: :asc)
    .limit(15)
  end

  def self.training
    where("(FLOOR(#{SCORE_PASSED_MIN} + learn_wrong/2) > learn_correct)")
    .order(created_at: :asc)
    .limit(15)
  end

  def self.similar(word)
    where(word_count: word.word_count).where.not(id: word.id).sample(3)
  end

  def self.customize_sample
    self.smart_training.sample || self.training.sample
  end

  def passed?
    learn_correct > (SCORE_PASSED_MIN + learn_wrong/2)
  end
end
