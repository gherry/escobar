Rails.application.routes.draw do
  root to: "home#index"
  get  '/auth/:provider/callback', to: 'sessions#create'
  get  'logout', to: 'sessions#destroy'

  scope "bots/:bot_id", controller: :bots, as: :bots do
    post :email
    post :email_confirm
    post :order_search
    post :orders
    post :fulfillment_search
    post :tracking_url_search
  end
end
