class Er::Item < ActiveRecord::Base
  validates :e_id, presence: true
  validates :name, presence: true
end
