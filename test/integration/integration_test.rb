require 'test_helper'

# Access token requires 'repo,delete_repo' scope
module GitHub::Deprecation
  class IntegrationTest < Test::Unit::TestCase
    if ENV['GH_LOGIN'] && ENV['GH_OAUTH_TOKEN']
      include IntegrationHelper

      def setup
        @test_repo = "github-deprecation_test_#{Time.now.to_i + rand(1000)}"
        @user_repo = [ENV['GH_LOGIN'], @test_repo].join('/')
        client.create_repository(@test_repo)

        GitHub::Deprecation.reset!(true)
        GitHub::Deprecation.configure({
          :login       => ENV['GH_LOGIN'],
          :oauth_token => ENV['GH_OAUTH_TOKEN'],
          :repo        => @user_repo
        })
        GitHub::Deprecation.register!
        GitHub::Deprecation.start_reporting!
      end

      def teardown
        client.delete_repository(@user_repo)
      end

      def client
        @client ||= Octokit::Client.new({
          :login       => ENV['GH_LOGIN'],
          :oauth_token => ENV['GH_OAUTH_TOKEN'],
        })
      end

      def test_create
        ActiveSupport::Deprecation.warn "Roh oh #{Time.now.to_i}"
        issues = client.list_issues(@user_repo)
        assert_equal 1, issues.size
      end

      def test_update
        num = Time.now.to_i
        ActiveSupport::Deprecation.warn "Roh oh #{num}"
        ActiveSupport::Deprecation.warn "Roh oh #{num}"
        issues = client.list_issues(@user_repo)
        assert_equal 1, issues.size
      end
    end
  end
end