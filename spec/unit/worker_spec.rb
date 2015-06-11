require 'spec_helper'

module Akb
  describe Worker do
    let(:config) do 
      {
        'ports' => {
          'service' => 8080,
          'monitor' => 8091
        },
        'base_dir' => '/home/work/akb',
        'logging' => {
          'file' => '/home/work/akb/log/akb.log',
          'level' => 'DEBUG'
        },
        'subscribe' => {
           'database' => 'mysql2://work:work@127.0.0.1:3306/cc_ng',
           'refresh_interval' => 2
        },
        'analyze' => {
          'interval' => 1
        }
      }
    end

    let(:worker) do
      described_class.new(config)
    end

    before do
      Subscribes.create!(appname: 'name1', cpu: false, cpu_quota: 1, memory: false, memory_quota: 1024, disk: false, disk_quota: 1024,  perm: true, perm_quota: 1024)
      ResourcesData.create!(appname: 'name1', cpu: 0.1, disk: 128, memory: 128, perm: 128)
    end

    it 'should receive timer create method' do
      Akb.run_in_eventloop do 
        expect(worker).to receive(:setup_refresh_timer)
        expect(worker).to receive(:setup_analyze_timer)
        worker.setup
      end
    end

    it 'should create worker' do
      expect(worker.analyze_interval).to eq(1)
      expect(worker.refresh_interval).to eq(2)
    end

    it 'should do nothing if item disabled' do
      name = 'name1'
      metadata = {'cpu' => false, 'cpu_quota' => 2}
      item = 'cpu'
      expect(worker).to receive(:do_analyze).and_return(nil)
      worker.send(:do_analyze, name, metadata, item)
    end

    let(:app_data) {
      {
        'name' => 'name1',
        'cpu' => 2
      }
    }
    it 'should do nothing is usage not updated' do
      name = 'name1'
      metadata = {'cpu' => true, 'cpu_quota' => 2}
      item = 'cpu'
      expect(worker).to receive(:do_analyze).and_return(nil)
      worker.send(:do_analyze, name, metadata, item)
    end

    it 'should make right analyze package' do
      param_to_convert = {
        appname: 'name',
        quota: 1,
        usage: 2,
        type: 'cpu'
      }
      expect(worker.make_analyze_params(param_to_convert)).to eq(param_to_convert)
    end

    it 'should update sublist' do
      worker.send(:update_sublist)
      expect(worker.app_registry).not_to be_nil
    end

    it 'should update usage data' do
      worker.send(:update_usage)
      expect(worker.app_data).not_to be_nil
    end

    it 'should update sublist and usage at 1st period' do
      Akb.close_eventloop_after(2) do
        expect(worker).to receive(:update_sublist)
        expect(worker).to receive(:update_usage)
        worker.setup
      end
    end

    it 'should do analyze at 1st period' do
      Akb.close_eventloop_after(1) do
        expect(worker).to receive(:analyze)
        worker.setup
      end
    end

    it 'should do analyze work' do
      Akb.close_eventloop_after(2.2) do
        expect(worker).to receive(:do_analyze).at_least(:once)
        worker.setup
      end
    end
  end
end
