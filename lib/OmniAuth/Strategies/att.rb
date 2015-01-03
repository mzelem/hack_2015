require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Att < OmniAuth::Strategies::OAuth2
      include OmniAuth::Strategy

      DEFAULT_SCOPE = 'full'

      ATT_OAUTH_URL = 'https://api.att.com/oauth/v4/authorize'
      MY_URL = 'localhost:3000'

      option :client_options, {
          :site => ATT_OAUTH_URL,
          :authorize_url => '/oauth/v4/authorize?',
          :token_url => '/oauth/v4/token'
      }

      option :access_token_options, {
          :header_format => 'OAuth %s',
          :param_name => 'access_token'
      }

      option :token_params, {
          :response_type => 'code'
      }

      option :authorize_options, [:scope, :display]

      uid { raw_info['uid'] }

      def callback_url
        protocal = 'https'
        protocal = 'http' if Rails.env == "development"
        "#{protocal}://#{MY_URL}/auth/att/callback"
      end

      def raw_info
        @raw_info ||= build_provider_hash
      end

      def build_provider_hash
        # hash = access_token.get("#{ATT_OAUTH_URL}/user-directory-api/users/currentUser").parsed
        # hash.merge!(access_token.get("#{ATT_OAUTH_URL}/user-directory-api/users/currentUser/biography").parsed)

        hash = {}
        map_provider_hash(hash)
      end

      def map_provider_hash(provider_hash)
        return {}
        result = {}
        provider_hash.each_key do |key|
          result[key.underscore] = provider_hash[key] unless key == 'id'
        end
        dob = provider_hash['birthday'] || provider_hash['dateOfBirth']
        if dob.present?
          dob = dob.split(/\/|-/)
          result['date_of_birth'] = Date.new(*dob.map(&:to_i))
        end
        if result["phones"].present?
          result.delete("phones").each do |h|
            result["mobile_phone"] = h["number"] if h["phoneType"] == "Mobile"
            result["home_phone"] = h["number"] if h["phoneType"] == "Home"
          end

        end
        result['uid'] = provider_hash['id']
        result
      end

      # normalize user's data according to http://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      def auth_hash
        OmniAuth::Utils.deep_merge(super(), {
            'uid' => uid,
            'user_info' => {
                'name' => @username,
                'nickname' => @username,
                'image' => @avatar
            },
            'extra' => { 'raw_info' => raw_info }
        })
      end

      #def callback_phase
      #
      #  super
      #end

      protected

      def build_access_token
        auth_params = {:redirect_uri => callback_url}

        verifier = request.params['code']
        client.auth_code.get_token(verifier, auth_params.merge(options.token_params.to_hash(:symbolize_keys => true)))
      end
    end
  end
end
