# GitHub::Deprecation

Create GitHub issues for `ActiveSupport::Deprecation` messages.

## Installation

Add this line to your application's Gemfile:

    gem 'github-deprecation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github-deprecation

## Usage

With Rails 3, add an initializer with:

```ruby
GitHub::Deprecation.configure({
  :login       => 'jch',
  :oauth_token => 'oauth2token',
  :repo        => 'org/repo-name',
})
```

To generate an oauth token:

```
gh-oauth-token
```

To use with any general Ruby project:

```ruby
require 'github-deprecation'
Github::Deprecation.register!  # require this as early as possible

GitHub::Deprecation.configure({
  :login       => 'jch',
  :oauth_token => 'oauth2token',
  :repo        => 'org/repo-name'
})

GitHub::Deprecation.start_reporting!
```

If you're using Resque, this gem will submit issues in the background.

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

* lazy load requires
* rename to github-deprecation. Note singular spelling to match with ActiveSupport::Deprecation
* better way to test with octokit
* pluggable background job backends. Would be nice to use Rails Queue API
* bin/github-access-token prompts for user/pass and returns an access token
* integrate with haystack
* smarter search
* optionally also log the deprecation
* error handling
* if issue is already closed, add a comment and re-open it?

* if we wanted to be fancy
* calculating an edit-distance probably removes a lot of duplicates
* test: when title is too long, then what? what about sha-ing the title and prefixing that to the title?
