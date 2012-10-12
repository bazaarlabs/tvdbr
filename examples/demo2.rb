require 'rubygems'
require 'tvdbr'
require 'active_support/all'

# Updated APIs circa 10/05/2012
tvdb = Tvdbr::Client.new('5FEC454623154441')

# Find episode by id
episode = tvdb.find_episode_by_id(326177)
puts episode.inspect

# Find episode with airdate
episode = tvdb.find_episode_by_airdate(80348, '2007-09-24')
puts episode.inspect

# Find with remote id
series = tvdb.find_series_by_remote_id('tt0290978')
puts series.inspect

# Fetch using static updates instead of since
# Fetch series updates since given timestamp
results = tvdb.find_static_updates(:day)
puts "\n\nUpdated series today: #{results[:series].size} series\n\n"
tvdb.each_updated_series(:period => :day) do |series|
 puts "#{series.id} - #{series.title}"
end

# Fetch episode udpates since given timestamp
puts "\nUpdated episodes since 10 mins ago: #{results[:episodes].size} episodes\n\n"
tvdb.each_updated_episode(:period => :day) do |episode|
 puts "#{episode.id} - #{episode.name} - #{episode.seriesid}"
end