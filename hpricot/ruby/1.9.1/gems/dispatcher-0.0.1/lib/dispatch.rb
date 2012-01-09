require 'dispatcher/cgi'

Dispatcher.dispatch do |request|
  header 'Status', '200 NOT OK'
  header 'Content-Type', 'text/plain'
  
  print "#{request.uri}\n\n"
  
  print request.inspect.gsub(' @', "\n@").gsub('={', "={\n  ").gsub('",', "\",\n ").gsub('"}', "\"\n}")
=begin
  print %{<?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >
    <head>
      <title>Roar</title>
    </head>
    <body>}
  print "<h2>#{Dispatcher.autodetect}</h2>"
  print "<h3>Working Directory</h3>\n"
  print Dir.getwd
  print "<h3>Environment Variables</h3>\n"
  print "<table style=\"font-size: 0.75em;\"><tbody>\n"
  ENV.each do |key, value|
    print "<tr><td style=\"text-align:right;\"><b>#{key}</b>:</td><td>#{value}</td></tr>\n"
  end
  print "</tbody></table>\n"
  print %{  </body>
  </html>}
=end
end