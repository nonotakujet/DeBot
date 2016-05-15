Rails.application.routes.draw do
  post '/callback' => 'webhook#callback'
  get '/test' => 'test#callback'
end
