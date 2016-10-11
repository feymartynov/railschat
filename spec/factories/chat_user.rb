FactoryGirl.define do
  factory :chat_user do
    chat
    user
    online false
  end
end
