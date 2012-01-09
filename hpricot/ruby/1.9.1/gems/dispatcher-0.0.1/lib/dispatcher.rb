module Dispatcher
  CR   = 13.chr
  LF   = 10.chr
  CRLF = CR + LF

  # Dispatches the specified responder block, given the passed parameters. 
  # 
  # If a subclass of Dispatcher is passed, it will be used as the dispatcher interface. Otherwise,
  # the last-defined interface will be used. Failing that, the functian will appempt to autodetect
  # an appropriate interface.
  #
  # Additionally, any number of named parameters (:param => value) may be passed, and will be
  # considered configuration values for the given dispatcher interface.
  def self::dispatch(*params, &responder)
    dispatcher = self.default_dispatcher
    config     = Hash.new
    
    params.each do |param|
      dispatcher = param if param.kind_of? CoreDispatcher
      config     = param if param.kind_of? Hash
    end
    
    # Autodetect if don't have a valid dispatcher
    dispatcher = self.autodetect if not dispatcher
    
    # create our Dispatcher, and start listening for requests
    dispatcher = dispatcher.new(responder, config)
    dispatcher.listen
  end
  
  # Attempts to autodetects an appropriate dispatcher interface depending on the current
  # configuration. If an appropriate interface is found, it will be loaded, and the appropriate
  # Dispatcher subclass will be returned. (CoreDispatcher by default)
  def self.autodetect
    # Check for CGI
    if ENV.has_key? 'GATEWAY_INTERFACE' and ENV['GATEWAY_INTERFACE'][0,4].upcase == 'CGI/'
      require 'dispatcher/cgi'
      return CGIDispatcher
    
    # Check for CLI
    elsif ENV.has_key? 'PROMPT'
      require 'dispatcher/cli'
      return CLIDispatcher
      
    # By default, we turn to the CoreDispatcher
    else
      return CoreDispatcher
    end
  end
  
  # A core Dispatcher interface.
  # 
  # This is intended as a 'virtual' class that all other dispatcher interfaces inherit from.
  class CoreDispatcher
    # Creates a new 
    def initialize(responder, *config)
      @responder = responder
      @config    = config
    end
    
    # Start listening for incoming requests.
    def listen
      err  = 'You are attempting to use the default Dispatcher interface. '
      err += 'Most likely the library was unable to autodetect an appropriate interface. '
      err += 'Try specifying one manually via a require \'request/<interface>\'.'
      
      raise TypeError, err, caller
    end
    
    # Super-simple handler.
    #
    # Just outputs any STDOUT content. Buffering should be done at the Responder level.
    def handle(request)
      response = Response.new(@responder)
      response.render(request)
    end
    
    # Set the default_dispatcher to the last class that inherits CoreDispatcher.
    def self.inherited(subclass)
      Dispatcher.default_dispatcher = subclass
    end
  end
  
  # A HTTP request.
  class Request
    # Any HTTP headers passed along with the request
    attr_accessor :headers
    
    # The body of the request, if given.
    attr_accessor :body
    
    # A full set of CGI environment values
    attr_accessor :values
    
    # Every environment variable passed from the server
    attr_accessor :env
    
    # Generates a new request.
    #
    # Any values passed will be set to the appropriate attributes.
    def initialize(*vals)
      @headers = HTTPHeaderHash.new
      @env     = Hash.new
      @values  = Hash.new
      
      vals.each do |key, value|
        instance_variable_set(key, value)
      end
    end
    
    # The current request method.
    def method
      @values['REQUEST_METHOD']
    end
    
    # The requested path
    def path
      @values['PATH_INFO']
    end
    
    # The fully qualified URI of the request
    def uri
      # protocol
      result = 'http'
      if @values['HTTPS'] == 'on'
        result += 's'
      end
      
      # server/port
      result += "://#{@values['HTTP_HOST']}"
      
      # path
      result += @values['PATH_INFO']
      
      # query
      if @values['QUERY_STRING'] != ''
        result += "?#{@values['QUERY_STRING']}"
      end
      
      return result
    end
    alias_method :url, :uri
  end
  
  # A response object embodies a single HTTP response to the Dispatcher.
  class Response
    attr_reader :body, :headers
    attr_accessor :body_start
    
    # Defines a new response
    #
    # The responder is a Proc object, that when run, output the HTTP response, via $stdout and any
    # helper functions defined in this class, such as header().
    #
    # If buffered is true, the responder method will be completely processed before any output is
    # rendered or returned.
    def initialize(responder, buffered = false)
      @headers = HTTPHeaderHash.new
      @body    = ''
      
      @body_start = false
      @buffered   = buffered
      
      (class <<self; self; end).send(:define_method, :responder, responder)
    end
    
    # Sets a header for the response.
    #
    # If the response is currently unbuffered, the header will be rendered once $stdout is written
    # to, otherwise it will be rendered at the end of buffering (or the end of the responder).
    #
    # Please note that if a header is sent after content is already rendered, an IOError will be
    # thrown.
    def header(field, value)
      if @body_start
        raise IOError, 'Attempt to output headers after the response body has started.', caller
      end
      
      @headers[field] = value
    end
    
    # Buffers a block's output to $stdout.
    #
    # The method will return the buffered output if passback is true.
    def buffer(passback = false)
      old_out = $stdout
      $stdout = $stdout.clone
      class <<$stdout
        attr_accessor :buffer
        
        def write(value)
          @buffer << value
        end
      end
      $stdout.buffer = ''
      
      yield
      
      result = $stdout.buffer
      $stdout = old_out
      
      if passback
        return result
        
      else
        # if this is the first render of the body, we need to print out any headers
        if not @body_start
          @body_start = true
          
          @headers.each do |field, value|
            print field + ': ' + value + CRLF
          end
          print CRLF
        end
        
        print result
      end
    end
    
    # Renders the request
    # 
    # If the response was designated as a buffered response at creation, the headers and body may
    # be retrieved from the object (no output will be rendered by this method).
    #
    # If the response is not buffered, the body and header attributes must be ignored.
    def render(request)
      if @buffered
        @body = buffer(true) do
          responder(request)
        end
      else
        # intercept the first chunk of output so we can detect header usage
        old_out = $stdout
        $stdout = $stdout.clone
        class <<$stdout
          attr_accessor :response
          
          def write(val)
            if not @ignore and not @response.body_start
              @response.body_start = true
              
              @response.headers.each do |field, value|
                print field + ': ' + value + CRLF
              end
              
              print CRLF
            end
            
            super(val)
          end
        end
        $stdout.response = self
        
        responder(request)
        print ''
        
        $stdout = old_out
      end
    end
  end
  
  # Defines a Hash of HTTP headers.
  #
  # Keys are case-insensitive, and converted to 'pretty' keys
  # e.g. 'CoNtEnT-TYPE' would be 'Content-Type'
  #
  # This class <b>does not</b> parse for valid HTTP header fields, so you may recieve
  # errors from your webserver if a malformed header is passed.
  class HTTPHeaderHash < Hash
    def initialize(*values)
      values.each do |field, value|
        self[field] = value
      end
    end
    
    # Converts the given key string into a 'pretty' HTTP header field
    def self.pretty_field(field)
      chunks = field.gsub('_', '-').split('-')
      
      chunks.collect! do |val| 
        val.capitalize
      end
      
      return chunks.join('-')
    end
    
    # Sets the key to value.
    def []=(field, value)
      super(HTTPHeaderHash.pretty_field(field.to_s), value.to_s)
    end
    
    # Returns the value stored for key.
    def [](field)
      super(HTTPHeaderHash.pretty_field(field.to_s))
    end
  end
  
  # Typically, this returns the last-defined subclass of CoreDispatcher.
  def self.default_dispatcher
    @default_dispatcher
  end
  # This is automatically set when a class inherits from CoreDispatcher.
  def self.default_dispatcher=(dispatcher)
    @default_dispatcher = dispatcher
  end
end