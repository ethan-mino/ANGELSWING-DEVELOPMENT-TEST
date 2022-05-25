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
		
		expect(each_data.keys).to contain_exactly('id', 'type', 'attributes')
		expect(attributes.keys).to contain_exactly('title', 'thumbnail', 'description', 'location', 'type', 'ownerName', 'createdAt', 'updatedAt')

		# response value validation
		expect(each_data['type']).to eql('project') # type이 'project'인지 확인
		
		project_id = each_data['id'] # 프로젝트 id
		project = project_map[project_id]
		user_id = project['user_id'] # 프로젝트 소유자의 id
		
		["title", "description", "location", "type"].each do |attribute| # 프로젝트를 생성할 때와 동일한 값이 저장되었는지 확인
			expect(attributes[attribute]).to eql(project[attribute])
		end
		
		# 프로젝트를 생성할 때와 동일한 값이 저장되었는지 확인
		user = user_map[user_id][:user] # 프로젝트 소유자
		ownerName = user.last_name + " " + user.first_name # # 프로젝트 소유자의 이름
		
		expect(attributes['ownerName']).to eql(ownerName)
		expect(project['thumbnail']).to eql(File.basename(attributes['thumbnail']))
	end
	
	def response_validation # response의 속성을 검증하는 메서드
		expect(body.keys).to contain_exactly('result', 'data')
		expect(result.keys).to contain_exactly('code', 'message')
		
		if data.kind_of?(Array)	# data가 Array인 경우
			data.each do |each_data|
				data_validation(each_data) # data 각각에 대해서 validation
			end
		else	# data가 Array가 아닌 경우
			data_validation(data) # data에 대해 validation
		end
	end

	USER_NUM = 5	# 유저 계정의 개수
	PROJECT_NUM_PER_USER = 3 # 유저 한 계정당 프로젝트의 개수
	COMMON_PWD = '1234' # 모든 유저의 공통 password
	
	# Factory
	let(:users) {create_list(:user, USER_NUM)}	# USER_NUM개의 유저 계정 생성
	let(:projects) {[]}
	let(:user_map) {Hash.new} # (user_id => {user: user, project: {project_id => project}}) 
	let(:project_map) {Hash.new} # (project_id => project)
	
	# Response 
	let (:body) {JSON.parse(response.body)}
	let (:result) {body['result']}
	let (:data) {body['data']}
	let (:code) {result['code']}
	
	# Login User
	let (:valid_project) {projects[0][0].attributes} # POST/PUT에서 project 생성/수정에 사용될 정보 (유효한 project)
	
	let (:login_user) {users[0]} # 로그인한 유저
	let (:login_info) {{auth: {email: login_user.email, password: COMMON_PWD}}}	# 로그인에 사용될 유저 정보
		
	describe 'Authentication Test' do # 인증이 필요한 API에 인증 없이 요청한 경우
		describe 'Request API without authentication' do
			it 'GET /projects/my_projects' do
				get('/projects/my_projects')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH])
			end
			
			it 'POST /projects' do
				post('/projects')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH])
			end
			
			it 'PUT /projects/:id' do
				put('/projects/1')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH])
			end
			
			it 'DELETE /projects/:id' do
				delete('/projects/1')
				expect(code).to eql(ApiResponse::CODE[:ERR_NEED_AUTH])
			end
		end
	end

	describe 'Test based on project presence' do
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
			end	
	
			describe 'API requiring authentication' do # 인증이 필요한 API
				before do
					post('/auth/signin', params: login_info)
					@token = JSON(response.body)['data']['attributes']['token']
					@Authorization = "Bearer " + @token
					
					valid_project[:thumbnail] = fixture_file_upload('files/angel_swing_logo.png', 'image/png')
				end
				
				describe 'Parameter Validation' do # 필수 인자가 제거되었을 경우
					before do
						valid_project.delete(:thumbnail)
						@REQUIRED = ["title", "type", "location", "thumbnail"]
						@valid_project_id = user_map[login_user.id][:project].keys[0] # 로그인한 유저가 생성한 project의 id
					end

					it 'POST /projects' do
						@REQUIRED.each do |required_param|
							param = valid_project.clone
							param.delete(required_param)
							
							post("/projects", params: param, headers: {'Authorization' => @Authorization})
							expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:ERR_PARAM_MISSING]) # Parameter Missing
						end
					end
				end
			
				it 'GET /projects/my_projects Normal Request' do
					get('/projects/my_projects', headers: {'Authorization' => @Authorization}) # 모든 프로젝트 GET 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS])

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
					it "POST /projects Normal Request" do
						post('/projects', params: valid_project, headers: {'Authorization' => @Authorization}) # 모든 프로젝트 GET 요청

						project_id = data['id'] # 프로젝트 id
						project_map[project_id] = valid_project

						# Response가 적절한지 Validation
						response_validation()

						expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS])

					end

					it "POST /projects Invalid Type" do
						valid_project[:type] = "invalid_type" # 허용되지 않는 project type
						post('/projects', params: valid_project, headers: {'Authorization' => @Authorization}) # 모든 프로젝트 GET 요청

						expect(code).to eql(ApiResponse::CODE[:ERR_INVALID_VALUE])
					end
				end
				
				describe 'PUT/DELETE TEST' do
					before do
						@valid_project_id = user_map[login_user.id][:project].keys[0] # 로그인한 유저가 생성한 project의 id
						@invalid_project_id = user_map[login_user.id + 1][:project].keys[0] # 로그인한 유저가 생성하지 않은 project의 id
						@not_exist_project_id = -1 # 존재하지 않는 project의 id
					end
					
					describe 'PUT TEST' do
						it "PUT /projects/:id Normal Request" do
							put("/projects/#{@valid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 
							# Response가 적절한지 Validation
							response_validation()

							expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS])
						end

						it "PUT /projects/:id Invalid Type" do
							valid_project[:type] = "invalid_type" # 허용되지 않는 project type
							put("/projects/#{@valid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

							expect(code).to eql(ApiResponse::CODE[:ERR_INVALID_VALUE])
						end

						it "PUT /projects/:id Invalid project id" do
							put("/projects/#{@invalid_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

							expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON])
						end

						it "PUT /projects/:id not exist project id" do# 모든 프로젝트 GET 요청
							put("/projects/#{@not_exist_project_id}", params: valid_project, headers: {'Authorization' => @Authorization}) 

							expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST])
						end
					end
					
					describe 'DELETE TEST' do
						CONTENT_NUM_PER_PROJECT = 10
						before do
							content_list = create_list(	
								:content, 
								CONTENT_NUM_PER_PROJECT, 
								user_id: login_user.id,
								project_id: @valid_project_id
							)
						end
						
						it "DELETE /projects/:id Normal Request" do
							delete("/projects/#{@valid_project_id}", headers: {'Authorization' => @Authorization}) 
							expect(code).to eql(ApiResponse::CODE[:INF_DELETED])
							
							get("/projects/#{@valid_project_id}/contents")
							expect(JSON(response.body)['result']['code']).to eql(ApiResponse::CODE[:INF_NO_DATA])
						end

						it "DELETE /projects/:id Invalid project id" do
							delete("/projects/#{@invalid_project_id}", headers: {'Authorization' => @Authorization}) 

							expect(code).to eql(ApiResponse::CODE[:ERR_PERMISSON])
						end

						it "DELETE /projects/:id not exist project id" do
							delete("/projects/#{@not_exist_project_id}", headers: {'Authorization' => @Authorization}) 

							expect(code).to eql(ApiResponse::CODE[:ERR_NOT_EXIST])
						end
					end
					
				end
			end

			describe 'API Not requiring authentication' do # 인증이 필요한 API
				it 'GET /projects Normal Request' do
					get('/projects') # 모든 프로젝트 GET 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS])

					# 프로젝트가 존재할 때이므로, data가 Array이고, 비어있지 않아야함.
					expect(data).to be_a_kind_of(Array) 	
					expect(data).to_not be_empty	

					# # Response가 적절한지 Validation
					response_validation()
				end

				it 'GET /project/:id Normal Request' do
					project_id = project_map.keys[0] 

					get("/projects/#{project_id}") # id가 project_id인 프로젝트 요청
					expect(code).to eql(ApiResponse::CODE[:INF_SUCCESS])
					expect(data).not_to be_nil

					# Response가 적절한지 Validation
					response_validation()
				end
			end
		end

		context 'When project not exists' do # 프로젝트가 존재하지 않을 때
			describe 'API requiring authentication' do # 인증이 필요한 API
				before do
					post('/auth/signin', params: login_info)
					@token = JSON(response.body)['data']['attributes']['token']
					@Authorization = "Bearer " + @token
				end
				
				it 'GET /projects/my_projects' do
					get('/projects/my_projects', headers: {'Authorization' => @Authorization}) # 로그인한 유저의 모든 프로젝트 GET 요청
					
					expect(body.keys).to contain_exactly('result') # 프로젝트가 존재하지 않을 때이므로, result만 존재해야 함
					expect(code).to eql(ApiResponse::CODE[:INF_NO_DATA]) # No Data
				end
			end

			describe 'API Not requiring authentication' do # 인증이 필요한 API
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
