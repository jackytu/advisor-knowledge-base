module Akb
  # knowledge base dsl
  module KnowledgeBaseDSL
    def initialize(controller)
      @controller = controller
    end

    # add rule to rules
    def rule(name, opts = {})
      rules[name] = {}
      rules[name].merge!(opts)
    end

    # rules attribute
    def rules
      @controller.rules ||= {}
    end
  end
end
