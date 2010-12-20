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
	PREFIX spatialrelations: <http://data.ordnancesurvey.co.uk/ontology/spatialrelations/>
	PREFIX postcode: <http://data.ordnancesurvey.co.uk/ontology/postcode/> 
	PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>

	SELECT ?easting ?northing ?long ?lat
	WHERE {
	  ?x skos:notation "#{postcode}"^^postcode:Postcode ;
	     spatialrelations:easting ?easting ;
	     spatialrelations:northing ?northing ;
	     geo:long ?long ;
	     geo:lat ?lat .
	}
endofquery

endpoint = "/stores/ordnance-survey/services/sparql?query=" + CGI::escape(query)

xml_data = Net::HTTP.get 'api.talis.com', endpoint
doc = REXML::Document.new(xml_data)

northing = doc.elements["sparql/results/result/binding[@name = 'northing']/literal"].text
easting = doc.elements["sparql/results/result/binding[@name = 'easting']/literal"].text
longitude = doc.elements["sparql/results/result/binding[@name = 'long']/literal"].text
latitude = doc.elements["sparql/results/result/binding[@name = 'lat']/literal"].text

print "Location of #{postcode}\n"
print "Northing/Easting: #{northing}/#{easting}\n" 
print "Long/Lat: #{longitude}/#{latitude}\n" 

