require 'spec_helper'

describe Berta::Service do
  subject(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'returns instace of Service with given data' do
      expect(service.endpoint).not_to be_empty
    end

    it 'connects to endpoint' do
      expect { service.client.get_version }.not_to raise_error
    end
  end

  describe '.running_vms' do
    context 'with empty exclude', :vcr do
      it 'gets running vms' do
        vms = service.running_vms
        expect(vms.count).to eq(2)
      end
    end

    context 'with exclude with id', :vcr do
      before(:each) do
        Berta::Settings.exclude['ids'] = [6, 420]
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get 1 vm' do
        vms = service.running_vms
        expect(vms.count).to eq(1)
      end
    end

    context 'with exclude with users', :vcr do
      before(:each) do
        Berta::Settings.exclude['users'] = ['oneadmin']
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get 0 vms' do
        vms = service.running_vms
        expect(vms.length).to eq(0)
      end
    end

    context 'with exclude with groups', :vcr do
      before(:each) do
        Berta::Settings.exclude['groups'] = ['oneadmin']
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get 0 vms' do
        vms = service.running_vms
        expect(vms.length).to eq(0)
      end
    end

    context 'with exclude with groups that doesnt exist', :vcr do
      before(:each) do
        Berta::Settings.exclude['groups'] = ['group']
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get all vms' do
        vms = service.running_vms
        expect(vms.length).to eq(2)
      end
    end

    context 'with exclude with clusters', :vcr do
      before(:each) do
        Berta::Settings.exclude['clusters'] = %w(default notsodefault)
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get 0 vms' do
        vms = service.running_vms
        expect(vms.length).to eq(0)
      end
    end

    context 'with exclude with clusters that doesnt exist', :vcr do
      before(:each) do
        Berta::Settings.exclude['clusters'] = ['himum']
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get all vms' do
        vms = service.running_vms
        expect(vms.length).to eq(2)
      end
    end

    context 'with exclude with all set but invalid', :vcr do
      before(:each) do
        Berta::Settings.exclude['clusters'] = ['ahojmiso']
        Berta::Settings.exclude['users'] = ['totoje']
        Berta::Settings.exclude['groups'] = ['test']
        Berta::Settings.exclude['ids'] = ['8']
      end

      after(:each) do
        Berta::Settings.reload!
      end

      it 'get all vms' do
        vms = service.running_vms
        expect(vms.length).to eq(2)
      end
    end

    context 'with wrong secret', :vcr do
      let(:wrong_service) { Berta::Service.new('ahoj:miso', 'http://localhost:2633/RPC2') }

      it 'raises authentication error' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::AuthenticationError
      end
    end

    context 'with wrong endpoint', :vcr do
      let(:wrong_service) { Berta::Service.new('oneadmin:opennebula', 'http://remotehost:2633/RPC2') }

      it 'raises resource retrieval error' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::ResourceRetrievalError
      end
    end
  end
end