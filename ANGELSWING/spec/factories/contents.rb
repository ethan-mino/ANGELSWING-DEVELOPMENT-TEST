FactoryGirl.define do
  factory :content do
   		title {Faker::Lorem.sentence}
	  	body {Faker::Lorem.sentence}
  end
end
