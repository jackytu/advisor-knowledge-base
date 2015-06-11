require 'logger'
require 'timeout'
require 'config'

##
# Advisor Knowledge Base
# AKB is used for applicaiton performance and resource status analyze;
# AKB will use a AKB DSL to analyze, which defined the usage, range, quota
# inference rules for analyze.
#
module Akb

  attr_accessor :log
  attr_accessor :config

  DEFAULT_CONFIG = File.expand_path('../../config/akb.yml', __FILE__)

  # get the global seetings from config file.
  # @param [String] config_path configure file path;
  def global_settings(config_path = nil)
    config_file = config_path ? config_path : DEFAULT_CONFIG
    unless File.exist?(config_file)
      abort "ERROR: no config specified and default config file #{config_file} not exist"
    end
    @config ||= AkbConfig.new(YAML.load_file(config_file))
  rescue => e
    abort "ERROR: Failed loading config: #{e}"
  end

  # @note this is not used yet!
  # run command with timeout, if timeout, the process will be killed.
  # @param [String] command command to exec;
  # @param [Integer] timeout command exec timeout.
  # @return [Bollean] running state.
  def promise_run_with_timeout(command, timeout = 5)
    pid = Process.spawn(command)
    begin
      Timeout.timeout(timeout) do
        pid, status = Process.wait2(pid)
        return true, status.exitstatus == 0 ? true : false
      end
    rescue Timeout::Error
      Process.kill('TERM', pid)
      return false
    end
  end

  module_function :global_settings
  DEFAULT_LOGFILE = global_settings['base_dir'] + '/log/akb.log'

  # create a log object;
  # @param [String] logging_file logging filename;
  # @return [Object] log object;
  def logger(logging_file = nil)
    log_path = logging_file ? logging_file : DEFAULT_LOGFILE
    FileUtils.mkdir_p(File.dirname(log_path)) unless File.exist?(log_path)
    @log = Logger.new(log_path, 10, 5_242_880)
    @log.level = Logger::DEBUG
    @log.formatter = proc {|severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity} #{progname} #{msg}\n"
    }
    @log
  end

  module_function :logger
  module_function :promise_run_with_timeout
end
