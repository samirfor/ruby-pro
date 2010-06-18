class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.column :url, :string
      t.column :completed, :boolean
      t.column :size, :integer
      t.column :date_started, :timestamp
      t.column :date_finished, :timestamp
      t.column :package_id, :integer
      t.column :status_id, :integer
    end
  end

  def self.down
    drop_table :links
  end
end
