require 'spec_helper'
require_relative '../../../lib/helpers/bat_manifest/openstack_bat_manifest'

describe Bosh::Helpers::BatManifest::OpenstackBatManifest do

  let(:env) {
    {
        'BOSH_OPENSTACK_VIP_BAT_IP' => '192.168.0.4',
        'BOSH_OPENSTACK_NET_ID' => 'net_id',
        'BOSH_OPENSTACK_NETWORK_CIDR' => '192.168.0.0/24',
        'BOSH_OPENSTACK_NETWORK_RESERVED' => '192.168.0.6 - 192.168.0.10 | 192.168.0.20 - 192.168.0.29',
        'BOSH_OPENSTACK_NETWORK_STATIC' => '192.168.0.4',
        'BOSH_OPENSTACK_NETWORK_GATEWAY' => '192.168.0.1',
    }
  }

  describe '#load_env' do

    before do
      subject.load_env env
    end

    its(:vip) { should eq '192.168.0.4' }
    its(:net_id) { should eq 'net_id' }
    its(:net_cidr) { should eq '192.168.0.0/24' }
    its(:net_reserved) { should eq ['192.168.0.6 - 192.168.0.10', '192.168.0.20 - 192.168.0.29'] }
    its(:net_static) { should eq '192.168.0.4' }
    its(:net_gateway) { should eq '192.168.0.1' }
  end

  describe '#generate' do

    let(:director_uuid) { 'abc' }
    let(:net_type) { 'manual' }

    it 'writes the yaml' do
      manifest = described_class.new
      manifest.load_env(env)

      template_path = File.expand_path(
          File.join(File.dirname(__FILE__), '..', '..', '..', 'templates',
                    'bat_openstack.yml.erb'))

      Tempfile.open('bat_output') do |output|
        manifest.generate(template_path, output.path, net_type, director_uuid)
        expect(YAML.load_file(output.path)).to eq({'cpi' => 'openstack',
                                                   'properties' =>
                                                       {'static_ip' => '192.168.0.4',
                                                        'uuid' => 'abc',
                                                        'pool_size' => 1,
                                                        'stemcell' => {'name' => 'bosh-stemcell', 'version' => 'latest'},
                                                        'instances' => 1,
                                                        'key_name' => 'jenkins',
                                                        'mbus' => 'nats://nats:0b450ada9f830085e2cdeff6@192.168.0.4:4222',
                                                        'network' =>
                                                            {'cidr' => '192.168.0.0/24',
                                                             'reserved' =>
                                                                 [['192.168.0.6 - 192.168.0.10', "192.168.0.20 - 192.168.0.29"]],
                                                             'static' => %w(192.168.0.4),
                                                             'gateway' => '192.168.0.1',
                                                             'security_groups' => %w(default),
                                                             'net_id' => 'net_id'}}})
      end
    end

  end
end
