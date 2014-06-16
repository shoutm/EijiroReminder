class Er::Tag < ActiveRecord::Base
  validate :name,     presence: true
  validate :tag,      presence: true
  validate :interval, presence: true
end
