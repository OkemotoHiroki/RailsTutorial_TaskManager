class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :detail
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
