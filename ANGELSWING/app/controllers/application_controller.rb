class ApplicationController < ActionController::API
	before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, ENV['BCRYPT_SECRET'])
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
		# header: { 'Authorization': 'Bearer <token>' }
		token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, ENV['BCRYPT_SECRET'], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      id = decoded_token[0]['user_id']
      @user = User.find_by(id: id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end