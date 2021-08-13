# using Pkg
# # Pkg.add("CSV")
# Pkg.add("BenchmarkTools")
using CSV
using Statistics


include("./playlists.jl")
include("./printFuncs.jl")
include("./dataFuncs.jl")
include("./keyFuncs.jl")
include("./testingFuncs.jl")

function playlistTest(allData, playlist, playlistRecs, columnsList, playlistTitle, yearMin, yearMax)
    println("$(playlistTitle) Testing")

    println("Building \"$(playlistTitle)\" Playlists")
    playlistIds = getPlaylist(allData, playlist)
    playlistRecIds = getPlaylist(allData, playlistRecs)

    println("Running Score Methods Comparison")
    tester_Scores(allData, playlistIds, columnsList, yearMin=yearMin, yearMax=yearMax, recList=playlistRecIds, playlistTitle=playlistTitle)

    println("Running Multiplier Methods Comparison")
    tester_Multipliers(allData, playlistIds, columnsList, yearMin=yearMin, yearMax=yearMax, print=false, recList=playlistRecIds, playlistTitle=playlistTitle)

    println("Getting Recommendations for $(playlistTitle)")
    getPlaylistRecommendations(allData, playlistIds, columnsList, yearMin=yearMin, yearMax=yearMax, count=10, print=false)
end




# Read in the Data
println("Reading Data")
allData = CSV.File("data.csv")
columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]

@time playlistTest(allData, rockAnthems, rockAnthemsRec, columnsList, "90's Rock Anthems", 1993, 1996)

println("Press Enter to continue")
readline()


# Build Playlists
# println("Building \"90's Rock Anthems\" Playlists")
# rockAnthemsIds = getPlaylist(allData, rockAnthems)
# # rockAnthemsRecIds = getPlaylist(allData, rockAnthemsRec)

# println(rockAnthemsIds)


# println("Building \"Classical Essentials\" Playlists")
# classicalEssentialsIds = getPlaylist(allData, classicalEssentials)
# classicalEssentialsRecIds = getPlaylist(allData, classicalEssentialsRec)


# println("Building \"Teen Beats\" Playlists")
# teenBeatsIds = getPlaylist(allData, teenBeats)
# teenBeatsRecIds = getPlaylist(allData, teenBeatsRec)


# println("Building \"Mood Booster\" Playlists")
# moodBoosterIds = getPlaylist(allData, moodBooster)
# moodBoosterRecIds = getPlaylist(allData, moodBoosterRec)






# println("Beginning Testing\nThis may take a while to complete because it is running multiple different tests.")
# columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]

# #########################################################################################################################
#90's Rock Anthems Testing
# println("90's Rock Anthems Testing")

# println("Building \"90's Rock Anthems\" Playlists")
# rockAnthemsIds = getPlaylist(allData, rockAnthems)
# rockAnthemsRecIds = getPlaylist(allData, rockAnthemsRec)

# println("Running Score Methods Comparison")
# tester_Scores(allData, rockAnthemsIds, columnsList, yearMin=1991, yearMax=1996, recList=rockAnthemsRecIds, playlistTitle="90s Rock Anthems")

# println("Running Multiplier Methods Comparison")
# tester_Multipliers(allData, rockAnthemsIds, columnsList, yearMin=1991, yearMax=1996, print=false, recList=rockAnthemsRecIds, playlistTitle="90s Rock Anthems")

# println("Getting Recommendations for 90's Rock Anthems")
# getPlaylistRecommendations(allData, rockAnthemsIds, columnsList, yearMin=1991, yearMax=1996, count=10, print=false)

println("Press Enter to continue")
readline()

# #########################################################################################################################
# # Classical Essentials Testing
# println("Classical Essentials Testing")

# println("Building \"Classical Essentials\" Playlists")
# classicalEssentialsIds = getPlaylist(allData, classicalEssentials)
# classicalEssentialsRecIds = getPlaylist(allData, classicalEssentialsRec)

# println("Running Score Methods Comparison")
# tester_Scores(allData, classicalEssentialsIds, columnsList; yearMin=1998, yearMax=2003, recList=classicalEssentialsRecIds, playlistTitle="Classical Essentials")

# println("Running Multiplier Methods Comparison")
# tester_Multipliers(allData, classicalEssentialsIds, columnsList; yearMin=1998, yearMax=2003, print=false, recList=classicalEssentialsRecIds, playlistTitle="Classical Essentials")

# println("Getting Recommendations for Classical Essentials")
# getPlaylistRecommendations(allData, classicalEssentialsIds, columnsList; yearMin=1998, yearMax=2003, count=10, print=false)

# #########################################################################################################################
# # Teen Beats Testing
# println("Teen Beats Testing")

# println("Building \"Teen Beats\" Playlists")
# teenBeatsIds = getPlaylist(allData, teenBeats)
# teenBeatsRecIds = getPlaylist(allData, teenBeatsRec)

# println("Running Score Methods Comparison")
# tester_Scores(allData, teenBeatsIds, columnsList; yearMin=2015, recList=teenBeatsRecIds, playlistTitle="Teen Beats")

# println("Running Multiplier Methods Comparison")
# tester_Multipliers(allData, teenBeatsIds, columnsList; yearMin=2015, print=false, recList=teenBeatsRecIds, playlistTitle="Teen Beats")

# println("Getting Recommendations for Teen Beats")
# getPlaylistRecommendations(allData, teenBeatsIds, columnsList; yearMin=2015, yearMax=2020, count=10, print=false)

# #########################################################################################################################
# # Mood Booster Testing
# println("Mood Booster Testing")

# println("Building \"Mood Booster\" Playlists")
# moodBoosterIds = getPlaylist(allData, moodBooster)
# moodBoosterRecIds = getPlaylist(allData, moodBoosterRec)

# println("Running Score Methods Comparison")
# tester_Scores(allData, moodBoosterIds, columnsList; yearMin=2015, recList=moodBoosterRecIds, playlistTitle="Mood Booster")

# println("Running Multiplier Methods Comparison")
# tester_Multipliers(allData, moodBoosterIds, columnsList; yearMin=2015, print=false, recList=moodBoosterRecIds, playlistTitle="Mood Booster")

# println("Getting Recommendations for Mood Booster")
# getPlaylistRecommendations(allData, moodBoosterIds, columnsList; yearMin=2018, yearMax=2020, count=10, print=false)