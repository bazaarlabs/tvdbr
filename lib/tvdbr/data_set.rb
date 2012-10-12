require 'hashie' unless defined?(Hashie)

module Tvdbr
  class DataSet < Hashie::Mash
    attr_reader :parent

    ## INSTANCE METHODS ##

    # Tvdb::DataSet.new(self, { :foo => "bar" })
    def initialize(parent, source_hash = nil, default = nil, &block)
      @parent = parent
      source_hash = normalize_keys(source_hash) if source_hash.is_a?(Hash)
      super(source_hash, default, &block)
    end

    # Outputs: <#Tvdb::Series actors="..." added=nil added_by=nil>
    def inspect
      ret = "<##{self.class.to_s}"
      self.keys.sort.each do |key|
        ret << " #{key}=#{self[key].inspect}"
      end
      ret << ">"
      ret
    end

    ## CLASS METHODS ##

    # Aliases the original propery to the new method name
    # alias_property :old, :new
    def self.alias_property(original, name)
      define_method(name) { self.send(original) }
    end

    # Turns a property "a | b | c" => ['a', 'b', 'c']
    # listify :lista, :listb
    def self.listify(*attrs)
      attrs.each do |a|
        define_method(a) { self[a] ? self[a][1..-1].split("|").map(&:strip) : []  }
      end
    end

    # Turns a property into a date object
    # dateify :release_date
    def self.dateify(*attrs)
      attrs.each do |a|
        define_method(a) { Time.parse(self[a]) rescue nil if self[a] }
      end
    end

    # Turns a relative image link to a full tvdb link url
    # absolutize :file_name
    def self.absolutize(*attrs)
      attrs.each do |a|
        define_method(a) { File.join("http://www.thetvdb.com/banners/", self[a]) if self[a] }
      end
    end

    private

      # Translates all keys to lowercase and to a symbol
      # => [:foo => "bar", ...]
      def normalize_keys(hash)
        hash.inject({}) do |options, (key, value)|
          options[(underscore(key) rescue key) || key] = normalize_value(value)
          options
        end
      end

      # Normalizes a value for the formatted hash
      # Sometimes TVDB returns a hash with a "__content__" key which needs to be removed
      def normalize_value(val)
        val.respond_to?(:has_key?) && val.has_key?("__content__") ? val["__content__"] : val
      end

      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
  end
end
