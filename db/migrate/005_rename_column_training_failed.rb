class RenameColumnTrainingFailed < ActiveRecord::Migration[5.1]
  def change
    rename_column :words, :training_failed, :learn_wrong
  end
end
