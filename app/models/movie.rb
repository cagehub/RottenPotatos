class Movie < ActiveRecord::Base
  @@ratings = ['G','PG','PG-13','R']
  
  def self.ratings
    return @@ratings
  end
end
