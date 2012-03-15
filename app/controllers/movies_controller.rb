class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def storeSession
    session["ratings"] = @all_ratings
    session["sort"] = params["sort"]
  end
  
  def tryRestoreSession
    if (not params["ratings"]) or (not params["sort"])
      redir_params = Hash.new
      if not params["ratings"]
        redir_params = redir_params.merge!({"ratings" => session["ratings"]})
      else
        redir_params = redir_params.merge!({"ratings" => params["ratings"]})
      end
      
      if not params["sort"]
        redir_params = redir_params.merge!({"sort" => session["sort"]})
      else
        redir_params = redir_params.merge!({"sort" => params["sort"]})
      end
      
      redirect_to movies_path(redir_params)
    end
  end

  def getCurrentRatings
    ratings = Hash.new

    if params["ratings"]
      Movie.ratings.each {|rating| 
        if params["ratings"].has_key?(rating) and params["ratings"][rating] == "true"
          ratings[rating] = true
        else
          ratings[rating] = false
        end
      }
    else
      Movie.ratings.each {|rating|
        ratings[rating] = false
      }
    end
    
    return ratings
  end
  
  def getAllRatings
    ratings = Hash.new
    
    Movie.ratings.each {|rating|
      ratings[rating] = true
    }
    
    return ratings
  end

  def index
    # if user was refreshing then lets redirect to RESTful page
    # if user wasn't refreshing and there are no "ratings" and "sort" then user came probably from "/movies"
    # so lets redirect to RESTful page
    if params["commit"] == "Refresh"
      return redirect_to movies_path("ratings" => getCurrentRatings())
    elsif not params["ratings"] and not params["sort"]
      return redirect_to movies_path("ratings" => getAllRatings(), "sort" => "title")
    end
    
    tryRestoreSession()
    
    @movies = Array.new
    @all_ratings = getCurrentRatings()
    
    condition = {:conditions => ["rating IN (?)", @all_ratings.select {|k, v| v == true}.keys]}
    
    if params["sort"] == "release_date"
      @movies = Movie.find(:all, condition, :order => "release_date")
      @release_date_class = 'hilite'
    elsif params["sort"] == "title"
      @movies = Movie.find(:all, condition, :order => "title")
      @title_class = 'hilite'
    else
      @movies = Movie.find(:all, condition)
      @release_date_class = ''
      @title_class = ''
    end
    
    storeSession()
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
