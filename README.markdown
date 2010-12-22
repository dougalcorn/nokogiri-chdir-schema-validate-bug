This little project should demonstrate what I think is a bug in
Nokogiri on jruby. The setup is validating a document against a schema
that includes another schema. The included schema is specified with a
schemaLocation that's a relative file path to the parent schema. The
xmllint tool that can validate a document handles this
fine. Unfortunately, nokogiri won't properly import the schema and the
resulting document is invalid. In fact, nokogiri throws an exception
at validation time saying the schema is invalid.

Here's how to show xmllint knows it's a vaild set of documents:

    $ xmllint --noout --schemas/CCOM-ML.xsd asset.xml
    asset.xml validates

