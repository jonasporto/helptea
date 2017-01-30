Rails.application.routes.draw do
  get 'search/index'
  get 'search/stats'
  get 'search/clear'

  root 'search#index'
end
