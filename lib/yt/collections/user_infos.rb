require 'yt/collections/base'
require 'yt/models/user_info'

module Yt
  module Collections
    class UserInfos < Base

      def initialize(options = {})
        @account = options[:account]
        @auth = options[:auth]
      end

      def self.by_account(account)
        new account: account, auth: account.auth
      end

    private

      def new_item(data)
        Yt::UserInfo.new data: data
      end

      def list_params
        super.tap do |params|
          params[:path] = '/oauth2/v2/userinfo'
          # TODO: Remove youtube from here, implement incremental scopes
          params[:scope] = 'https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
        end
      end

      def next_page
        request = Request.new list_params
        response = request.run
        raise unless response.is_a? Net::HTTPOK
        @page_token = nil
        
        Array.wrap response.body
      end
    end
  end
end