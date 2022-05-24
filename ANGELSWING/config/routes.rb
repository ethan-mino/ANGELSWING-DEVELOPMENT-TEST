Rails.application.routes.draw do
	# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
	resource :users, only: [:create]
	post "/auth/signin", to: "users#signin"	# used for signin
	post "/users/signup", to: "users#signup"	# used for signup
	post "/auth/auto_login", to: "users#auto_login"	# used for signup

	resources :projects, except: [:show, :update, :destroy]
	get "/projects/my_projects", to: "projects#show_own_all"
	get "/projects", to: "projects#index"
	get "/projects/:id", to: "projects#show_by_id"
	post "/projects", to: "projects#create"
	put "/projects/:id", to: "projects#update_by_id"
	delete "/projects/:id", to: "projects#delete_by_id"
	
	resources :contents, except: [:show, :update, :destroy]
	get "/projects/:project_id/contents", to: "contents#show_by_project_id"
	get "/projects/:project_id/contents/:id", to: "contents#show_by_id"
	post "/projects/:project_id/contents", to: "contents#create"
	put "contents/:id", to: "contents#update_by_id"
	delete "contents/:id", to: "contents#delete_by_id"
end
