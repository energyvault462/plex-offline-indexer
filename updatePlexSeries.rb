require 'inifile'
require 'tvdbr'
require 'time'

version = "1.1"
releaseDate = "2017-07-13"

@ini = IniFile.load('updatePlexSeries.ini')

@printSeriesToScreen=@ini['general']['printSeriesToScreen']
@tvdbapi = @ini['general']['tvdbApiKey']
@fileExt = @ini['general']['fileExt']

@tvdb = Tvdbr::Client.new('B43FF87DE395DF56')

def WriteDiscFile(fileInfo)
	fileName = File.join(fileInfo[:path], fileInfo[:fileName])
	if !File.exist?(fileName)
		out_file = File.new(fileName, "w")
		out_file.puts("<discstub>")
		out_file.puts("\t<title>Available on #{fileInfo[:streamService]}</title>")
		#out_file.puts("\t")
		out_file.puts("</discstub>")
		out_file.close
	end

end

def GetTvDbId(folderToCheck)
	fileToCheck = File.join(folderToCheck, "_tvdbid.ini")
	if File.exist?(fileToCheck)
		seriesIni = IniFile.load(fileToCheck)
		tvdbid = seriesIni['general']['tvdbid']
		startSeason = seriesIni['general']['startSeason']
		endSeason = seriesIni['general']['endSeason']
		if !startSeason 
			startSeason = 1
		end
		if !endSeason 
			endSeason = 200
		end
	end
	return {:tvdbid=>tvdbid, :startSeason=>startSeason, :endSeason=>endSeason}
end

def UpdateSeries(seriesInfo)
	series = @tvdb.find_series_by_id(seriesInfo[:tvdbid])
	network = series.network
	series.episodes.each do |e|
		
		begin
			if e.season_num.to_i >= seriesInfo[:startSeason] and e.season_num.to_i <= seriesInfo[:endSeason]
				if e.first_aired and Time.now >= e.first_aired
					if @printSeriesToScreen
						puts "#{series.series_name.tr(" ", ".")}.S#{e.season_num.rjust(2, "0")}E#{e.episode_num.rjust(2, "0")} - #{e.first_aired}: #{series.network}"
					end
					fileName = "#{series.series_name.tr(" ", ".")}.S#{e.season_num.rjust(2, "0")}E#{e.episode_num.rjust(2, "0")}.#{@fileExt}"
					WriteDiscFile({:streamService=>series.network, :path=>seriesInfo[:seriesPath], :fileName=>fileName})
				end
			end
		rescue Exception => e
			puts "Error:  #{series.series_name}"
			puts e
		end
	end
end

def IterateStreamServicePath(streamInfo)
	Dir.chdir(streamInfo[:streamPath])
	subdir_list=Dir["*"].reject{|o| not File.directory?(o)}
	subdir_list.each do |series|
		streamInfo[:seriesPath] = File.join(streamInfo[:streamPath], series)
		seriesInfo = GetTvDbId(streamInfo[:seriesPath])
		streamInfo[:tvdbid] = seriesInfo[:tvdbid]
		streamInfo[:startSeason] = seriesInfo[:startSeason]
		streamInfo[:endSeason] = seriesInfo[:endSeason]
		if streamInfo[:tvdbid] != "0"
			UpdateSeries(streamInfo)
		end
	end
end

@ini.each_section do |section|
  if section != "general"
		IterateStreamServicePath({:streamPath=>@ini[section]['path']})
  end
end
@ini = nil


#IterateStreamServicePath({:streamService=>'Netflix', :streamPath=>@netflixPath})
#IterateStreamServicePath({:streamService=>'Amazon', :streamPath=>@amazonPath})
#IterateStreamServicePath({:streamService=>'HBO', :streamPath=>@hboPath})
#IterateStreamServicePath({:streamService=>'Netflix', :streamPath=>@netflixNotOriginal})
