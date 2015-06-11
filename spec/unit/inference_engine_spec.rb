require 'spec_helper'

module Akb
  describe InferenceEngine do
    let(:engine) {
      Akb::AkbMachine::Perm.new
    }

    before :each do
      allow(InferenceEngine).to receive(:rules).and_return({ rule1: {condition: 'usage>1', conclusion: 'quota=2'}})
    end

    it 'should return if data nill' do
      expect(engine.do_analyze).to be_nil
    end

    it 'should return if usage nil' do
      expect(engine.do_analyze(item: 'cpu')).to be_nil
    end

    it 'should return okay if data ok' do
      data = {
        usage: 2,
        quota: 3
      }
      expect{|hook| engine.do_analyze(data, &hook)}.to yield_with_args(data, 2)
    end
  end
end
