module Bosh
  module Helpers
    module BatManifest
      OpenstackBatManifest = Struct.new(
          :vip,
          :net_id,
          :net_cidr,
          :net_reserved_string,
          :net_static,
          :net_gateway,
          :stemcell_version_override) do

        def load_env(env)
          self.vip = env['BOSH_OPENSTACK_VIP_BAT_IP']
          self.net_id = env['BOSH_OPENSTACK_NET_ID']
          self.net_cidr = env['BOSH_OPENSTACK_NETWORK_CIDR']
          self.net_reserved_string = env['BOSH_OPENSTACK_NETWORK_RESERVED']
          self.net_static = env['BOSH_OPENSTACK_NETWORK_STATIC']
          self.net_gateway = env['BOSH_OPENSTACK_NETWORK_GATEWAY']
        end

        def net_reserved
          net_reserved_string.split(/[|,]/).map(&:strip)
        end

        def stemcell_version
          self.stemcell_version_override || 'latest'
        end

        def generate(template_path, output_path, net_type, director_uuid)
          bat_manifest = ERB.new(File.read(template_path)).result(binding)

          File.write(output_path, bat_manifest)
        end
      end
    end
  end
end
