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

  def getDefaultRatings
    ratings = Hash.new
    Movie.ratings.each {|rating| 
      ratings[rating] = true
    }
    return ratings
  end

  def getCurrentRatings
    ratings = Hash.new
    Movie.ratings.each {|rating| 
      if params["ratings"] and params["ratings"].has_key?(rating) and params["ratings"][rating] == "true"
        ratings[rating] = true
      else
        ratings[rating] = false
      end
    }
    return ratings
  end
  
  def sortParamValid?(sort_param)
    if sort_param == "release_date" or sort_param == "title"
      return true
    else
      return false
    end
  end
  
  def setSortedColumnHilite
    case params["sort"]
    when "release_date"
      @release_date_class = 'hilite'
      @title_class = ''
    when "title"
      @release_date_class = ''
      @title_class = 'hilite'
    end
  end

  def index
    need_to_redirect = false
    redir_params = Hash.new
  
    if params["ratings"] and params["sort"] and sortParamValid?(params["sort"])
      # everything needed is in params, can return correct site
      @movies = Array.new
      @all_ratings = getCurrentRatings()
      
      setSortedColumnHilite()
      
      condition = {:conditions => ["rating IN (?)", @all_ratings.select {|k, v| v == true}.keys]}
      
      @movies = Movie.find(:all, condition, :order => params["sort"])
      
      storeSession()
    elsif params["commit"] == "Refresh"
      need_to_redirect = true
      
      @all_ratings = getCurrentRatings()
      
      redir_params["ratings"] = @all_ratings
      if session["sort"] and sortParamValid?(session["sort"])
        redir_params["sort"] = session["sort"]
      else
        redir_params["sort"] = "title"
      end
    else
      # something is missing, lets try to fill in from session or if that fails then 
      # set to default values and redirect
      need_to_redirect = true
      
      if params["ratings"]
        redir_params["ratings"] = params["ratings"]
      elsif session["ratings"]
        redir_params["ratings"] = session["ratings"]
      else
        redir_params["ratings"] = getDefaultRatings()
      end
      
      if params["sort"] and sortParamValid?(params["sort"])
        redir_params["sort"] = params["sort"]
      elsif session["sort"]
        redir_params["sort"] = session["sort"]
      else
        redir_params["sort"] = "title"
      end
    end
    
    if need_to_redirect
      redirect_to movies_path(redir_params)
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
