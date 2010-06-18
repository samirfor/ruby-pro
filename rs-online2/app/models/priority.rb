class Priority < ActiveRecord::Base
  belongs_to :package, :foreign_key => 'priority_id'
end
