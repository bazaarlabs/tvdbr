module Tvdbr
  # {:combined_episodenumber=>"14", :imdb_id=>nil, :episode_number=>"14", :absolute_number=>nil, :first_aired=>"2010-05-04",
  #  :dvd_episodenumber=>nil, :episode_name=>"The Candidate", :rating=>"7.9", :filename=>"episodes/73739/1685171.jpg", :director=>"Jack Bender",
  #  :seasonid=>"66871", :writer=>"|Elizabeth Sarnoff|Jim Galasso|", :dvd_chapter=>nil, :production_code=>nil, :combined_season=>"6", :season_number=>"6",
  #  :dvd_season=>nil, :language=>"en", :dvd_discid=>nil, :lastupdated=>"1277153526",
  #  :overview=>"...", :id=>"1685171", :ep_img_flag=>"2", :rating_count=>"187", :seriesid=>"73739", :guest_stars=>nil}
  class Episode < DataSet
    alias_property :episode_name, :name
    alias_property :episode_number, :episode_num
    alias_property :season_number, :season_num
    alias_property :overview, :description
    alias_property :first_aired, :original_air_date
    dateify :first_aired
    listify :writer
    absolutize :filename
  end
end