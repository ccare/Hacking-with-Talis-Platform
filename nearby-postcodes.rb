#!/usr/bin/ruby

require 'net/http'
require 'rexml/document'
require "cgi"

postcode = 'CV4 7AL'

if ARGV.length > 1
  $stderr.puts "Please supply one argument (the postcode you're interested in)"
  exit 1 
elsif ARGV.length == 1
  postcode = ARGV[0]
else 
  puts 'You did not supply a postcode. Using University of Warwick as default location'
end

query = <<endofquery
	PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
	PREFIX postcode: <http://data.ordnancesurvey.co.uk/ontology/postcode/> 
	PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>

	SELECT ?pcode ?long ?lat ?y
	WHERE {
	  ?x skos:notation "#{postcode}"^^postcode:Postcode ;
	     geo:long ?long ;
	     geo:lat ?lat .
	  ?y geo:lat ?lat1;
	     geo:long ?long1;
	     skos:notation ?pcode .
	  FILTER ( ?lat1 > ?lat && ?lat1 < ?lat + 0.01 && ?long1 > ?long && ?long1 < ?long + 0.01) .
	}
	LIMIT 10 
endofquery

endpoint = "/stores/ordnance-survey/services/sparql?query=" + CGI::escape(query)

xml_data = Net::HTTP.get 'api.talis.com', endpoint

doc = REXML::Document.new(xml_data)


longitude = doc.elements.each("sparql/results/result/") {
    |elem| 
	pcode = elem.elements["binding[@name = 'pcode']/literal"].text
	lat = elem.elements["binding[@name = 'lat']/literal"].text
	long = elem.elements["binding[@name = 'long']/literal"].text
	print "#{pcode} is at lat: #{lat}, long: #{long}\n"
}

