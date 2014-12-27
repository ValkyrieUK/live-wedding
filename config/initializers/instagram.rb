INSTA_TAG = 'eastiseastcoat'

Instagram.configure do |config|
  config.client_id = ENV['INSTA_CLIENT']
  config.access_token = ENV['INSTA_TOKEN']
end
