class Link < ActiveRecord::Base

  belongs_to :package, :foreign_key => 'package_id'
end
