FactoryGirl.define do
	factory :project do
		title {Faker::Lorem.sentence}
		description {Faker::Lorem.sentence}
		location {Faker::Nation.nationality}
		type ["in_house", "external", "international"].sample
	end
end
