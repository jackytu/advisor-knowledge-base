require 'active_record'
require 'sqlite3'
require 'uri'
require 'base'

# Advisor Knowledge Base
module Akb

  db_uri = URI.parse(Akb.global_settings['subscribe']['database'])
  ActiveRecord::Base.establish_connection(
    adapter:       db_uri.scheme,
    host:          db_uri.host,
    port:          db_uri.port,
    username:      db_uri.user,
    password:      db_uri.password,
    database:      db_uri.path.split('/')[1],
    pool:          100,
    wait_timeout:  0.25,
    timeout:       250
  )

  class Subscribes < ActiveRecord::Base; end # :nodoc:

  class ResourcesData < ActiveRecord::Base; end # :nodoc:

  class AdviseReport < ActiveRecord::Base # :nodoc:
    validates :advise, uniqueness: {
      scope: :appname,
      message: 'only 1 advises for 1 application'
    }

    # add advises to dtabase
    # @param [Hash] meta metadata of application;
    # @param [Integer] advises juse quota advise;
    def self.add_advises(meta, advises)
      create(
        appname:       meta[:appname],
        advise:        advises,
        quota:         meta[:quota],
        usage:         meta[:usage],
        report_type:   meta[:type]
      )
    end
  end
end
