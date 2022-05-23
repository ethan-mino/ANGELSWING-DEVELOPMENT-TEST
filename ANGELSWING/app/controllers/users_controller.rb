class UsersController < ApplicationController
  before_action :authorized, only: [:auto_login]
  @@TYPE = "users"
		
  # REGISTER
  def signup
	begin
    	@user = User.create(user_params)
	rescue ActiveRecord::RecordNotUnique => e	# If the email is duplicated 
		render json: ApiResponse.response("ERROR-000", nil)
	rescue ActionController::ParameterMissing => e # parameter missing
		render json: ApiResponse.response("ERROR-300", nil)
	rescue => e
		render json: ApiResponse.response("ERROR-500", nil)
	else
		if @user.valid?	
		  render json: ApiResponse.response("INFO-200", handle_user_data())
		else
		  render json: ApiResponse.response("ERROR-310", nil)
		end
	end
  end

  
  def signin
	begin
		params = login_params()
	rescue ActionController::ParameterMissing => e # parameter missing
		render json: ApiResponse.response("ERROR-300", nil)
	rescue => e
		render json: ApiResponse.response("ERROR-500", nil)
	else
		auth = params[:auth]
		@user = User.find_by(email: auth[:email]) # email, unique: true
		if @user && @user.authenticate(auth[:password]) 
			render json: ApiResponse.response("INFO-200", handle_user_data())
		else
			render json: ApiResponse.response("ERROR-010", nil) # fail to authenticate
		end
	end
  end


  def auto_login
	attributes = @user.attributes  
	['password_digest'].each {|attribute| attributes.delete(attribute)}
    render json: attributes
  end

  private
	
  def handle_user_data	# method for processing user info
	token = encode_token({user_id: @user.id})
	username = User.username(@user.first_name, @user.last_name)
	  
	{
		id: @user.id, 
		type: @@TYPE, 
		attributes: {
			token: token,
			email: @user.email,
			name: username,
			country: @user.country,
			created_at: @user.created_at,
			updated_at: @user.updated_at
		}
	}
  end
	
  def login_params # for Strong parameter
	puts params.require(:auth).require([:email, :password])
	params
  end

  def user_params # for Strong parameter
    required = [:first_name, :last_name, :email, :password]
	permitted = required + [:country]
	params.require(required)
	params.permit(permitted)
  end

end