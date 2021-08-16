using CSV
using DataFrames

include("./playlists.jl")
include("./printFuncs.jl")
include("./dataFuncs.jl")
include("./keyFuncs.jl")
include("./testingFuncs.jl")



println("This test is to measure the quality of our recommendations.")

println("Press Enter to run 90's Rock Anthems test")
readline()
allData = DataFrame(CSV.File("data.csv"))
columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]
@time playlistTest(allData, rockAnthems, rockAnthemsRec, columnsList, "90's Rock Anthems", 1993, 1996)

println("Press Enter to run Classical Essentials test")
readline()
allData = DataFrame(CSV.File("data.csv"))
columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]
@time playlistTest(allData, classicalEssentials, classicalEssentialsRec, columnsList, "Classical Essentials", 1998, 2003)

println("Press Enter to run Teen Beats test")
readline()
allData = DataFrame(CSV.File("data.csv"))
columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]
@time playlistTest(allData, teenBeats, teenBeatsRec, columnsList, "Teen Beats", 2015, 2020)

println("Press Enter to run Mood Booster test")
readline()
allData = DataFrame(CSV.File("data.csv"))
columnsList = [1, 3, 5, 8, 10, 11, 16, 17, 18]
@time playlistTest(allData, moodBooster, moodBoosterRec, columnsList, "Mood Booster", 2015, 2020)

println("Press Enter to close tests")
readline()