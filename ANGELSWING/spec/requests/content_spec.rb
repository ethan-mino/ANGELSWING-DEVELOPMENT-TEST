require 'rails_helper'

RSpec.describe "Contents", type: :request do
	# 공통
		# authentication이 필요한지 확인
		# response가 명세와 동일한지 확인
	
		# Parameter validation
			# 존재하지 않는 type이 입력되었을 때, 에러를 발생시키는 지 확인
			# required parameter가 주어지지 않았을 때, 에러를 발생시키는 지 확인
			# permitted parameter 외에 다른 Parameter가 있을 때 proeject를 생성할 수 있는지 확인
	
	# GET /projects/:project_id/contents
		# 해당 프로젝트의 모든 content가 출력되는지 확인
		# 해당 프로젝트가 존재하지 않는 경우
		# 해당 프로젝트의 콘텐츠가 존재하지 않는 경우
		# Projectownername이 올바른지 확인	
	
	# GET /projects/:project_id/contents/:id
		# 해당 프로젝트가 존재하지 않는 경우
		# 해당 프로젝트의 해당 콘텐츠가 존재하지 않는 경우
		# Projectownername이 올바른지 확인	
	
	# POST /projects/:project_id/contents
		# 해당 프로젝트의 소유자만 content를 생성할 수 있는지 확인
	
	# PUT /contents/:id
		# 존재히지 않는 콘텐츠인 경우
		# 소유자가 아닌 경우
	
	# DELETE /contents/:id
		# 존재히지 않는 콘텐츠인 경우
		# 소유자가 아닌 경우
	
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end
end
