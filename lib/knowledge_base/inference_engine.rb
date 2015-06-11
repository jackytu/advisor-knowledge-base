require 'knowledge_base/knowledge_base_dsl'

module Akb

  # inference engine, do inference according to the rules defined in rules/;
  # Inference engine will do very constraint inference based on three factors:
  # usage, factor, and time range;
  class InferenceEngine

    # Analyze Exception
    class AnalyzeException < Exception
    end

    # do analyze based on the data and rules defined in `rules` dir;
    # the analyze will give a suggested quota value, if rule condition satisfied;
    # @param [Hash] data input data;
    # @param [Block] blk callback proc;
    def do_analyze(data = nil, &blk)
      return unless data
      usage = data[:usage]
      quota = pre_quota = data[:quota]
      return unless usage && quota

      rules = self.class.rules
      rules.each_pair do |_, rule|
        if instance_eval(rule[:condition])
          instance_eval(rule[:conclusion])
          break
        end
      end
      blk.call(data, quota) if pre_quota != quota
    rescue => ex
      raise Akb::InferenceEngine::AnalyzeException.new(ex)
    end

    class << self

      attr_accessor :rules

      def define_rules(&blk)
        k = Class.new do
          include KnowledgeBaseDSL
        end
        k.new(self).instance_eval(&blk)
      end
    end
  end
end
