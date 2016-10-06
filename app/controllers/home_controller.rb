class HomeController < ApplicationController
  before_action :authenticate_user!, only: :index
  before_action :setup_client, only: :index

  def index
    @account = @client.Account.current
    @product_size = @client.Product.size
  end
end
