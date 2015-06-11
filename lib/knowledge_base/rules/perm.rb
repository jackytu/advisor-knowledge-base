module Akb::AkbMachine
  inference_engine :Perm do
    define_rules do
      rule :rule1, :condition => 'usage > 10', :conclusion => 'quota = usage/0.6'
    end
  end
end
