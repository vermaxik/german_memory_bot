class AddAndRenameColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :training_failed, :integer, default: 0, after: :training_right
    rename_column :words, :training_views, :learn_views
    rename_column :words, :training_right, :learn_correct
  end
end
