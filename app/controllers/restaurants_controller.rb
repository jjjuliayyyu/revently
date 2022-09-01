class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy]

  def index
    # Query params for the filters in the restaurants page
    @restaurants = Restaurant.all
    if params.present?
      if params[:rating] == "4.0"
        @restaurants = Restaurant.where("rating > ?", 4.0)
      elsif params[:cuisine] == "American"
        @restaurants = Restaurant.where(cuisine: "American")
      elsif params[:cuisine] == "Japanese"
        @restaurants = Restaurant.where(cuisine: "Japanese")
      elsif params[:cuisine] == "Mexican"
        @restaurants = Restaurant.where(cuisine: "Mexican")
      elsif params[:cuisine] == "Chinese"
        @restaurants = Restaurant.where(cuisine: "Chinese")
      elsif params[:cuisine] == "Bar"
        @restaurants = Restaurant.where(cuisine: "Bar")
      elsif params[:cuisine] == "Vegan"
        @restaurants = Restaurant.where(cuisine: "Vegan")
      end
    end

    # Query params for the search bar at the top of each page
    if params[:query].present?
      sql_query = "name ILIKE :query OR cuisine ILIKE :query"
      @restaurants = Restaurant.where(sql_query, query: "%#{params[:query]}%")
    else
      @restaurants = Restaurant.all
    end
    
    @markers = @restaurants.geocoded.map do |restaurant|
      {
        lat: restaurant.latitude,
        lng: restaurant.longitude,
        info_window: render_to_string(partial: "info_window", locals: {restaurant: restaurant}),
        image_url: helpers.asset_url("https://res.cloudinary.com/hykim103/image/upload/v1661956170/Revently-logo_ja0wa1.png")
      }
    end
  end

  def search_index
  end

  def host_restaurants
    @restaurants = Restaurant.where(user_id: current_user)

    @markers = @restaurants.geocoded.map do |restaurant|
      {
        lat: restaurant.latitude,
        lng: restaurant.longitude,
        info_window: render_to_string(partial: "info_window", locals: {restaurant: restaurant}),
        image_url: helpers.asset_url("https://res.cloudinary.com/hykim103/image/upload/v1661956170/Revently-logo_ja0wa1.png")
      }
    end
  end

  def show
    authenticate_user!
    @marker = [{
      lat: @restaurant.latitude,
      lng: @restaurant.longitude,
      info_window: render_to_string(partial: "info_window", locals: { restaurant: @restaurant })
    }]
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.user = current_user
    if @restaurant.save
      redirect_to new_restaurant_menu_path(@restaurant.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @restaurant.update(restaurant_params)
  end

  def destroy
    @restaurant.destroy
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address, :cuisine, :phone_number, :venue_type, :chairs, :max_guests, :price, :rating, :photos)
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end
end
