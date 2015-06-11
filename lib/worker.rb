require 'knowledge_base'

module Akb
  # Advisor knowledge-base worker::
  #   Analyze the status of specified item(cpu, memory, disk, or jvm usage)
  #   The application data is pull from UsageData Database periodically.
  #   The advise rule are defined in the format of KnowledgeBaseDSL.
  class Worker

    attr_reader :config
    attr_reader :logger

    # application registry
    attr_reader :app_registry 

    # application usage data
    attr_reader :app_data

    # the interval to analyze application status
    attr_reader :analyze_interval

    # the interval to refresh application data
    attr_reader :refresh_interval

    # @param [Hash] config akb base configures
    def initialize(config)
      @logger = Akb.logger
      @config = config
      @app_registry = {}
      @app_data = {}
      @analyze_interval = @config['analyze']['interval']
      @refresh_interval = @config['subscribe']['refresh_interval']
    end

    # setup akb workers
    # refresh_worker: refresh application data;
    # analyze_worker: analyze application status;
    def setup
      logger.info 'setup workers'

      setup_refresh_timer
      setup_analyze_timer
    end

    # update advise table;
    # @param [Hash] data raw analyze data
    # @param [Integer] advise suggested quota value
    def update_advise_db(data, advise)
      AdviseReport.add_advises(data, advise)
      logger.info "make advise to application <#{data[:appname]}> with advise quota = #{advise}."
    end

    # make analyze data package
    # @param [Hash] options analyze options;
    # @return [Hash] analyze params package;
    def make_analyze_params(options = {})
      {
        usage: options[:usage],
        quota: options[:quota],
        appname: options[:appname],
        type: options[:type],
      }
    end

    private

    # update subscriber information
    def update_sublist
      # TODO: replace `where` method to get sublist
      logger.debug 'update sublist'

      sublist = Subscribes.where.not(appname: nil)

      sublist.each do |sub; data|
        data = {}
        %w(cpu cpu_quota disk disk_quota memory memory_quota perm perm_quota).each do |item|
          data[item] = sub.send(item)
        end
        app_registry[sub.appname] = data
      end

      logger.debug 'update sublist completed'
    rescue ActiveRecord::ActiveRecordError => ex
      logger.error "access database failed with #{ex.message}."
    rescue => ex
      logger.error "update sublist failed with #{ex.message}."
    end

    # update application usage data
    def update_usage
      logger.debug 'update usage'

      # TODO: replace `where` method to get sublist
      usage_data = ResourcesData.where.not(appname: nil)

      usage_data.each do |usage; data|
        data = {}
        %w(cpu disk memory perm).each do |item|
          data[item] = usage.send(item)
        end
        app_data[usage.appname] = data
      end

      logger.debug 'update usage completed'
    rescue ActiveRecord::ActiveRecordError => ex
      logger.debug "access database failed with #{ex.message}."
    rescue => ex
      logger.error "update usage data failed with #{ex.message}."
    end

    # setup refresh worker, refresh sublist and usage data;
    def setup_refresh_timer
      EM.add_periodic_timer(refresh_interval) do
        update_sublist
        update_usage
      end
    end

    # setup analyze worker,  analyze application status;
    def setup_analyze_timer
      EM.add_periodic_timer(analyze_interval) do
        analyze
      end
    end

    # analyze application stauts;
    def analyze
      app_registry.each do |name, app|
        %w(cpu disk memory perm).each do |item|
          do_analyze(name, app, item)
        end
      end
    end

    # initialize an akb inference engine object
    # @param [String] item item to analyze;
    # @return [Object] akb inference engine object;
    def akb_engine(item)
      Akb::AkbMachine.const_get(item.capitalize).new
    end

    # do analyze process
    # @param [String] name applicaiton name;
    # @param [Hash] metadata application metadata;
    # @param [String] item item to analyze;
    def do_analyze(name, metadata, item)
      base_data = app_data[name]
      enabled = metadata[item]

      return unless enabled && base_data

      logger.debug "analyze #{item} status of #{name}"

      data = make_analyze_params(usage: base_data[item], 
                                 quota: metadata["#{item}_quota"],
                                 appname: name,
                                 type: item
                                )
      akb_engine(item).do_analyze(data) do |input, output|
        update_advise_db(input, output) if output
      end
    rescue Akb::InferenceEngine::AnalyzeException => ex
      logger.error "analyze with exception #{ex.message}"
    end
  end
end
