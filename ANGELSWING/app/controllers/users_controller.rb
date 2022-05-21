class UsersController < ApplicationController
  before_action :authorized, only: [:auto_login]
  @@TYPE = "users"
	
  # REGISTER
  def create
    @user = User.create(user_params)
    if @user.valid?
      token = encode_token({user_id: @user.id})
      render json: {user: @user, token: token}
    else
      render json: {error: "Invalid username or password"}
    end
  end

  # LOGGING IN
  def login
	auth = params[:auth]
    @user = User.find_by(email: auth[:email]) # email, unique: true
    if @user && @user.authenticate(auth[:password])
      token = encode_token({user_id: @user.id})
      name = @user["last_name"] + " " + @user["first_name"]
      
      render json: 
				{data: {
						id: @user.id, 
		  				type: @@TYPE, 
		  				attributes: {
							token: token,
							email: @user.email,
							name: name,
							country: @user.country,
							created_at: @user.created_at,
							updated_at: @user.updated_at
						}
					}
				}
    else
      render json: {error: "Invalid email or password"}
    end
  end


  def auto_login
    render json: @user
  end

  private

  def user_params
    params.permit(:username, :password, :age)
  end

end