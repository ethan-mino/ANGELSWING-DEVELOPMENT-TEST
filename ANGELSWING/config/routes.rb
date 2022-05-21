Rails.application.routes.draw do
  	resources :projects
	get : "/projects/:id", to: "projects#show_by_id"
	get : "/projects", to: "projects#show_all"
	get : "/projects/my_projects", to: "projects#show_own_all"
	post : "/projects", to: "projects#create"
	put : "/projects/:id", to: "projects#update_by_id"
	delete : "/projects/:id", to: "projects#delete_by_id"
	
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	resource :users, only: [:create]
	post "/auth/signin", to: "users#signin"	# used for signin
	post "/auth/signup", to: "users#signup"	# used for signup
	get "/auth/auto_login", to: "users#auto_login"	# Use to verify that the user is logged in using JWT. 
end
