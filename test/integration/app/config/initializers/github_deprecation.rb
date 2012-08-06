GitHub::Deprecation.configure({
  :login       => ENV['GH_LOGIN'] || 'user',
  :oauth_token => ENV['GH_OAUTH_TOKEN'] || 'some-token',
  :repo        => ENV['GH_DEPRECATION_TEST_REPO'] || 'user/repo'
})
