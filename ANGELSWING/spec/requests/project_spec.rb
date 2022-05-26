require 'rails_helper'

RSpec.describe "Projects", type: :request do
	# 공통
		# authentication이 필요한지 확인 ✓
		# response가 명세와 동일한지 확인 ✓

		# Parameter validation
			# 존재하지 않는 type이 입력되었을 때, 에러를 발생시키는 지 확인 ✓
			# required parameter가 주어지지 않았을 때, 에러를 발생시키는 지 확인 ✓

	# GET /projects, # GET project/:id  
		# 정상 요청 ✓
		# project가 존재하지 않는 경우 ✓
		# 프로젝트를 생성한 유저가 올바른지 확인	✓

	# GET /projects/my_projects
		# 정상 요청 ✓
		# 프로젝트가 존재하지 않는 경우 ✓
		# 프로젝트를 생성한 유저가 올바른지 확인 ✓
		# 다른 유저의 프로젝트가 포함되지 않는지 확인 ✓

	# POST /projects
		# 정상 요청 ✓
		# 존재하지 않는 project type이 주어진 경우 ✓

	# PUT /projects/:id
		# 정상 요청 ✓
		# 존재하지 않는 project type이 주어진 경우 ✓
		# 존재하지 않는 project인 경우 ✓
		# 본인이 생성한 프로젝트가 아닌 경우 ✓

	# DELETE /projects/:id
		# 정상 요청 ✓ 
		# 존재하지 않는 project인 경우 ✓
		# 본인이 생성한 프로젝트가 아닌 경우 ✓
		# 프로젝트에 속하는 모든 콘텐츠가 삭제되는지 확인 ✓

	def data_validation (each_data) # 응답의 'data' 속성을 검증하는 메서드
		attributes = each_data['attributes']
		
		expect(each_data.keys).to contain_exactly('id', 'type', 'attributes') # data가 포함해야하는 속성
		expect(attributes.keys).to contain_exactly('title', 'thumbnail', 'description', 'location', 'type', 'ownerName', 'createdAt', 'updatedAt') # attributes가 포함해야하는 속성

		# response value validation
		expect(each_data['type']).to eql('project') # type이 'project'인지 확인
		
		project_id = each_data['id'] # 프로젝트 id
		project = project_map[project_id]
		user_id = project['user_id'] # 프로젝트 소유자의 id
		
		 # 프로젝트를 생성할 때와 동일한 값이 저장되었는지 확인
		["title", "description", "location", "type"].each do |attribute|
			expect(attributes[attribute]).to eql(project[attribute])
		end
		
		user = user_map[user_id][:user] # 프로젝트 소유자
		ownerName = user.last_name + " " + user.first_name # # 프로젝트 소유자의 이름
		
		expect(attributes['ownerName']).to eql(ownerName) # 소유자 확인
		expect(project['thumbnail']).to eql(File.basename(attributes['thumbnail'])) # thumbnail 확인
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
	COMMON_PWD = '1234' # 모든 유저의 공통 password
	
	# Factory
	let(:users) {create_list(:user, USER_NUM)}	# USER_NUM개의 유저 계정 생성
	let(:projects) {[]} # 생성된 모든 project
	let(:user_map) {Hash.new} # (user_id => {user: user, project: {project_id => project}}) 
	let(:project_map) {Hash.new} # (project_id => project)
	
	# Response 
	let (:body) {JSON.parse(response.body)}
	let (:result) {body['result']}
	let (:data) {body['data']}
	let (:code) {result['code']}
	
	# Login User
	let (:valid_project) {projects[0][0].attributes} # POST/PUT에서 project 생성/수정에 사용될 정보 (유효한 project)
	
	let (:login_user) {users[0]} # 로그인에 사용될 유저
	let (:login_info) {{auth: {email: login_user.email, password: COMMON_PWD}}}	# 로그인에 사용될 유저 정보
		
	describe 'Authentication Test' do # 인증이 필요한 API에 인증 없이 요청한 경우
		describe 'Request API without authentication' do
			it 'GET /projects/my_projects' do
				get('/projects/my_projects')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
			
			it 'POST /projects' do
				post('/projects')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
			
			it 'PUT /projects/:id' do
				put('/projects/1')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
			
			it 'DELETE /projects/:id' do
				delete('/projects/1')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH]) # Please Log in.
			end
		end
	end

	describe 'Test based on project presence' do # 프로젝트의 존재 유무에 따라 Test
		context 'When project exists' do # 프로젝트가 존재할 때
			before do		
				thumbnail = fixture_file_upload('files/angel_swing_logo.png', 'image/png') # thumnail file
				users.each do |user| 
					project_list = create_list(	# PROJECT_NUM_PER_USER개의 project 생성
						:project, 
						PROJECT_NUM_PER_USER, 
						thumbnail: thumbnail, 
						user_id: user.id
					)
					
					projects.append(project_list)
					
					user_map[user.id] = {:user => user}
					user_map[user.id][:project] = Hash.new
					project_list.each do |project|
						user_map[user.id][:project][project.id] = project.attributes
						project_map[project.id] = project.attributes;
					end
				end
				
				@valid_project_id = Project.where("user_id = ?", login_user.id)[0].id # 로그인한 유저가 생성한 project의 id
				@invalid_project_id = Project.where("user_id = ?", login_user.id + 1)[0].id # 로그인한 유저가 생성하지 않은 project의 id
				@not_exist_project_id = -1 # 존재하지 않는 project의 id 
			end	
	
			describe 'API requiring authentication' do # 인증이 필요한 API
				before do
					post('/auth/signin', params: login_info) # login_info로 로그인 수행
					@token = JSON(response.body)['data']['attributes']['token'] # 로그인 token
					@Authorization = "Bearer " + @token # Authorization 헤더의 value
					
					valid_project[:thumbnail] = fixture_file_upload('files/angel_swing_logo.png', 'image/png') # valid_project의 thumbnail 설정
				end
				
				describe 'Parameter Validation' do # 필수 인자가 제거되었을 경우 (PUT은 필수 인자가 없기 때문에 validation을 수행하지 않음)
					before do
						valid_project.delete(:thumbnail) # "thumnail", :thumnail 속성이 존재하기 때문에 :thumbnail 속성은 먼저 제거
						@REQUIRED = ["title", "type", "location", "thumbnail"] # POST의 필수 인자
					end

					it 'POST /projects' do
						@REQUIRED.each do |required_param| # 필수 인자를 하나씩 지우고, POST 요청
							param = valid_project.clone
							param.delete(required_param)
							
							post("/projects", params: param, headers: {'Authorization' => @Authorization})
							expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Required parameter is missing.
						end
					end
				end
			
				it 'GET /projects/my_projects Normal Request' do
					get('/projects/my_projects', headers: {'Authorization' => @Authorization}) # 로그인한 유저의 프로젝트 GET 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.

					# 프로젝트가 존재할 때이므로, data가 Array이고, 비어있지 않아야함.
					expect(data).to be_a_kind_of(Array) 	
					expect(data).to_not be_empty	

					# Response가 적절한지 Validation
					response_validation()

					# 로그인한 유저의 프로젝트만 포함되어 있는지 확인
					data.each do |each_data|	
						attributes = each_data['attributes']
						ownerName = login_user.last_name + " " + login_user.first_name
						
						expect(attributes['ownerName']).to eql(ownerName)
					end
				end
				
				describe 'POST TEST' do
					it "POST /projects Normal Request" do # 정상적인 프로젝트 생성
						post('/projects', params: valid_project, headers: {'Authorization' => @Authorization}) # 프로젝트 생성

						project_id = data['id'] # 프로젝트 id
						project_map[project_id] = valid_project

						# Response가 적절한지 Validation
						response_validation()

						expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
						
						get("project/#{project_id}")
						expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_SUCCESS]) # 생성한 프로젝트가 저장되었는지 확인
					end

					it "POST /projects Invalid Type" do # 유효하지 않은 Project type인 경우
						valid_project[:type] = "invalid_type" # 허용되지 않는 project type
						post('/projects', params: valid_project, headers: {'Authorization' => @Authorization}) # 프로젝트 생성

						expect(code).to eql(ApiResponse::CODE[:ERR_INVALID_VALUE]) # Value is invalid.
					end
				end
				
				describe 'PUT TEST' do
					it "PUT /projects/:id Normal Request" do # 정상적인 프로젝트 수정
						put("/projects/#{@valid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) # 프로젝트 소유자가 프로젝트를 수정
						# Response가 적절한지 Validation
						response_validation()

						expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					end

					it "PUT /projects/:id Invalid Type" do # 유효하지 않은 Project type인 경우
						valid_project[:type] = "invalid_type" # 허용되지 않는 project type
						put("/projects/#{@valid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

						expect(code).to eql(ApiResponse::CODE[:ERR_INVALID_VALUE]) # Value is invalid.
					end

					it "PUT /projects/:id Invalid project id" do # 프로젝트 소유자가 아닌 경우
						put("/projects/#{@invalid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

						expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON]) # You do not have permission.
					end

					it "PUT /projects/:id not exist project id" do # 존재하지 않는 프로젝트 id인 경우 
						put("/projects/#{@not_exist_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

						expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST]) # Data does not exist.
					end
				end

				describe 'DELETE TEST' do # 프로젝트 제거
					CONTENT_NUM_PER_PROJECT = 10 # 프로젝트 당 content의 개수
					before do
						content_list = create_list(	# content 생성
							:content, 
							CONTENT_NUM_PER_PROJECT, 
							user_id: login_user.id, # 로그인 한 유저의 id
							project_id: @valid_project_id # 로그인 한 유저가 생성한 프로젝트의 id
						)
					end

					it "DELETE /projects/:id Normal Request" do # 정상적인 프로젝트 제거
						delete("/projects/#{@valid_project_id}", headers: {'Authorization' => @Authorization})  # 소유자의 프로젝트 제거
						expect(code).to eql(ApiResponse::CODE[:INF_DELETED]) # Deleted.

						# 해당 프로젝트의 contents가 모두 제거되는지 확인
						get("/projects/#{@valid_project_id}/contents") 
						expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data.
					end

					it "DELETE /projects/:id Invalid project id" do # 프로젝트 소유자가 아닌 경우
						delete("/projects/#{@invalid_project_id}", headers: {'Authorization' => @Authorization}) 

						expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON]) # You do not have permission.
					end

					it "DELETE /projects/:id not exist project id" do # 존재하지 않는 프로젝트 id인 경우 
						delete("/projects/#{@not_exist_project_id}", headers: {'Authorization' => @Authorization}) 

						expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST]) # Data does not exist.
					end
				end
			end

			describe 'API Not requiring authentication' do # 인증이 필요하지 않은 API
				it 'GET /projects Normal Request' do # 정상적인 모든 프로젝트 요청
					get('/projects') # 모든 프로젝트 GET 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.

					# 프로젝트가 존재할 때이므로, data가 Array이고, 비어있지 않아야함.
					expect(data).to be_a_kind_of(Array) 	
					expect(data).to_not be_empty	

					# # Response가 적절한지 Validation
					response_validation()
				end

				it 'GET /project/:id Normal Request' do # 정상적인 단일 프로젝트 요청
					get("/projects/#{@valid_project_id}") # id가 project_id인 프로젝트 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS]) # Successfully processed.
					expect(data).not_to be_nil

					# Response가 적절한지 Validation
					response_validation()
				end
			end
		end

		context 'When project not exists' do # 프로젝트가 존재하지 않을 때
			describe 'API requiring authentication' do # 인증이 필요한 API
				before do
					post('/auth/signin', params: login_info) # login_info로 로그인 수행
					@token = JSON(response.body)['data']['attributes']['token'] # 로그인 token
					@Authorization = "Bearer " + @token # Authorization 헤더의 value
				end
				
				it 'GET /projects/my_projects' do # 로그인한 유저의 모든 프로젝트 요청
					get('/projects/my_projects', headers: {'Authorization' => @Authorization}) # 로그인한 유저의 모든 프로젝트 GET 요청
					
					expect(body.keys).to contain_exactly('result') # 프로젝트가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
			end

			describe 'API Not requiring authentication' do # 인증이 필요하지 않으 API
				it 'GET /projects' do
					get('/projects')	# 모든 프로젝트 GET 요청

					expect(body.keys).to contain_exactly('result') # 프로젝트가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
				
				it 'GET /projects/:id' do
					get('/projects/1')	# id가 1인 프로젝트 GET 요청

					expect(body.keys).to contain_exactly('result') # 프로젝트가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
			end
		end
	end
end
