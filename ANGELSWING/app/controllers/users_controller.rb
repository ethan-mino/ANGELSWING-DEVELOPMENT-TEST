class UsersController < ApplicationController
  before_action :authorized, only: [:auto_login, :handle_user_info, :username]
  @@TYPE = "users"
		
  # REGISTER
  def signup
	begin
    	@user = User.create(user_params)
	rescue ActiveRecord::RecordNotUnique => e	# If the email is duplicated 
		render json: {error: "duplicate entry"}
	rescue ActionController::ParameterMissing => e # parameter missing
		head 400 # response 400
	else
		if @user.valid?	
		  render json: handle_user_info(), status: :created
		else
		  render json: {error: "Invalid username or password"}
		end
	end
  end

  
  def signin
	begin
		params = login_params()
	rescue ActionController::ParameterMissing => e # parameter missing
		head 400
	else
		auth = params[:auth]
		@user = User.find_by(email: auth[:email]) # email, unique: true
		if @user && @user.authenticate(auth[:password]) 
		  render json: handle_user_info() # if succeed in authenticate
		else
		  render json: {error: "Invalid email or password"} # fail to authenticate
		end
	end
  end


  def auto_login
	attributes = @user.attributes  
	['password_digest'].each {|attribute| attributes.delete(attribute)}
    render json: attributes
  end

  private
	
  def handle_user_info	# method for processing user info
	token = encode_token({user_id: @user.id})
	ownername = User.username()
	{data: {
			id: @user.id, 
			type: @@TYPE, 
			attributes: {
				token: token,
				email: @user.email,
				name: ownername,
				country: @user.country,
				created_at: @user.created_at,
				updated_at: @user.updated_at
			}
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