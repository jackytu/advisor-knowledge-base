require 'active_record'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load File.join(File.dirname(__FILE__), '../../', 'db/schema.rb')

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
