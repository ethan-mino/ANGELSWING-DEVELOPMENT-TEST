require 'rails_helper'

RSpec.describe "Users", type: :request do
	# 공통
		# response가 명세와 동일한지 확인
	
		# Parameter validation
			# 존재하지 않는 type이 입력되었을 때, 에러를 발생시키는 지 확인
			# required parameter가 주어지지 않았을 때, 에러를 발생시키는 지 확인
			# permitted parameter 외에 다른 Parameter가 있을 때 proeject를 생성할 수 있는지 확인
	
	# POST /users/signup
		# 중복된 이메일로 가입 가능한지 확인

	# POST /auth/signin
		# 이메일이 틀렸을 때 로그인 가능한지 확인
		# 비밀번호가 틀렸을 때 로그인 가능한지 확인
	
end
