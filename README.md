# GithubDeprecations

Create GitHub issues for ActiveSupport::Deprecation messages.

## Installation

Add this line to your application's Gemfile:

    gem 'github_deprecations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github_deprecations

## Usage

To catch as many deprecations as possible, require this as early as possible.

```ruby
require 'github_deprecations'

GithubDeprecations.configure({
  :login       => 'jch',
  :oauth_token => 'oauth2token',
  :repo        => 'org/repo-name',

  :subscribe   => %r{^deprecation},  # optional: string or regex of deprecation types
  :labels      => ['deprecations']   # optional: labels to apply to created issues
}).register!
```

## Development

To run integration tests, you need to specify two environment variables:

* `GH_LOGIN` - your github login
* `GH_OAUTH_TOKEN` - oauth access token with 'repo,delete_repo' scopes

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## TODO

* better way to test with octokit
* pluggable background job backends. Would be nice to use Rails Queue API
* bin/github-access-token prompts for user/pass and returns an access token
* integrate with haystack
* smarter search
* optionally also log the deprecation
* error handling
* if issue is already closed, add a comment and re-open it?