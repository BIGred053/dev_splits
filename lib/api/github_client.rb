# frozen_string_literal: true

module API
  class GitHubClient
    # Instantiate an Octokit client authenticated as a GitHub App.
    # GitHub App authentication requires that you construct a
    # JWT (https://jwt.io/introduction/) signed with the app's private key,
    # so GitHub can be sure that it came from the app an not altererd by
    # a malicious third party.
    def app_client
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + 10.minutes,
        iss: ENV['GITHUB_APP_IDENTIFIER']
      }
      jwt = JWT.encode(payload, PRIVATE_KEY, 'RS256')

      @app_client ||= Octokit::Client.new(bearer_token: jwt)
    end

    # Instantiate an Octokit client, authenticated as an installation of a
    # GitHub App, to run API operations.
    def installation_client(payload)
      @installation_id = payload['installation']['id']
      @installation_token =
        @app_client.create_app_installation_access_token(@installation_id)[:token]
      @installation_client = Octokit::Client.new(bearer_token: @installation_token)
    end
  end
end
