class Er::Tag < ActiveRecord::Base
  validates :name,     presence: true
  validates :tag,      presence: true
  validates :interval, presence: true #TODO rename this to interval_to_next
  validates :order, presence: true, uniqueness: true

  class << self
    attr_reader :INTERVAL_NEVER
  end
  @INTERVAL_NEVER = -1
end
