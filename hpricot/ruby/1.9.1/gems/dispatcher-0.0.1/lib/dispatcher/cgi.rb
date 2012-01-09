require 'dispatcher'


module Dispatcher
  # CGI Dispatcher
  #
  # Manages dispatching to CGI interfaces.
  class CGIDispatcher < CoreDispatcher
    # Immediately processes the request for the values given in ENV.
    def listen
      # set up our request
      request = generate_request
      
      # and handle it
      handle(request)
    end
    
    # Generates a reques object from the current values of ENV
    def generate_request
      request = Request.new
      
      # Copy information out of the environment
      ENV.each do |key, value|
        request.env[key] = value
        
        if key[0,5].upcase == 'HTTP_'
          request.headers[key[5, key.length - 5]] = value
        end
      end
      
      # Set up the CGI value Hash
      request.values = build_cgi_environment(request.env)
      
      return request
    end
    
    #:nodoc:
    # List of environment values used in the CGI environment.
    # We use Hash keys to avoid O(n^2) type behavior.
    CGI_VARS = {
      'AUTH_TYPE' => true,
      'CONTENT_LENGTH' => true,
      'CONTENT_TYPE' => true,
      'GATEWAY_INTERFACE' => true,
      'HTTPS' => true, # non-spec
      'PATH_INFO' => true,
      'PATH_TRANSLATED' => true,
      'QUERY_STRING' => true,
      'REMOTE_ADDR' => true,
      'REMOTE_HOST' => true,
      'REMOTE_IDENT' => true,
      'REMOTE_USER' => true,
      'REQUEST_METHOD' => true,
      'SCRIPT_NAME' => true,
      'SERVER_NAME' => true,
      'SERVER_PORT' => true,
      'SERVER_PROTOCOL' => true,
      'SERVER_SOFTWARE' => true,
    }
    
    # Generates a hash of a CGI environment from values in the given hash.
    def build_cgi_environment(env)
      cgi_env = Hash.new
      
      env.each do |key, value|
        if key[0,5].upcase == 'HTTP_' or CGI_VARS[key.upcase]
          cgi_env[key] = value
        end
      end
      
      return cgi_env
    end
  end
end