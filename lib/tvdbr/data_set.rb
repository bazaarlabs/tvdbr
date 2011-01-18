module Tvdbr
  class DataSet < Hashie::Mash
    attr_reader :parent

    ## INSTANCE METHODS ##

    # Tvdb::DataSet.new(self, { :foo => "bar" })
    def initialize(parent, *args)
      @parent = parent
      args[0] = normalize_keys(args[0]) if args[0].is_a?(Hash)
      super(*args)
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
        define_method(a) { self[a] ? self[a].from(1).split("|").map(&:strip) : []  }
      end
    end

    # Turns a property into a date object
    # dateify :release_date
    def self.dateify(*attrs)
      attrs.each do |a|
        define_method(a) { Time.parse(self[a]) if self[a] }
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
          options[(key.underscore rescue key) || key] = value
          options
        end
      end

  end
end
