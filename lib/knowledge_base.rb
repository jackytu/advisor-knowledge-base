require 'knowledge_base/inference_engine'

module Akb
  module AkbMachine
    def inference_engine(name, &blk)
      kclass = Class.new Akb::InferenceEngine
      const_set name, kclass
      kclass.class_eval(&blk)
    end
    module_function :inference_engine
  end
end

require 'knowledge_base/rules/perm'
