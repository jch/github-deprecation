# GitHub::Deprecation

Create GitHub issues for `ActiveSupport::Deprecation` messages.

Tired of seeing deprecation messages spam your development and test logs? Take
action and turn that log spam into useful GitHub issues. This gem works by
subscribing to notifications from `ActiveSupport::Deprecation` and posting
them as new issues in your repository.


## Installation

Add this line to your application's Gemfile:

    gem 'github-deprecation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github-deprecation

## Usage

github-deprecation is setup in 3 phases: registration, configuration, and
submission. Registration subscribes to the deprecation messages and queues
them up. Configuration specifies GitHub credentials and repository options.
Finally, submission sends queued and future deprecation messages to GitHub.

To generate an oauth token for configuration:

```
github-deprecation-auth
```

The generated token will have access to your private repositories and can
create issues. You can [revoke the tokens
here](https://github.com/settings/applications).


### Rails 3

With Rails 3, in `config/application.rb`, add the following line right after
requiring boot.rb, and before requiring rails.

```ruby
require File.expand_path('../boot', __FILE__)

require 'github/deprecation'
```

Add an initializer with:

```ruby
GitHub::Deprecation.configure({
  :login       => 'jch',
  :oauth_token => 'oauth2token',
  :repo        => 'org/repo-name',
})
```

To disable github-deprecation in certain environments, call `GitHub::Deprecation.reset!`

### General Ruby

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

Then run:

```
rake test:integration
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## TODO

* better way to test with octokit
* integrate with haystack
* smarter search
* optionally also log the deprecation
* if issue is already closed, add a comment and re-open it?
* calculating an edit-distance probably removes a lot of duplicates
* test: when title is too long, then what? what about sha-ing the title and prefixing that to the title?