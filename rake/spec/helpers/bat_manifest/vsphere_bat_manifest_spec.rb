require 'spec_helper'
require_relative '../../../lib/helpers/bat_manifest/vsphere_bat_manifest'

describe Bosh::Helpers::BatManifest::VsphereBatManifest do

  let(:env) {
    {
        'BOSH_BAT_IP' => '192.168.0.4',
        'BOSH_VSPHERE_NET_ID' => 'net_id',
        'BOSH_VSPHERE_NETWORK_CIDR' => '192.168.0.0/24',
        'BOSH_VSPHERE_NETWORK_RESERVED_ADMIN' => '192.168.0.5',
        'BOSH_VSPHERE_NETWORK_RESERVED' => '192.168.0.6 - 192.168.0.10 | 192.168.0.20 - 192.168.0.29',
        'BOSH_VSPHERE_NETWORK_STATIC_BAT' => '192.168.0.4',
        'BOSH_VSPHERE_NETWORK_STATIC_BOSH' => '192.168.0.3',
        'BOSH_VSPHERE_GATEWAY' => '192.168.0.1',
        'BOSH_MICROBOSH_IP' => '192.168.0.2',
    }
  }

  describe '#load_env' do

    before do
      subject.load_env env
    end

    its(:ip) { should eq '192.168.0.4' }
    its(:net_id) { should eq 'net_id' }
    its(:net_cidr) { should eq '192.168.0.0/24' }
    its(:net_reserved_admin) { should eq '192.168.0.5' }
    its(:net_reserved) { should eq ['192.168.0.6 - 192.168.0.10', '192.168.0.20 - 192.168.0.29'] }
    its(:net_static_bat) { should eq '192.168.0.4' }
    its(:net_static_bosh) { should eq '192.168.0.3' }
    its(:gateway) { should eq '192.168.0.1' }
    its(:stemcell_version) { should eq 'latest' }
    its(:microbosh_ip) { should eq '192.168.0.2' }
  end

  describe '#generate' do

    let(:director_uuid) { 'abc' }

    it 'writes the yaml' do
      manifest = described_class.new
      manifest.load_env(env)

      template_path = File.expand_path(
          File.join(File.dirname(__FILE__), '..', '..', '..', 'templates',
                    'bat_vsphere.yml.erb'))

      Tempfile.open('bat_output') do |output|
        manifest.generate(template_path, output.path, director_uuid)
        expect(YAML.load_file(output.path)).to eq({'cpi' => 'vsphere',
                                                   'properties' =>
                                                       {'uuid' => 'abc',
                                                        'static_ip' => '192.168.0.4',
                                                        'pool_size' => 1,
                                                        'stemcell' => {'name' => 'bosh-stemcell', "version" => "latest"},
                                                        'instances' => 1,
                                                        'mbus' => 'nats://nats:0b450ada9f830085e2cdeff6@192.168.0.4:4222',
                                                        'network' =>
                                                            {'cidr' => '192.168.0.0/24',
                                                             'reserved' =>
                                                                 ['192.168.0.2',
                                                                  '192.168.0.5',
                                                                  '192.168.0.6 - 192.168.0.10',
                                                                  '192.168.0.20 - 192.168.0.29',
                                                                  '192.168.0.3'],
                                                             'static' => %w(192.168.0.4),
                                                             'gateway' => '192.168.0.1',
                                                             'vlan' => 'net_id'}}})
      end
    end

  end
end
