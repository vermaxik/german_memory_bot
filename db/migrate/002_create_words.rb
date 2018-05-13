class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words, force: true do |t|
      t.belongs_to :user
      t.string :word
      t.string :translate
      t.string :lang_from
      t.string :lang_to
      t.string :word_count, default: 0
      t.string :translate_count, default: 0
      t.integer :training_views, default: 0
      t.integer :training_right, default: 0
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
