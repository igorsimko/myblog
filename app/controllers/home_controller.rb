class HomeController < ApplicationController

  def index
    @users = User.includes(:posts).all
  end
end
