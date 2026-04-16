class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.references :task, null: false, foreign_key: true
      t.binary :data
      t.string :filename
      t.string :content_type

      t.timestamps
    end
  end
end
