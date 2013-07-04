module Bosh
  module Helpers
    module BatManifest
      VsphereBatManifest = Struct.new(
          :ip,
          :net_id,
          :net_cidr,
          :net_reserved_admin,
          :net_reserved_string,
          :net_static_bat,
          :net_static_bosh,
          :gateway,
          :stemcell_version_override,
          :microbosh_ip) do

        def load_env(env)
          self.ip = env['BOSH_VSPHERE_BAT_IP']
          self.net_id = env['BOSH_VSPHERE_NET_ID']
          self.net_cidr = env['BOSH_VSPHERE_NETWORK_CIDR']
          self.net_reserved_admin = env['BOSH_VSPHERE_NETWORK_RESERVED_ADMIN']
          self.net_reserved_string = env['BOSH_VSPHERE_NETWORK_RESERVED']
          self.net_static_bat = env['BOSH_VSPHERE_NETWORK_STATIC_BAT']
          self.net_static_bosh = env['BOSH_VSPHERE_NETWORK_STATIC_BOSH']
          self.gateway = env['BOSH_VSPHERE_GATEWAY']
          self.microbosh_ip = env['MICROBOSH_IP']
        end

        def net_reserved
          net_reserved_string.split(/[|,]/).map(&:strip)
        end

        def stemcell_version
          self.stemcell_version_override || 'latest'
        end

        def generate(template_path, output_path, director_uuid)
          bat_manifest = ERB.new(File.read(template_path)).result(binding)

          File.write(output_path, bat_manifest)
        end
      end
    end
  end
end
