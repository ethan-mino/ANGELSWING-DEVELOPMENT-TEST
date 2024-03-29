class UsersController < ApplicationController
	before_action :authorized, only: [:auto_login]
			
	# POST /users/signup
	def signup
		begin
			@user = User.create(user_params) # create user
		rescue ActiveRecord::RecordNotUnique => e	# If the email is duplicated 
			render json: ApiResponse.response(:ERR_DUP_ENTRY, nil) # Duplicate entry
		rescue ActionController::ParameterMissing => e # parameter missing
			render json: ApiResponse.response(:ERR_PARAM_MISSING, nil) # Required parameter is missing
		rescue => e
			render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
		else
			if @user.valid?	
			  render json: ApiResponse.response(:INF_SUCCESS, handle_user_data(@user)) # Successfully processed.
			else
			  render json: ApiResponse.response(:ERR_DB, nil) # DB ERROR.
			end
		end
	end

	# POST /auth/signin
	def signin
		begin
			params = login_params()
		rescue ActionController::ParameterMissing => e # parameter missing
			render json: ApiResponse.response(:ERR_PARAM_MISSING, nil)	# Required parameter is missing
		rescue => e
			render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
		else
			auth = params[:auth]
			@user = User.find_by(email: auth[:email]) # email, unique: true
			if @user && @user.authenticate(auth[:password]) # Email exists and password is the same
				render json: ApiResponse.response(:INF_SUCCESS, handle_user_data(@user)) # Successfully processed.
			else
				render json: ApiResponse.response(:ERR_INVALID_ACCOUNT, nil) # Email or password is not valid.
			end
		end
	end

	def auto_login
		render json: ApiResponse.response(:INF_SUCCESS, handle_user_data(@user))
	end
	
	private

	def handle_user_data(user)	# method for processing user info
		if user
			token = encode_token({user_id: user.id})
			username = User.username(user.first_name, user.last_name)

			{
				id: user.id, 
				type: User::TYPE, 
				attributes: {
					token: token,
					email: user.email,
					name: username,
					country: user.country,
					created_at: user.created_at,
					updated_at: user.updated_at
				}
			}
		else
			nill
		end
	end

	REQUIRED = [:first_name, :last_name, :email, :password]
	PERMITTED = REQUIRED + [:country]
	
	def login_params # for Strong parameter
		params.require(:auth).require([:email, :password])
		params
	end

	def user_params # for Strong parameter
		params.require(REQUIRED)
		params.permit(PERMITTED)
	end

end