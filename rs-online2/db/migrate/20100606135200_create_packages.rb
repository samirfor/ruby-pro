class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.column :description, :string
      t.column :comment, :string
      t.column :completed, :boolean
      t.column :show, :boolean
      t.column :problem, :boolean
      t.column :date_created, :timestamp
      t.column :date_started, :timestamp
      t.column :date_finished, :timestamp
      t.column :password, :string
      t.column :priority_id, :integer
      t.column :source, :string
      t.column :legend, :string
    end
  end

  def self.down
    drop_table :packages
  end
end
