class MovieRole < ActiveRecord::Base
  belongs_to :movie
  belongs_to :role
  has_and_belongs_to_many :authors
end