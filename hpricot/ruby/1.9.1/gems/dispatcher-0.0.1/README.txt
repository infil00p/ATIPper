= Dispatcher

The +Dispatcher+ module defines a simple and consistent interface between Ruby and most webserver 
configurations. This library provides a very restrictive set of features, and as such is generally
not meant to be directly used by web-application authors, but instead targets implementors of
frameworks and web-libraries. 

== Basic Usage

The following is a very basic example of relaying a "Hello World" type response back to the 
webserver. Notice that we rely on the +autodetection+ facilities of +Dispatcher+ here, by not
defining or configuring which webserver interface the script is to utilize.

  require 'dispatcher'

  Dispatcher.dispatch do |request|
    header 'Status',       '200 OK'
    header 'Content-Type', 'text/plain'
    
    print 'Hello World'
  end

However, in some instances, we may wish to use a webserver that cannot be necessairly 
+autodetected+, such as a standalone server like +Mongrel+.

  require 'dispatcher/mongrel'

  Dispatcher.dispatch(:port => 8081) do |request|
    header 'Status',       '200 OK'
    header 'Content-Type', 'text/plain'
    
    print 'Hello World'
  end