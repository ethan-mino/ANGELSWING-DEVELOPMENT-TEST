require 'rails_helper'

RSpec.describe "Contents", type: :request do
	# 공통
		# authentication이 필요한지 확인 ✓
		# response가 명세와 동일한지 확인 ✓
	
		# Parameter validation
			# required parameter가 주어지지 않았을 때, 에러를 발생시키는 지 확인 ✓
	
	# GET /projects/:project_id/contents
		# 정상 요청  ✓
		# 모두 id가 project_id인 프로젝트의 콘텐츠인지 확인 ✓
		# 해당 프로젝트가 존재하지 않는 경우 ✓
		# 해당 프로젝트는 존재하지만,  콘텐츠가 존재하지 않는 경우 ✓
	
	# GET /projects/:project_id/contents/:id
		# 정상 요청 ✓
		# 해당 프로젝트가 존재하지 않는 경우 ✓
		# id가 project_id인 프로젝트의 콘텐츠인지 확인 ✓
		# 해당 프로젝트의 해당 콘텐츠가 존재하지 않는 경우 ✓	
	
	# POST /projects/:project_id/contents
		# 정상 요청 ✓
		# 프로젝트 소유자가 아닌 경우 ✓
	
	# PUT /contents/:id
		# 정상 요청 ✓
		# 존재하지 않는 콘텐츠인 경우 ✓
		# 프로젝트 소유자가 아닌 경우 ✓
	
	# DELETE /contents/:id
		# 정상 요청  ✓
		# 존재하지 않는 콘텐츠인 경우 ✓
		# 프로젝트 소유자가 아닌 경우 ✓
	
def data_validation (each_data) # 응답의 'data' 속성을 검증하는 메서드
		attributes = each_data['attributes']
		
		expect(each_data.keys).to contain_exactly('id', 'type', 'attributes') # data가 포함해야하는 속성
		expect(attributes.keys).to contain_exactly('projectId', 'projectOwnerName', 'title', 'body', 'createdAt', 'updatedAt') # attributes가 포함해야하는 속성

		# response value validation
		expect(each_data['type']).to eql('content') # type이 'content'인지 확인
		
		project_id = attributes['project_id'] # project id
		content_id = each_data['id'] # content id
		content = content_map[content_id]
		user_id = content['user_id'] # content 소유자의 id
		
		 # contents를 생성할 때와 동일한 값이 저장되었는지 확인
		["title", "body"].each do |attribute|
			expect(attributes[attribute]).to eql(content[attribute])
		end
		
		user = user_map[user_id][:user] # content 소유자
		projectOwnerName = user.last_name + " " + user.first_name # project 소유자의 이름
		
		expect(attributes['projectOwnerName']).to eql(projectOwnerName) # 소유자 확인
	end
	
	def response_validation # Response의 형식과 값이 올바른지 확인
		expect(body.keys).to contain_exactly('result', 'data')
		expect(result.keys).to contain_exactly('code', 'message')
		
		if data.kind_of?(Array)	# data가 Array인 경우
			data.each do |each_data|
				data_validation(each_data) # data 각각에 대해서 검증
			end
		else	# data가 Array가 아닌 경우
			data_validation(data) # data에 대해 검증
		end
	end

	USER_NUM = 5	# 유저 계정의 개수
	PROJECT_NUM_PER_USER = 3 # 한 계정당 프로젝트의 개수
	CONTENT_NUM_PER_PROJECT = 5 # 하나의 프로젝트당 콘텐츠의 개수
	COMMON_PWD = '1234' # 모든 유저의 공통 password
	
	# Factory
	let(:users) {create_list(:user, USER_NUM)}	# USER_NUM개의 유저 계정 생성
	let(:contents) {[]} # 생성된 모든 콘텐츠
	let(:user_map) {Hash.new} # (user_id => {user: user, project: {project_id => project}) 
	let(:project_map) {Hash.new} # (project_id => {project: project, content: {content_id => content}) 
	let(:content_map) {Hash.new} # (content_id => content)
	
	# Response 
	let (:body) {JSON.parse(response.body)}
	let (:result) {body['result']}
	let (:data) {body['data']}
	let (:code) {result['code']}
	
	# Login User
	let (:valid_content) {contents[0][0].attributes} # POST/PUT에서 content 생성/수정에 사용될 정보 (유효한 content)
	
	let (:login_user) {users[0]} # 로그인에 사용될 유저
	let (:login_info) {{auth: {email: login_user.email, password: COMMON_PWD}}}	# 로그인에 사용될 유저 정보
		
	describe 'Authentication Test' do # 인증이 필요한 API에 인증 없이 요청한 경우
		describe 'Request API without authentication' do
			it 'POST /projects/:project_id/contents' do
				post('/projects/:project_id/contents')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
			
			it 'PUT /contents/:id' do
				put('/contents/:id')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
			
			it 'DELETE /contents/:id' do
				delete('/contents/:id')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
		end
	end

	describe 'Test based on project/content presence' do # project/content의 존재 유무에 따라 Test
		context 'When project/content exists' do # project/content가 존재할 때
			before do							
				users.each do |user| 
					thumbnail = fixture_file_upload('files/angel_swing_logo.png', 'image/png') # thumnail file
					
					project_list = create_list(	# PROJECT_NUM_PER_USER개의 project 생성
						:project, 
						PROJECT_NUM_PER_USER, 
						thumbnail: thumbnail, 
						user_id: user.id
					)
					
					user_map[user.id] = {:user => user}
					
					project_list.each do |project|
						content_list = create_list(	# CONTENT_NUM_PER_PROJECT개의 content 생성
							:content, 
							CONTENT_NUM_PER_PROJECT, 
							project_id: project.id,
							user_id: user.id
						)
						
						contents.append(content_list)
						
						user_map[user.id][:project] = Hash.new
						project_map[project.id] = Hash.new
						user_map[user.id][:project][project.id] = project.attributes
						project_map[project.id][:project] = project.attributes;

						content_list.each do |content|
							project_map[project.id][:content] = Hash.new
							project_map[project.id][:content][content.id] = content # (project_id => {project: project, content: {content_id => content})  
							content_map[content.id] = content
						end
					end
				end
				
				@exist_project_id = Project.all[0].id # 존재하는 프로젝트의 id
				@exist_content_id = Content.where("project_id = ?", @exist_project_id)[0].id # @exist_project_id의 존재하는 content의 id
				@invalid_project_id = Project.where("user_id = ?", login_user.id + 1)[0].id # 로그인한 유저가 생성하지 않은 project의 id
				@invalid_content_id = Content.where("project_id = ?", @invalid_project_id)[0].id # 로그인한 유저가 생성하지 않은 프로젝트의 콘텐츠 id
				@not_exist_content_id = -1; # 존재하지 않는 콘텐츠의 ID
			end	
	
			describe 'API requiring authentication' do # 인증이 필요한 API
				before do
					post('/auth/signin', params: login_info) # login_info로 로그인 수행
					@token = JSON(response.body)['data']['attributes']['token'] # 로그인 token
					@Authorization = "Bearer " + @token # Authorization 헤더의 value
				end
				
				describe 'Parameter Validation' do # 필수 인자가 제거되었을 경우 (PUT은 필수 인자가 없기 때문에 validation을 수행하지 않음)
					before do
						@REQUIRED = ["title", "body"] # POST의 필수 인자
					end

					it 'POST /projects/:project_id/contents' do
						@REQUIRED.each do |required_param| # 필수 인자를 하나씩 지우고, POST 요청
							param = valid_content.clone
							param.delete(required_param)

							post("/projects/#{@exist_project_id}/contents", params: param, headers: {'Authorization' => @Authorization})
							expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Required parameter is missing.
						end
					end
				end
				
				describe 'POST TEST' do
					it 'POST /projects/:project_id/contents Normal Request' do
						post("/projects/#{@exist_project_id}/contents", params: valid_content, headers: {'Authorization' => @Authorization}) # 소유한 프로젝트의 콘텐츠 생성
						
						content_id = data['id'] # 콘텐츠 id
						content_map[content_id] = valid_content
						
						# Response가 적절한지 Validation
						response_validation()
					
						expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					
						get("/projects/#{@exist_project_id}/contents/#{content_id}") # 생성한 콘텐츠가 저장되었는지 확인
						expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					end
					
					it 'POST /projects/:project_id/contents' do # 소유하지 않은 프로젝트의 콘텐츠를 생성하려는 경우
						post("/projects/#{@invalid_project_id}/contents", params: valid_content, headers: {'Authorization' => @Authorization})
						
						expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON]) # You do not have permission.
					end
				end

				describe 'PUT TEST' do
					it "PUT /contents/:id Normal Request" do # 정상적인 콘텐츠 수정
						put("/contents/#{@exist_content_id}", params: valid_content, headers: {'Authorization' => @Authorization}) # 프로젝트 소유자가 콘텐츠를 수정
						
						# Response가 적절한지 Validation
						response_validation()
						
						expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					end
					
					it "PUT /contents/:id" do # 존재하지 않는 콘텐츠인 경우
						put("/contents/#{@not_exist_content_id}", params: valid_content, headers: {'Authorization' => @Authorization}) 
						
						expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST]) # Data does not exist.
					end
					
					it "PUT /contents/:id" do # 소유하지 않은 콘텐츠인 경우
						put("/contents/#{@invalid_content_id}", params: valid_content, headers: {'Authorization' => @Authorization})
						
						expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON]) # You do not have permission.
					end
				end

				describe 'DELETE TEST' do # 프로젝트 제거
					it "DELETE /contents/:id Normal Request" do # 정상적인 콘텐츠 제거
						delete("/contents/#{@exist_content_id}", headers: {'Authorization' => @Authorization})  # 프로젝트 소유자가 존재하는 콘텐츠 제거
						expect(code).to eql(ApiResponse::CODE[:INF_DELETED]) # Deleted.

						# 해당 콘텐츠가 지워졌는지 확인
						get("/projects/#{@exist_project_id}/contents/#{@exist_content_id}") 
						expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data.
					end
					
					it "DELETE /contents/:id" do # 존재하지 않는 콘텐츠인 경우
						delete("/contents/#{@not_exist_content_id}", headers: {'Authorization' => @Authorization})  
						expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST]) # Data does not exist.
					end
					
					it "DELETE /contents/:id" do # 소유하지 않은 콘텐츠인 경우
						delete("/contents/#{@invalid_content_id}", headers: {'Authorization' => @Authorization}) 
						expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON]) # You do not have permission.
					end
				end
					
			end

			describe 'API Not requiring authentication' do # 인증이 필요하지 않은 API
				it 'GET /projects/:project_id/contents Normal Request' do # 정상적인 콘텐츠 요청
					get("/projects/#{@exist_project_id}/contents")
					
					# Response가 적절한지 Validation
					response_validation()
					
					# 프로젝트와 콘텐츠가 존재할 때이므로, data가 Array이고, 비어있지 않아야함.
					expect(data).to be_a_kind_of(Array) 	
					expect(data).to_not be_empty	
					
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					expect(data).not_to be_nil
					
					data.each do |each_data|	
						attributes = each_data['attributes']
						expect(attributes['projectId']).to eql(@exist_project_id)	# 해당 프로젝트의 콘텐츠만 포함되는지 확인
					end
				end
				
				it 'GET /projects/:project_id/contents/:id Normal Request' do # 정상적인 콘텐츠 요청
					get("/projects/#{@exist_project_id}/contents/#{@exist_content_id}")
					
					# Response가 적절한지 Validation
					response_validation()
					
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					expect(data).not_to be_nil
					
					expect(data['id']).to eql(@exist_content_id) # 해당 콘텐츠인지 확인
				end
				
				it 'GET /projects/:project_id/contents/:id' do # 프로젝트는 존재하지만, 콘텐츠는 존재하지 않을 때
					get("/projects/#{@exist_project_id}/contents/#{@not_exist_content_id}")
					
					expect(body.keys).to contain_exactly('result') # 콘텐츠가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
			end
		end

		context 'When project/content not exists' do # 프로젝트와 콘텐츠가 존재하지 않을 때
			describe 'API Not requiring authentication' do # 인증이 필요하지 않은 API
				it 'GET /projects/:project_id/contents' do # 해당 프로젝트가 존재하지 않을 때
					get('/projects/1/contents')
					
					expect(body.keys).to contain_exactly('result') # 프로젝트가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
				
				it 'GET GET /projects/:project_id/contents/:id' do # 프로젝트와 콘텐츠 모두 존재하지 않을 때
					get('/projects/1/contents/1')
					
					expect(body.keys).to contain_exactly('result') # 프로젝트와 콘텐츠가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
			end
		end
	end
end
