Rails.application.config.middleware.use OmniAuth::Builder do
  config = YAML.load_file( Rails.root.join('config/github_oauth.yml') )[Rails.env]
  provider :github, config['app_id'], config['app_secret']
end
