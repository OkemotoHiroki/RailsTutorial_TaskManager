class AddEventidToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :event_id, :string
  end
end
