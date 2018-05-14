class AddWaitingColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :waiting, :boolean, default: false, after: :training_right
  end
end
