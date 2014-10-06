Rails.application.config.middleware.use OmniAuth::Builder do
  config = YAML.load_file( Rails.root.join('config/oauth.yml') )[Rails.env]
  provider :github, config['github']['app_id'], config['github']['app_secret']
  provider :weibo,  config['weibo']['app_id'],  config['weibo']['app_secret']
end
