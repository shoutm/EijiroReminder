class Er::Tag < ActiveRecord::Base
  validates :name,     presence: true
  validates :tag,      presence: true
  validates :interval, presence: true #TODO rename this to interval_to_next
end
