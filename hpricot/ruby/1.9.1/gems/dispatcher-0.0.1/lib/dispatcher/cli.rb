require 'dispatcher'
require 'getoptlong'
require 'uri'

module Dispatcher
  # Command line Dispatcher interface.
  #
  # The CLI interface allows for easy command line debugging of Responders.
  # 
  # Usage: script.rb [URI] [switches]
  class CLIDispatcher < CoreDispatcher
    OPTS = GetoptLong.new(
      ['--help', '-h', GetoptLong::NO_ARGUMENT],
      ['--clean', '-c', GetoptLong::NO_ARGUMENT]
    )
  
    # Sets up the request, and handles the response.
    def listen
      # read the options into a Hash
      options = Hash.new
      OPTS.quiet = true # shut it up
      
      begin
        OPTS.each do |opt, value|
          options[opt] = value
        end
      # catch invalid option exceptions
      rescue GetoptLong::InvalidOption => err
        puts err.to_s + '  (-h will show valid options)'
      end
      
      # help?
      if options.has_key? '--help'
        display_help
      
      # otherwise we're going to handle a request
      else
        # set up our request
        request = Request.new
        
        # and handle it
        if options.has_key? '--clean'
          handle_cleaned(request)
        else
          handle(request)
        end
      end
    end
    
    # Displays a nicely formatted copy of the response
    def handle_cleaned(request)
      response = Response.new(@responder, true)
      response.render(request)
      body = response.body
       
      # strip tags
      body.gsub!(/<\/?[^>]*>/, "")
      
      print body
    end
    
    # Displays the command line help and usage details
    def display_help
      print %{
Usage: #{File.basename($0)} [URI] [options]

  Options:
    -c/--clean   Cleans up any HTML output for easy screen reading
    -h/--help    Help. You're looking at it

  Further Information:
    http://dispatcher.rubyforge.org
}
    end
  end
end