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
	def response_validation # Response의 형식과 값이 올바른지 확인
		# response attributes validation
		expect(body.keys).to contain_exactly('result', 'data') # body가 포함할 속성
		expect(result.keys).to contain_exactly('code', 'message') # result가 포함할 속성
		expect(data.keys).to contain_exactly('id', 'type', 'attributes') # data가 포함할 속성
		expect(attributes.keys).to contain_exactly('token', 'email', 'name', 'country', 'createdAt', 'updatedAt') # attributes가 포함할 속성

		# response value validation
		expect(data['type']).to eql('users') # type이 'users'인지 확인
		
		# 회원가입에 사용된 값과 응답의 값이 같은지 확인
		expect(attributes['name']).to eql(user1[:last_name] + " " + user1[:first_name]) 
		expect(attributes['email']).to eql(user1[:email])
		if attributes['country']
			expect(attributes['country']).to eql(user1[:country])
		end
	end
	
	let (:user1) { # 회원가입과 로그인에 사용되는 유저 정보
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
		it 'Normal signup' do # 정상적인 회원가입 테스트
			post("/users/signup", params: user1) # User1 정보로 회원가입

			# user response validation
			response_validation() # Response의 형식과 값이 올바른지 확인
			# result code validation
			expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
		end

		it 'Duplicate email signup' do # 중복 이메일 회원가입 테스트
			post("/users/signup", params: user1) # User1 정보로 회원가입
			post("/users/signup", params: user1) # User1 정보로 회원가입 
			
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_DUP_ENTRY]) # Duplicate entry.
		end
		
		it 'Parameter Validation' do # 필수 Parameter 제거 Case 테스트
			REQUIRED = [:first_name, :last_name, :email, :password] # 회원가입의 필수 인자
			REQUIRED.each do |required_param| # 필수 인자를 하나씩 제거하고 회원가입 요청
				param = user1.clone
				param.delete(required_param)
				
				post("/users/signup", params: param) 
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Required parameter is missing.
			end
		end
  	end
	
	describe "/auth/signin" do
		let (:valid_account) {{auth: {email: user1[:email], password: user1[:password]}}} # 유효한 로그인 정보
		let (:invalid_pwd) {{auth: {email: user1[:email], password: "invalid"}}} # 유효하지 않은 비밀번호를 가진 로그인 정보
		let (:invalid_email) {{auth: {email: "invalid@email.com", password: user1[:password]}}} # 유효하지 않은 이메일을 가진 로그인 정보
		let (:token){attributes['token']}
		
		it 'Valid account Login' do # Valid account Login
			post("/users/signup", params: user1) # Create User
			post('/auth/signin', params: valid_account) # login
						
			# user response validation
			response_validation() # Response의 형식과 값이 올바른지 확인

			# result code validation
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Create user successfully
			
			get('/auth/auto_login', headers: {'Authorization' => "Bearer " + token}) # Token login
			
			# result code validation
			expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Login Success
		end
		
		it 'Invalid account Login' do # 유효하지 않은 정보로 로그인을 시도하는 경우
			post("/users/signup", params: user1) # User1 정보로 회원가입
			invalid = [invalid_email, invalid_pwd] 
			
			invalid.each do |invalid_account| # 유요하지 않은 이메일/비밀번호에 대해 로그인 수행
				post('/auth/signin', params: invalid_account) # Invalid Login
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_INVALID_ACCOUNT]) # Fail to Login
			end
		end
		
		it 'Parameter Validation' do # 필수 Parameter 제거 Case 테스트
			required = [:auth]
			required.each do |required_param| # 'auth'를 로그인 정보에서 제거
				param = valid_account.clone
				param.delete(required_param)
				
				post("/auth/signin", params: param)
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Required parameter is missing.
			end
			
			required = [:email, :password]
			required.each do |required_param| # 
				param = valid_account.deep_dup
				param[:auth].delete(required_param)
				
				post("/auth/signin", params: param)
				expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Required parameter is missing.
			end
		end
	end
end

