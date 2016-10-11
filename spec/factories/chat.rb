FactoryGirl.define do
  factory :chat do
    sequence(:name) { |n| "chat#{n}" }
    association :creator, factory: :user

    trait :with_messages do
      after(:create) do |chat, _|
        messages = create_list(:message, 2, chat: chat)
        messages.each { |m| create(:chat_user, user: m.user, chat: chat) }
      end
    end
  end
end
