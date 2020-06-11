require 'bundler'
require 'date'
require 'require_all'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil
require_all 'app/models'
require_relative '../bin/api-reader.rb'
require_relative '../bin/currency_methods.rb'
