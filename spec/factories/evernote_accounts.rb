# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :evernote_account do
    user nil
    oauth_token "MyString"
  end
end
