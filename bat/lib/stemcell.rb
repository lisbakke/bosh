require 'common/exec'
class Stemcell
  include Bosh::Exec

  attr_reader :path
  attr_reader :name
  attr_reader :version

  def self.from_bat_file(bat_file, path_or_uri)
    bat_config = Psych.load_file(bat_file)
    stemcell_bat_config = bat_config['properties']['stemcell']

    stemcell_name = stemcell_bat_config['name']
    stemcell_version = stemcell_bat_config['version']

    if stemcell_version == 'latest'
      raise 'Specifying "latest" requires a local stemcell' unless File.exists(path_or_uri)

      Dir.mktmpdir do |dir|
        sh("tar xzf #{path_or_uri} --directory=#{dir} stemcell.MF")
        stemcell_manifest_config = Psych.load_file(File.join(dir, 'stemcell.MF'))

        stemcell_name = stemcell_manifest_config['name']
        stemcell_version = stemcell_manifest_config['version']
      end
    end

    Stemcell.new(stemcell_name,
                 stemcell_version,
                 path_or_uri)
  end

  def initialize(name, version, path=nil)
    @name = name
    @version = version
    @path = path
  end

  def to_s
    "#{name}-#{version}"
  end

  def to_path
    @path
  end

  def ==(other)
    to_s == other.to_s
  end
end
