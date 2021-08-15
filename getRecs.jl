using CSV
using DataFrames
using BenchmarkTools

include("./printFuncs.jl")
include("./dataFuncs.jl")
include("./keyFuncs.jl")
include("./testingFuncs.jl")


################################################################
# Create a playlist of song titles and artists
################################################################
example = [
    ("Magic In The Hamptons (feat. Lil Yachty)", "Social House"),
    ("Sunday Best", "Surfaces"),
    ("Electric Love", "BØRNS")
]

# Add songs and artist here
playlist = [
    ("Magic In The Hamptons (feat. Lil Yachty)", "Social House"),
    ("Sunday Best", "Surfaces"),
    ("Electric Love", "BØRNS")
]

# The number of recommendations that you want
count = 20

# The year range that songs are searched for
# Also affects playlist generation
yearMin = 2010
yearMax = 2020


columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]


println("Loading all songs")
allData = DataFrame(CSV.File("data.csv"))
datasetFilter(allData, yearMin=yearMin, yearMax=yearMax)

println("Building playlist")
playlistIds = getPlaylist(allData, playlist)

if isempty(playlistIds)
    println("Playlist is empty")
    return
end

println("Press Enter to get recommendations")
readline()

println("Getting recommendations")
getPlaylistRecommendations(allData, playlistIds, columnsList, yearMin=yearMin, yearMax=yearMax, count=count, print=true)


