require 'active_record'

class Word < ActiveRecord::Base
  belongs_to :user

  scope :waiting, ->{ where(waiting: true) }
  scope :de_en, -> { where(lang_from: :de) }
  scope :en_de, -> { where(lang_to: :de) }

  def self.similar(word)
    where(word_count: word.word_count).where.not(id: word.id).limit(3).order('RAND()')
  end
end
