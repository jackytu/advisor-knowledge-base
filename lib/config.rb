require 'membrane'

module Akb
  # AKB config, define config schema
  class AkbConfig
    DEFAULT_CONFIG = {
      'ports' => {
        'service' => 8080,
        'monitor' => 8091
      }
    }

    def self.schema
      ::Membrane::SchemaParser.parse do
        {
          'ports' => {
            'service' => Integer,
            'monitor' => Integer
          },
          'logging' => {
            'file'    => String,
            'level'   => String
          },
          'subscribe' => {
            'database' => String,
            'refresh_interval' => Integer
          },
          'analyze'  => {
            'interval' => Integer
          }
        }
      end
    end

    # validate config from file
    def self.from_file(file_path)
      new(YAML.load_file(file_path)).tap(&:validate)
    end

    # init config
    def initialize(config)
      @config = DEFAULT_CONFIG.merge(config)
    end

    # validate config
    def validate
      self.class.schema.validate(@config)
    end

    def [](key)
      @config[key]
    end

    def []=(key, val)
      @config[key] = val
    end

    def each(&blk)
      @config.each(&blk)
    end
  end
end
