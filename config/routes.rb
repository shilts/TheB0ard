TheB0ard::Application.routes.draw do

  root :to => "dashboard#main"

   get '/refresh_data', to: 'dashboard#main'

end
