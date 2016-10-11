FactoryGirl.define do
  factory :message do
    user
    text { "Hello from @#{user.name}!" }
  end
end
