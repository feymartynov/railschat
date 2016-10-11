FactoryGirl.define do
  password = 'secret'
  salt = 'zxcvb'

  factory :user do
    sequence(:name) { |n| "user#{n}" }
    password password
    password_confirmation password
    salt salt
    crypted_password Sorcery::CryptoProviders::BCrypt.encrypt(password, salt)
  end
end
