BoomBamSplash::Application.routes.draw do
  resources :sounds
  root :to => "sounds#index"
end
