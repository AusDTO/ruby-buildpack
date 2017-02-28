class LanguagePack::NodeInstaller
  MODERN_NODE_VERSION = "TO_BE_REPLACED_BY_CF_DEFAULTS"
  MODERN_BINARY_PATH  = "node-v#{MODERN_NODE_VERSION}-linux-x64"

  LEGACY_NODE_VERSION = "0.4.7"
  LEGACY_BINARY_PATH = "node-#{LEGACY_NODE_VERSION}"

  NODEJS_BASE_URL     = "https://s3pository.heroku.com/node/v#{MODERN_NODE_VERSION}/"

  def initialize(stack)
    @fetchers = {
      modern: LanguagePack::Fetcher.new(NODEJS_BASE_URL),
      legacy: LanguagePack::Fetcher.new(LanguagePack::Base::VENDOR_URL, LanguagePack::Base::DEFAULT_LEGACY_STACK)
    }
    @legacy   = stack == LanguagePack::Base::DEFAULT_LEGACY_STACK
  end

  def version
    if @legacy
      LEGACY_NODE_VERSION
    else
      MODERN_NODE_VERSION
    end
  end

  def binary_path
    if @legacy
      LEGACY_BINARY_PATH
    else
      MODERN_BINARY_PATH
    end
  end

  def install
    p "installing node"
    if @legacy
      @fetchers[:legacy].fetch_untar("#{LEGACY_BINARY_PATH}.tgz")
    else
      node_bin = "#{MODERN_BINARY_PATH}/bin/node"
      npm_bin = "#{MODERN_BINARY_PATH}/bin/npm"
      @fetchers[:modern].fetch_untar("#{MODERN_BINARY_PATH}.tar.gz", "")
      FileUtils.mv(node_bin, ".")
      FileUtils.mv(npm_bin, ".")
      FileUtils.cp_r("#{MODERN_BINARY_PATH}/lib", "../lib")
      FileUtils.rm_rf(MODERN_BINARY_PATH)
      p "lib file contents: #{Dir.glob('../lib/*')}"
    end
  end

  def self.default_node_version
    bin_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "compile-extensions", "bin"))
    manifest_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "manifest.yml"))
    `#{bin_path}/default_version_for #{manifest_path} node`.chomp
  end
end
