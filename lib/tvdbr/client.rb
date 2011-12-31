require 'httparty' unless defined?(HTTParty)

module Tvdbr
  class Client
    include HTTParty
    format :xml
    base_uri "http://www.thetvdb.com/api/"

    # Creates an instance of the TVDB interface
    # Tvdb.new('some_key')
    def initialize(api_key)
      @api_key = api_key
      check_api_key!
    end

    # Fetches a series object based on the given attributes hash
    # tvdb.fetch_series_from_data(:title => "Dexter", :kind => "TvShow", :starring => "xxxx, xxxx")
    # => { "SeriesName" => "Dexter", ... } or nil
    #
    def fetch_series_from_data(options={})
      return self.find_series_by_title(options[:title]) if options[:starring].nil?
      series_results = self.find_all_series_by_title(options[:title])
      expected_actors = options[:starring].split(",")
      series_results.compact.find { |series| series.actor_match?(expected_actors) }
    end

    # Yields the block for every updated series
    # tvdb.each_updated_series(:since => 1.day.ago) { |s| Media.find_by_tvdb_id(s.id).title = s.title }
    def each_updated_series(options={}, &block)
      updates = self.find_updates_since(options[:since])
      updates[:series].each do |series_id|
        series = self.find_series_by_id(series_id)
        block.call(series) if series && series.title
      end if updates[:series].respond_to?(:each)
    end

    # Yields the block for every updated episode
    # tvdb.each_updated_episode(:since => 1.day.ago) { |s| Episode.find_by_tvdb_id(s.id).title = s.title }
    def each_updated_episode(options={}, &block)
      updates = self.find_updates_since(options[:since])
      updates[:episodes].each do |episode_id|
        episode = self.find_episode_by_id(episode_id)
        block.call(episode) if episode && episode.name
      end if updates[:episodes].respond_to?(:each)
    end

    # Returns all series matching the given title
    # tvdb.find_all_series_by_title("Dexter")
    # => [{ "SeriesName" => "Dexter", ... }, ...]
    def find_all_series_by_title(title)
      result = self.class.get("/GetSeries.php", :query => { :seriesname => title, :language => "en" })['Data']
      return [] if result.blank? || result['Series'].blank?
      result = result['Series'].is_a?(Array) ? result['Series'] : [result['Series']]
      result.first(5).map { |s| self.find_series_by_id(s['seriesid']) }
    rescue MultiXml::ParseError => e
      puts "Result for title '#{title}' could not be parsed!"
      return []
    end

    # Returns the first series returned for a title
    # tvdb.find_series_by_title("Dexter")
    # => { "SeriesName" => "Dexter", ... }
    #
    def find_series_by_title(title)
      self.find_all_series_by_title(title).first
    end

    # Returns series data for a given series_id
    # tvdb.find_series_by_id(1234, :all => true)
    # tvdb.find_series_by_id(1234, :raw => true)
    def find_series_by_id(series_id, options={})
      series_url = "/series/#{series_id}"
      series_url << "/all" if options[:all]
      series_url << "/en.xml"
      result = self.get_with_key(series_url)['Data']
      return nil unless result && result['Series']
      return result if options[:all]
      return result["Series"] if options[:raw]
      Series.new(self, result["Series"])
    end

    # Returns Episode data for a given episode id
    # tvdb.find_episode_by_id(12345)
    # tvdb.find_episode_by_id(12345, :raw => true)
    def find_episode_by_id(episode_id, options={})
      episode_url = "/episodes/#{episode_id}"
      result = self.get_with_key(episode_url)['Data']
      return nil unless result && result['Episode']
      return result["Episode"] if options[:raw]
      Episode.new(self, result["Episode"])
    end

    # Returns the list of TVDB mirror_urls
    # => ["http://thetvdb.com", ...]
    def mirror_urls
      Array(self.get_with_key('/mirrors.xml')['Mirrors']['Mirror']['mirrorpath'])
    end

    # Returns a list of image locations for the series
    def banner_urls(series_id)
      self.get_with_key("/series/#{series_id}/banners.xml")['Banners']['Banner']
    end

    # Returns a list of series and episode updates since given time
    # tvdb.find_updates_since(1.day.ago)
    # => { :series => [1,2,3], :episodes => [1,2,3], :time => '<stamp>'  }
    def find_updates_since(time)
      stamp = time.to_i # Get timestamp
      result = self.class.get("/Updates.php?type=all&time=#{stamp}")['Items']
      { :series => result['Series'], :episodes => result['Episode'], :time => result['Time'] }
    end

    protected

      # Returns the given xml as a hash appending the api_key to the url
      # tvdb.get_with_key("/some/url", :query => { :foo => "bar" })
      def get_with_key(*args)
        args[0] = "/#{@api_key}/" + args[0]
        begin
          self.class.get(*args)
        rescue Exception => e
          { 'Data' => nil }
        end
      end

      # Checks if the api key works by retrieving mirrors
      def check_api_key!
        self.mirror_urls
      rescue
        raise "Please check your TVDB API Key!"
      end
  end
end
