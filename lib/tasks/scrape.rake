require 'rubygems'
require 'nokogiri'
require 'open-uri'

namespace 'setup' do
  
  task :scrape => :environment do 
    doc = Nokogiri.HTML(open('http://www.tbs-sct.gc.ca/atip-aiprp/apps/coords/index-eng.asp'), nil, 'ISO-8859-1')
    paras = doc.css('.center').css('p')
    paras.each do |p|
      name = p.css('strong')
      if(name.length > 0)
        a = Agency.new
        a.name = p.css('strong').text
        a.email = p.css('a').text
        # Thank you Govt. of Canada for making this a PAIN IN THE ASS TO SCRAPE
        #a.address_text = p.text.split('</strong>')[1].split("<a")[0]
        a.save
      end
    end  
  end

end
