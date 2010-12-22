This little project should demonstrate what I think is a bug in
Nokogiri on jruby. The setup is validating a document against a schema
that includes another schema. The included schema is specified with a
schemaLocation that's a relative file path to the parent schema. This
project was created as a test case of this [issue][https://github.com/tenderlove/nokogiri/issues/issue/389] on [tenderlove/nokogiri][https://github.com/tenderlove/nokogiri].

The xmllint from the libxml2 package can validate the document like
so: 

    $ xmllint --noout --schemas/CCOM-ML.xsd asset.xml
    asset.xml validates

I've written a validate.rb file that shows the steps to validate the
document from nokogiri. The outline is this:

1. Instantiate a Nokogiri::XML::Schema object
2. Instantiate a Nokogiri::XML document object
3. Call the schema's validate passing in the document

These steps behave differently based on using MRI 1.9.2 and JRuby
1.5.6.

Using MRI, the schema object fails to instantiate because nokogiri
doesn't know about the cct:IDType. If you chdir into the schemas
directory and instantiate the schema object it loads just fine. When
you try to validate the document, it doesn't matter what directory
you're in. The schema has already been loaded and fully "initialized".

    $ rvm --create use 1.9.2@nokogiri-bug
    Using /Users/dalcorn/.rvm/gems/ruby-1.9.2-p0 with gemset
    nokogiri-bug
    $ gem install nokogiri --pre
    Building native extensions.  This could take a while...
    Successfully installed nokogiri-1.5.0.beta.3
    1 gem installed
    $ ruby -rubygems validate.rb
    instantiating the schema without chdir... element decl. '{http://www.example.com/CCOM-ML}SerialNumber', attribute 'type': The QName value '{urn:un:unece:uncefact:documentation:standard:CoreComponentType:2}IDType' does not resolve to a(n) type definition.
    instantiating the schema with chdir... done.
    trying to validate without chdir... done.
    trying to validate with Dir.chdir... done.

JRuby, on the other hand, doesn't care what directory you're in when
you instantiate the schema. It doesn't seem to really initialize the
schema object. At document validation time, it will complain about the
undefined cct:IDType.

    $ rvm --create use jruby@nokogiri-bug
    Using /Users/dalcorn/.rvm/rubies/jruby-1.5.6 with gemset
    nokogiri-bug
    $ gem install nokogiri --pre
    Successfully installed nokogiri-1.5.0.beta.3-java
    1 gem installed
    $ ruby -rubygems validate.rb
    instantiating the schema without chdir... done.
    trying to validate without chdir... Could not parse document: src-resolve: Cannot resolve the name 'cct:IDType' to a(n) 'type definition' component. done.
    trying to validate with Dir.chdir... Could not parse document: src-resolve: Cannot resolve the name 'cct:IDType' to a(n) 'type definition' component. done.
        

The bug is that nokogiri-java doesn't care what directory you're in
when you do the validate. Even if you chdir into the schemas, nokogiri
still can't import the cct.xsd.

I don't really understand it. However, I suspect it's got something to
do with the Java code that executes in the Thread context that may not
know about jruby's Dir.chdir.
