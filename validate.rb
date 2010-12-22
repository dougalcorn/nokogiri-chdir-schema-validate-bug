require 'nokogiri'

PO_SCHEMA_FILE= File.join(File.dirname(__FILE__), "schemas", "CCOM-ML.xsd")
PO_XML_FILE="asset.xml"

STDOUT.write "instantiating the schema without chdir... "
begin
  xsd = Nokogiri::XML::Schema(File.read(PO_SCHEMA_FILE))
rescue Exception => e
  puts e.message
  STDOUT.write "instantiating the schema with chdir... "
  xsd = Dir.chdir(File.dirname(PO_SCHEMA_FILE)) do |path|
    Nokogiri::XML::Schema(File.read(File.basename(PO_SCHEMA_FILE)))
  end
end
puts "done."

doc = Nokogiri::XML(File.read(PO_XML_FILE))

def validate_with_rescue(xsd,doc)
  xsd.validate(doc).each do |error|
    puts error.message
  end
rescue Exception => e
  puts e.message
end

STDOUT.write "trying to validate without chdir... "
validate_with_rescue(xsd, doc)
puts "done."

STDOUT.write "trying to validate with Dir.chdir... "
Dir.chdir(File.dirname(PO_SCHEMA_FILE)) do |path|
  STDOUT.write " (#{Dir.pwd}) "
  validate_with_rescue(xsd, doc)
end
puts "done."

STDOUT.write "trying to validate with Dir.chdir and no block ... "
Dir.chdir(File.dirname(PO_SCHEMA_FILE))
STDOUT.write " (#{Dir.pwd}) "
validate_with_rescue(xsd, doc)
puts "done."
