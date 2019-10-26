# frozen_string_literal: true

module API
  class GithubClient
    class << self
      def app_client
        payload = {
          iat: Time.now.to_i,
          exp: Time.now.to_i + 10.minutes,
          iss: ENV['GITHUB_APP_IDENTIFIER']
        }
        jwt = JWT.encode(payload, github_app_private_key, 'RS256')

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

      private

      def github_app_private_key
        @github_app_private_key ||= OpenSSL::PKey::RSA.new(ENV['GITHUB_PRIVATE_KEY'])
      end
    end
  end
end
