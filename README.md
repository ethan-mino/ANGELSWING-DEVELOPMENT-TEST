# ANGELSWING DEVELOPMENT TEST

## Environment
	OS : Linux
	ruby : 2.6.10
	rails : 6.0.5
	
## Gems
	## Development 
	'bcrypt' : for password encryption
	'rack-cors' : for CORS
	'jwt' : for JWT authentication
	'mysql2' : for mysql connection and query
	'olive_branch' : for convert JSON to camelCase
	'carrierwave' : for file upload
	
	## Test
	'rspec-rails' for Unit Test
	'database_cleaner' To clean the DB during the test
	'faker', 'factory_girl_rails' for fake data

## Changes
1. 직관성과 Unit Test의 편의성을 위해, Response에 {"result" : {"code" : "ERROR-300", "message" : "Required parameter missing."}}의 데이터 형식을 추가해주었습니다. 
2. Entity Update시 일부 속성만 제공해도 수정할 수 있도록 하였습니다. (Ex. Project Update시 {title : "title"}만 제공해도 Pass)

## Execution
	## Start
	1. git clone Repository
	
	## API Server
	1. cd ANGELSWING-DEVELOPMENT-TEST/ANGELSWING
	2. sudo docker-compose build
	3. sudo docker-compose run web rails db:create
	4. sudo docker-compose run web rails db:migrate
	5. sudo docker-compose up

	## Unit Test
	1. cd ANGELSWING-DEVELOPMENT-TEST/ANGELSWING
	2. sudo docker-compose run web rspec ./spec/requests

# Postman (볼수 없으시다면 초대드리겠습니다!)
* [Postman Documentation](https://cloudy-comet-98520.postman.co/workspace/My-Workspace~e5f512fc-bd24-413a-89a3-aa73b3a0ae7d/documentation/17630551-a0f46f27-a306-45d7-9312-0d4f0f061bb6)

## References
### Rails Tutorial
* [Rails Getting started](https://rubykr.github.io/rails_guides/getting_started.html)
* [Chapter 10 : Using Rails for API-only Applications](https://kbs4674.tistory.com/168)
* [5주만에 웹 어플리케이션 만들기 (Ruby coin)](https://www.youtube.com/watch?v=iNrT0O2_MQM&list=PLEBQPmkNcLCIE9ERi4k_nUkGgJoBizx6s)
* [한 눈에 읽는 루비 온 레일즈](https://edu.goorm.io/learn/lecture/16335/%ED%95%9C-%EB%88%88%EC%97%90-%EC%9D%BD%EB%8A%94-%EB%A3%A8%EB%B9%84-%EC%98%A8-%EB%A0%88%EC%9D%BC%EC%A6%88/lesson/806307/%EA%B0%95%EC%9D%98%EC%9D%98-%EB%B0%A9%ED%96%A5)

### JWT
* [JWT Aurh tutorial](https://dev.to/alexmercedcoder/ruby-on-rails-api-with-jwt-auth-tutorial-go2)
	
### Database
* [Config Rails Base url](https://jike.in/qa/?qa=604420/)
* [Config Dabase](https://dev-yakuza.posstree.com/ko/ruby-on-rails/database/)
	
### OliveBranch
* [OliveBranch](https://github.com/vigetlabs/olive_branch)
* [Ruby on Rails - File Uploading](https://www.tutorialspoint.com/ruby-on-rails/rails-file-uploading.htm)

### Validation
* [ActiveRecord Validation](https://guides.rubyonrails.org/active_record_validations.html)

### Strong Parameter
* [레일즈 Strong parameters 사용하기](https://chancethecoder.tistory.com/8)
* [Action Controller Parameters](https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require)

### Unit Test
* [Faker Github](https://github.com/faker-ruby/faker)
* [Test Driven Rspec](https://www.youtube.com/watch?v=K6RPMhcRICE&list=PLr442xinba86s9cCWxoIH_xq5UE9Wwo4Z)
* [Project: RSpec Expectations 3.11](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers)
* [Project: RSpec Rails 5.1](https://relishapp.com/rspec/rspec-rails/v/5-1/docs/gettingstarted)
* [RSpec 입문 그 1번 「RSpec의 기본적인 구조나 편리한 기능을 이해하자!」](https://velog.io/@jinsu6688/RSpec-%EC%9E%85%EB%AC%B8-%EA%B7%B8-1%EB%B2%88-%E3%80%8CRSpec%EC%9D%98-%EA%B8%B0%EB%B3%B8%EC%A0%81%EC%9D%B8-%EA%B5%AC%EC%A1%B0%EB%82%98-%ED%8E%B8%EB%A6%AC%ED%95%9C-%EA%B8%B0%EB%8A%A5%EC%9D%84-%EC%9D%B4%ED%95%B4%ED%95%98%EC%9E%90%E3%80%8D)

### Open Source
* [Gitlab](https://github.com/gitlabhq/gitlabhq)
* [discource](https://github.com/discourse/discourse)

### ETC
* [nodemon](https://stackoverflow.com/questions/36193387/restart-rails-server-automatically-after-every-change-in-controllers)
* [Module: Rack::Utils](https://www.rubydoc.info/github/rack/rack/Rack/Utils)

