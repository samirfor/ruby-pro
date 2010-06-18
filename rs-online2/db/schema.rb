# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100606185548) do

  create_table "links", :force => true do |t|
    t.string   "url"
    t.boolean  "completed"
    t.integer  "size"
    t.datetime "date_started"
    t.datetime "date_finished"
    t.integer  "package_id"
    t.integer  "status_id"
  end

  create_table "packages", :force => true do |t|
    t.string   "description"
    t.string   "comment"
    t.boolean  "completed"
    t.boolean  "show"
    t.boolean  "problem"
    t.datetime "date_created"
    t.datetime "date_started"
    t.datetime "date_finished"
    t.string   "password"
    t.integer  "priority_id"
    t.string   "source"
    t.string   "legend"
  end

  create_table "priorities", :force => true do |t|
    t.string "description"
  end

end
