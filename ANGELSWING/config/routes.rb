Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	resource :users, only: [:create]
	post "/auth/signin", to: "users#signin"	# used for login
	post "/auth/signup", to: "users#signup"	# used for login
	get "/auth/auto_login", to: "users#auto_login"	# Use to verify that the user is logged in using JWT. 
end
