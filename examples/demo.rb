require 'rubygems'
require 'tvdbr'
require 'active_support/all'

tvdb = Tvdbr::Client.new('5FEC454623154441')

# Fetch series based on title and starring
series_wrong = tvdb.fetch_series_from_data(:title => "Dexter",
  :starring => "Adewale Akinnuoye-Agbaje, Sam Anderson, Naveen Andrews, L. Scott Caldwell, Nestor Carbonell, Francois Chau, Henry Ian Cusick, Jeremy Davies, Emilie de Ravin, Michael Emerson, Jeff Fahey, Fionnula Flanagan, Matthew Fox, Jorge Garcia, Maggie Grace, Josh Holloway, Malcolm David Kelley, Daniel Dae Kim, Yunjin Kim, Ken Leung, Evangeline Lilly, Rebecca Mader, Elizabeth Mitchell, Dominic Monaghan, Terry O'Quinn, Harold Perrineau, Zuleikha Robinson, Michelle Rodriguez, Kiele Sanchez,Rodrigo Santoro, Ian Somerhalder, John Terry, Sonya Walger, Cynthia Watros")
puts "Wrong Match: #{series_wrong.inspect}"

# Fetch series based on title and starring
series_right = tvdb.fetch_series_from_data(:title => "Lost",
  :starring => "Adewale Akinnuoye-Agbaje, Sam Anderson, Naveen Andrews, L. Scott Caldwell, Nestor Carbonell, Francois Chau, Henry Ian Cusick, Jeremy Davies, Emilie de Ravin, Michael Emerson, Jeff Fahey, Fionnula Flanagan, Matthew Fox, Jorge Garcia, Maggie Grace, Josh Holloway, Malcolm David Kelley, Daniel Dae Kim, Yunjin Kim, Ken Leung, Evangeline Lilly, Rebecca Mader, Elizabeth Mitchell, Dominic Monaghan, Terry O'Quinn, Harold Perrineau, Zuleikha Robinson, Michelle Rodriguez, Kiele Sanchez,Rodrigo Santoro, Ian Somerhalder, John Terry, Sonya Walger, Cynthia Watros")
puts "Right Match: #{series_right.inspect}"

puts "\n\n"
series = series_right
puts series.title + " (" + series.categories.join(", ") + ")"
puts series.synopsis
puts series.starring.join(", ")
puts series.poster
puts series.release_date.inspect

# Fetch episodes for a series
puts "\nEpisodes:\n\n"
series.episodes.each do |e|
 puts e.name + " (S#{e.season_num}E#{e.episode_num})"
end

# Fetch series updates since given timestamp
time = 10.minutes.ago
results = tvdb.find_updates_since(time)
puts "\n\nUpdated series since 10 mins ago: #{results[:series].size} series\n\n"
tvdb.each_updated_series(:since => time) do |series|
 puts "#{series.id} - #{series.title}"
end

# Fetch episode udpates since given timestamp
puts "\nUpdated episodes since 10 mins ago: #{results[:episodes].size} episodes\n\n"
tvdb.each_updated_episode(:since => time) do |episode|
 puts "#{episode.id} - #{episode.name} - #{episode.seriesid}"
end