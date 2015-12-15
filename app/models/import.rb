class Import < ActiveRecord::Base
  def mtext
    
    if movie_id.to_i > 0
      begin
       m = Movie.find(movie_id)
       if m
        "<span style='color: green'>" + movie_id.to_s + "<span>"
       else
        "<span style='color: blue'>" + movie_id.to_s + "<span>"
       end  
      rescue
       "<span style='color: red'>" + movie_id.to_s + "<span>" 
      end  
    else
      "-"
    end
  end
  
end