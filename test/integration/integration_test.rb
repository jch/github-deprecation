require 'test_helper'

# Access token requires 'repo,delete_repo' scope
class IntegrationTest < Test::Unit::TestCase
  if ENV['GH_LOGIN'] && ENV['GH_OAUTH_TOKEN']
    def setup
      @test_repo = "github-deprecation_test_#{Time.now.to_i + rand(1000)}"
      @user_repo = [ENV['GH_LOGIN'], @test_repo].join('/')

      GitHub::Deprecation.reset!(true)
      GitHub::Deprecation.configure({
        :login       => ENV['GH_LOGIN'],
        :oauth_token => ENV['GH_OAUTH_TOKEN'],
        :repo        => @user_repo
      })
      GitHub::Deprecation.register!
      GitHub::Deprecation.start_reporting!
    end

    def with_repo(&blk)
      client.create_repository(@test_repo)
      blk.call @user_repo
    ensure
      client.delete_repository(@user_repo)
    end

    def client
      @client ||= Octokit::Client.new({
        :login       => ENV['GH_LOGIN'],
        :oauth_token => ENV['GH_OAUTH_TOKEN'],
      })
    end

    def test_create
      with_repo do |repo|
        ActiveSupport::Deprecation.warn "Roh oh #{Time.now.to_i}"
        issues = client.list_issues(repo)
        assert_equal 1, issues.size
      end
    end

    def test_update
      with_repo do |repo|
        num = Time.now.to_i
        ActiveSupport::Deprecation.warn "Roh oh #{num}"
        ActiveSupport::Deprecation.warn "Roh oh #{num}"
        issues = client.list_issues(repo)
        assert_equal 1, issues.size
      end
    end
  end
end