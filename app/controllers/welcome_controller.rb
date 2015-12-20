class WelcomeController < ApplicationController

  def index
    render json: {all_good: true}
  end
end
