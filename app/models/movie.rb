class Movie < ActiveRecord::Base
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :countries
  has_many :movie_roles
  has_many :roles, :through => :movie_roles
end