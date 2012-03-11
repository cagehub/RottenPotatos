class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #debugger
    @movies = Array.new
    
    if not @all_ratings
      @all_ratings = Hash.new
      
      Movie.ratings.each {|rating| 
        @all_ratings[rating] = true
      }
    end
    
    if params["commit"] == "Refresh"
      Movie.ratings.each {|rating| 
        if params["ratings"] and params["ratings"].has_key?(rating)
          @all_ratings[rating] = true
        else
          @all_ratings[rating] = false
        end
      }
    end

    if params["ratings"]
      @current_ratings = params["ratings"]
    else
      @current_ratings = {}
    end
    
    if params["sort"] == "release_date"
      #@movies.sort! {|a,b| b.release_date <=> a.release_date}
      debugger
      temp =  @current_ratings.keys
      @movies = Movie.find(:all, :conditions => ["rating IN (?)", @current_ratings.keys], :order => "release_date")
      @release_date_class = 'hilite'
    elsif params["sort"] == "title"
      @movies = Movie.find(:all, :order => "title")
      @title_class = 'hilite'
    else
      if params["commit"] == "Refresh"
        if @current_ratings
          @current_ratings.each_key {|rating| @movies += Movie.find_all_by_rating(rating)}
        end
      else
        @movies = Movie.all
      end
      
      @release_date_class = ''
      @title_class = ''
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
