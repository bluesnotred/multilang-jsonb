# Multilang-jsonb

> Multilang is a small translation library for translating database values for Active Support/Rails using the [jsonb datatype](https://www.postgresql.org/docs/15/functions-json.html).

This project is a fork of [bithavoc/multilang-hstore](https://github.com/bithavoc/multilang-hstore), which was a fork of[artworklv/multilang](https://github.com/artworklv/multilang) with some differences:

* Replaced YAML text fields and Hstore fields in favor of JSONB fields. (Convert your hstore fields to jsonb)
* Support for Rails 7.

## Installation

### Rails 7

You need configure the multilang gem inside your gemfile:

    gem 'multilang-jsonb', '~> 1.0.0'

Do not forget to run:

	bundle install

## Basic Usage

This is a walkthrough with all steps you need to setup multilang translated attributes, including model and migration.

We're assuming here you want a Post model with some multilang attributes, as outlined below:

    class Post < ActiveRecord::Base
      multilang :title
    end

or

    class Post < ActiveRecord::Base
      multilang :title, :description, :required => true, :length => 100
    end

The multilang translations are stored in the same model attributes (eg. title):

You may need to create migration for Post as usual, but multilang attributes should be in jsonb type:
  
    create_table(:posts) do |t|
      t.jsonb :title
      t.timestamps
    end

Thats it!

Now you are able to translate values for the attributes :title and :description per locale:

    I18n.locale = :en
    post.title = 'Multilang rocks!'
    I18n.locale = :lv
    post.title = 'Multilang rulle!'

    I18n.locale = :en
    post.title #=> Multilang rocks!
    I18n.locale = :lv
    post.title #=> Multilang rulle!


You may assign attributes through auto generated methods (this methods depend from I18n.available_locales):

    I18n.available_locales #=> [:en. :lv]

    post.title_en = 'Multilang rocks!'
    post.title_lv = 'Multilang rulle!'

    post.title_en #=>  'Multilang rocks!'
    post.title_lv #=>  'Multilang rulle!'

You may use initialization if needed:

    Post.new(:title => {:en => 'Multilang rocks!', :lv => 'Multilang rulle!'})

or

    Post.new(:title_en => 'Multilang rocks!', :title_lv => 'Multilang rulle!')

Also, you may ise same hashes with setters:

    post.title = {:en => 'Multilang rocks!', :lv => 'Multilang rulle!'} 

## Attribute methods

You may get other translations via attribute translation method:

    post.title.translation[:lv] #=> 'Multilang rocks!'
    post.title.translation[:en] #=> 'Multilang rulle!'
    post.title.translation.locales #=> [:en, :lv]

If you have incomplete translations, you can get translation from other locale:

    post.title = {:en => 'Multilang rocks!', :lv => ''}
    I18n.locale = :lv
    post.title.any #=> 'Multilang rocks!'

The value from "any" method returns value for I18n.current_locale or, if value is empty, return value for I18n.default_locale, if it's empty too it searches through all locales. It takes searching order from I18n.available_locales array. If you don't need ANY value, you can also use current_or_default method like `post.title.current_or_default` (it searches value for current and default locales only).

## Validations

Multilang has some validation features:

    multilang :title, :length => 100  #define maximal length validator
    multilang :title, :required => true #define requirement validator for all available_locales
    multilang :title, :required => 1 #define requirement validator for 1 locale
    multilang :title, :required => [:en, :es] #define requirement validator for specific locales
    multilang :title, :format => /regexp/ #define validates_format_of validator

## Migrating form multilang-hstore to multilang-jsonb

If you want to switch from [bithavoc/multilang-hstore](https://github.com/bithavoc/multilang-hstore to multilang-jsonb, you can use the following ActiveRecord migration as an example to convert your existing hstore fields to jsonb:

    class ConvertMultipleFieldsToJSONB < ActiveRecord::Migration[7.0]
      def up
        migrate_to_jsonb("articles", "productname", false)
        migrate_to_jsonb("articles", "description")
        migrate_to_jsonb("categories", "name", false)
      end
    
      def migrate_to_jsonb(table_name, fieldname, null_values_allowed = true)
        rename_column table_name, fieldname, "#{fieldname}_hstore"
        add_column    table_name, fieldname, :jsonb, default: {}, null: null_values_allowed, index: { using: 'gin' }
        execute       "UPDATE #{table_name} SET #{fieldname} = json_object(hstore_to_matrix(#{fieldname}_hstore))::jsonb"
        remove_column table_name, "#{fieldname}_hstore"
      end
    end

## Tests

Test runs using a temporary database in your local PostgreSQL server:

Create a test database:

    $ createdb multilang-jsonb-test

Create the role *postgres* if necessary:

    $ createuser -s -r postgres 

Finally, you can run your tests:
  
    rspec	


## Bugs and Feedback

Use [http://github.com/bluesnotred/multilang-jsonb/issues](http://github.com/bluesnotred/multilang-jsonb/issues)

## License(MIT)

* Copyright (c) 2017 - 2023 Bluesnotred and Contributors
* Copyright (c) 2012 - 2014 Bithavoc and Contributors - http://bithavoc.io
* Copyright (c) 2010 Arthur Meinart
