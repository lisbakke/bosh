require 'common/exec'
class Stemcell
  include Bosh::Exec

  attr_reader :path
  attr_reader :name
  attr_reader :version

  def self.from_bat_file(bat_file, path_or_uri)
    bat_config = Psych.load_file(bat_file)
    stemcell_config = bat_config['properties']['stemcell']

    Stemcell.new(stemcell_config['name'],
                 stemcell_config['version'],
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
