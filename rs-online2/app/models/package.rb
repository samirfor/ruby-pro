class Package < ActiveRecord::Base

  attr_accessor :links
  
  has_one :priority
  has_many :link
end
