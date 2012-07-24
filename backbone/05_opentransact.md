!SLIDE
## Consider #2 first, then #1

!SLIDE
#2. Use a Token#

	POST /transactions/usd
	Host: FSP.com
	Authorization: Bearer abc123

	to=bill@recipient.com&
	amount=10&
	note=consulting

!SLIDE smaller
# [config/application.rb](https://github.com/nov/rack-oauth2-sample/blob/master/config/application.rb#L42) #

	@@@ ruby

	require 'rack/oauth2'
	config.middleware.use Rack::OAuth2::Server
                   ::Resource::Bearer, '' do |req|
	  AccessToken.valid.find_by_token(req.access_token) 
                   || req.invalid_token!
	end

!SLIDE smaller
# [application_controller.rb](https://github.com/nov/rack-oauth2-sample/blob/master/lib/authentication.rb#L40) #
	
    @@@ ruby

    def require_oauth_token
      @current_token = AccessToken.find_by_token(
        request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN])
      raise Rack::OAuth2::Server::Resource::Bearer
              ::Unauthorized unless @current_token
    end

    def require_oauth_user_token
      require_oauth_token
      raise Rack::OAuth2::Server::Resource::Bearer
        ::Unauthorized.new(:invalid_token, 'User token is required') 
        unless @current_token.account
      authenticate @current_token.account
    end

!SLIDE
#1. Get a Token#

!SLIDE smaller
# [authorizations_controller.rb](https://github.com/nov/rack-oauth2-sample/blob/master/app/controllers/authorizations_controller.rb#L30) #
	
    @@@ ruby

    Rack::OAuth2::Server::Authorize.new do |req, res|
      @client = Client.find_by_identifier(req.client_id) || req.bad_request!
      res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uri)
      if allow_approval
        if params[:approve]
          case req.response_type
          when :code
            authorization_code = current_account.authorization_codes.create(:client_id => @client, :redirect_uri => res.redirect_uri)
            res.code = authorization_code.token
          when :token
            res.access_token = current_account.access_tokens.create(:client_id => @client).to_bearer_token
          end
          res.approve!
        else
          req.access_denied!
        end
      else
        @response_type = req.response_type
      end
    end
