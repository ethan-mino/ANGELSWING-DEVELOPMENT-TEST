require 'rails_helper'

RSpec.describe "Users", type: :request do
	# 공통
		# response가 명세와 동일한지 확인	
		# Parameter validation
			# required parameter가 주어지지 않았을 때, 에러를 발생시키는 지 확인
	
	# POST /users/signup
		# 중복된 이메일로 가입 가능한지 확인

	# POST /auth/signin
		# 이메일이 틀렸을 때 로그인 가능한지 확인
		# 비밀번호가 틀렸을 때 로그인 가능한지 확인
	
	# user response validation
	def response_validation 
		# response attributes validation
		expect(body.keys).to contain_exactly('result', 'data')
		expect(result.keys).to contain_exactly('code', 'message')
		expect(data.keys).to contain_exactly('id', 'type', 'attributes')
		expect(attributes.keys).to contain_exactly('token', 'email', 'name', 'country', 'createdAt', 'updatedAt')

		# response value validation
		expect(data['type']).to eql('users')
		expect(attributes['name']).to eql(user1[:last_name] + " " + user1[:first_name])
		expect(attributes['email']).to eql(user1[:email])
		if attributes['country']
			expect(attributes['country']).to eql(user1[:country])
		end
	end
	
	let (:user1) {
		{
			first_name: "minho", 
			last_name: "Gil", 
			email: "valid@email.com", 
			password: "valid",
			country: "seoul"
		}
	}
	
	let (:attributes) {data['attributes']}
	let (:code) {result['code']}
	let (:result) {body['result']}
	let (:data) {body['data']}
	let (:body) {JSON.parse(response.body)}
		
	describe "POST /users/signup" do
		it 'Normal signup' do
			post("/users/signup", params: user1) # Create User

			# user response validation
			response_validation()
			# result code validation
			expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Success Signup
		end

		it 'Duplicate email signup' do
			post("/users/signup", params: user1) # Create user
			post("/users/signup", params: user1) # Create user with the same email
			
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_DUP_ENTRY]) # Duplicate entry
		end
		
		it 'Parameter Validation' do
			REQUIRED = [:first_name, :last_name, :email, :password]
			REQUIRED.each do |required_param|
				param = user1.clone
				param.delete(required_param)
				
				post("/users/signup", params: param)
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Parameter Missing
			end
		end
  	end
	
	describe "/auth/signin" do
		let (:valid_account) {{auth: {email: user1[:email], password: user1[:password]}}}
		let (:invalid_pwd) {{auth: {email: user1[:email], password: "invalid"}}}
		let (:invalid_email) {{auth: {email: "invalid@email.com", password: user1[:password]}}}
		let (:token){attributes['token']}
		
		it 'Valid account Login' do # Valid account Login
			post("/users/signup", params: user1) # Create User
			post('/auth/signin', params: valid_account) # login
						
			# user response validation
			response_validation()

			# result code validation
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # create user successfully
			
			get('/auth/auto_login', headers: {'Authorization' => "Bearer " + token}) # Token login
			
			# result code validation
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # login Success
		end
		
		it 'Invalid account Login' do # Invalid account Login
			post("/users/signup", params: user1) # create user
			invalid = [invalid_email, invalid_pwd]
			
			invalid.each do |invalid_account|
				post('/auth/signin', params: invalid_account) # Invalid Login
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_INVALID_ACCOUNT]) # Fail to login
			end
		end
		
		it 'Parameter Validation' do
			required = [:auth]
			required.each do |required_param|
				param = valid_account.clone
				param.delete(required_param)
				
				post("/auth/signin", params: param)
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Parameter Missing
			end
			
			required = [:email, :password]
			required.each do |required_param|
				param = valid_account.deep_dup
				param[:auth].delete(required_param)
				
				post("/auth/signin", params: param)
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Parameter Missing
			end
		end
	end
end

