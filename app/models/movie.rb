class Movie < ActiveRecord::Base
  has_and_belongs_to_many :genres,:dependent => :destroy
  has_and_belongs_to_many :countries, :dependent => :destroy
  has_many :movie_roles, -> { includes( :role, :authors) }, :dependent => :destroy
  has_many :roles, :through => :movie_roles
  belongs_to :box
  
  def rok
    year.year.to_i
  end
  
 def rezie
   o = []
   movie_roles.each do |mr|
     o << mr.role.name.to_s + "(" + mr.authors.map {|a| a.name}.join(", ")  + ")"
   end
   o.join(", ")
 end   
end