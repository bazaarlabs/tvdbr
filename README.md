# TvdbR

The simple but complete ruby library for the TVDB apis. Created by Nathan Esquenazi for use at Miso.

Yes, there are a lot of libraries out there for this. I needed a few things that were different:

  * Easy way to 'verify' the correctness of a match beyond just title
  * An easy way to get all updates since a certain time, to keep our database synced
  * Easy helpers for accessing episodes from a series and the objects conceptually mapped to our existing schema.

Please reference the [TVDB APIs](http://thetvdb.com/wiki/index.php?title=Programmers_API) to 
become familiar with the available actions and properties.

## Installation

    $ sudo gem install tvdbr

### Usage

Create the tdvbr client:

    tvdb = Tvdbr::Client.new('API_KEY')

Get a series based on the id:

    series = tvdb.find_series_by_id('1234')

Get a series based on a remote (IMDB) id:

    series = tvdb.find_series_by_remote_id('tt0290978')

Get an episode based on the id:

    episode = tvdb.find_episode_by_id('5678')

Get an episode based on the seriesid and airdate:

    episode = tvdb.find_episode_by_airdate(80348, '2007-09-24')

Fetch a series based on the title:

    dexter = tvdb.fetch_series_from_data(:title => "Dexter")
    # => <#Tvbdr::Series>
    dexter.title # => "Dexter"
    dexter.actors # => ["Michael C. Hall", ...]
    dexter.genres # => ["Drama", ...]
    dexter.poster # => "http://thetvdb.com/some/poster.jpg"

Fetch a series based on the title and list of actors:

    dexter = tvdb.fetch_series_from_data(:title => "Dexter", :starring => "Michael C. Hall, Jennifer Carpenter")

Get the episodes for a series:

    series.episodes.each { |e| puts "#{e.name} - S#{e.season_num}E#{e.episode_num}" }

Get the updated series since a given timestamp:

    tvdb.each_updated_series(:since => 1.day.ago) do |series|
      puts "#{series.id} - #{series.title}"
    end

Get the updated episodes since a given timestamp:

    tvdb.each_updated_episode(:since => 1.day.ago) do |episode|
      puts "#{episode.id} - #{episode.name} - #{episode.seriesid}"
    end

You can also query using the newer static updates, by providing a 'period':

    tvdb.each_updated_episode(:period => :day) do |episode|
      puts "#{episode.id} - #{episode.name} - #{episode.seriesid}"
    end

You can provide `day`, `week`, or `month` to get complete data for that range of time.

## Known Issues

* None so far, but the gem is very young.
* ...except I wrote this in a day or two and didn't write specs :(
* ...but this will soon be corrected!
