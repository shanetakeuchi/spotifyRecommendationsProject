#import stuff
using Pkg
Pkg.add("Plots")


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# TESTING FUNCTIONS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

###################################################################################################
# Procedure:
#     randomPercentGenerator
# Parameters:
#     listLength - The size of the list to generate
#     dataLength - The size of the dataset
# Purpose:
#     Generates a sorted list of random percentages to act as a base line when testing our functions.
#     The percentages are generated a set number of times, then it takes the average of them.
# Produces:
#     Returns a list of percents
# Preconditions
#     listLength - an int
#     dataLength - an int
# Postconditions
#     Returns a list of floats sorted smallest to largest
function randomPercentGenerator(listLength, dataLength)
    tries = 50
    randPercentList = fill(0.0, listLength, tries)
    for i in 1:tries
       singleList = []
        while length(singleList) < listLength
            randPercent = rand(1:dataLength)/dataLength * 100
            if !(randPercent in singleList)
                push!(singleList, randPercent)
            end
        end
        sort!(singleList)
        for j in 1:listLength
            randPercentList[j, i] = singleList[j]
        end
    end
    randAverage = []
    for j in 1:listLength
        total = 0.0
        for i in 1:tries
            total += randPercentList[j, i]
        end
        val = total/tries
        push!(randAverage, val)
    end
    return sort!(randAverage)
end


###################################################################################################
# Procedure:
#     tester_Scores
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songList - a list of song Ids corresponding to Spotify's Id's in the dataset
#     columnsList - a list song attribute columns
#     yearMin(optional) - a year, filters out all songs released before yearMin
#     yearMax(optional) - a year, filters out all songs released after yearMax
#     recList(optional) - a list of song Ids corresponding to Spotify's Id's in the dataset used for extra comparison
#     playlistTitle(optional) - the name of the playlist to add to graph titles
# Purpose:
#     Used to test different calculations for determining song score for recommendations by
#         checking the placement of the playlist's songs among the recommendations.
# Produces:
#     Returns nothing.
#     Displays a scatter plot where each dot represents a song from the inputted song
#         list and the y-axis is its placement among the recommendations.
#     A low value on the y-axis means that a song is recommended more. The exact
#         value represents the percent of songs in the dataset that are recommended before that song.
#     Each set of colored dots represents a different method of score calculations.
#     If recList is provided a similar scatter plot is also displayed except the dots represent
#         songs from the recList and their placements among the songList's recommendations.
#     If print is set to true the multiplier values for each case are printed
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songList - a list of strings
#     columnList - a list of ints
#     yearMin(optional) - an int
#     yearMax(optional) - an int
#     recList(optional) - a list of strings
#     playlistTitle(optional) - a string
# Postconditions
#     No Additional
function tester_Scores(dataset, songList, columnsList; yearMin=0, yearMax=0, recList=0, playlistTitle="Playlist")
    # Reduce Data Set
    testingData = datasetFilter(dataset, yearMin=yearMin, yearMax=yearMax)
    dataSize = size(testingData)[1]

    # Build Playlist
    songIndices = getSongIndices(testingData, songList)

    # Build Recommedations
    if recList != 0
        recommedationIndices = getSongIndices(testingData, recList)
    end

    # Generate song attribute dictionary
    attDict = generateAttDict(testingData, songIndices, columnsList)
    attDict = getPlaylistMultipliers_Median(testingData, songIndices, attDict)

    # Generate Graph
    G = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G, testingData, songIndices, attDict)

    # Test Cases
    # Sum of weights
    sortedWeights1 = getScores_TotalWeight(testingData, G, songIndices)
    resultsPlaylist1 = recommendationComparison(testingData, sortedWeights1, songIndices)

    # Median of weights
    sortedWeights2 = getScores_MedianWeight(testingData, G, songIndices)
    resultsPlaylist2 = recommendationComparison(testingData, sortedWeights2, songIndices)

    # Average of weights excluding some percent of the results
    sortedWeights3 = getScores_TrimAverageWeight(testingData, G, songIndices)
    resultsPlaylist3 = recommendationComparison(testingData, sortedWeights3, songIndices)

    pointSize = length(resultsPlaylist1)
    randPercentList = randPercentList = randomPercentGenerator(pointSize, dataSize)

    pointList = fill(0.0, pointSize, 4)
    for i in 1:pointSize
        pointList[i, 1] = randPercentList[i]
        pointList[i, 2] = resultsPlaylist1[i][3]
        pointList[i, 3] = resultsPlaylist2[i][3]
        pointList[i, 4] = resultsPlaylist3[i][3]
    end

    display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of $playlistTitle Songs\nAmong Our Recommendations:\nComparison of Score Calculation Methods", xlabel="Playlist Songs Ordered by Recommendation Ranking", ylabel="Percent Placement\n", label = ["Random" "Sum" "Median" "Trim Average"]))


    if recList != 0
        resultsRecommend1 = recommendationComparison(testingData, sortedWeights1, recommedationIndices)
        resultsRecommend2 = recommendationComparison(testingData, sortedWeights2, recommedationIndices)
        resultsRecommend3 = recommendationComparison(testingData, sortedWeights3, recommedationIndices)

        pointSize = length(resultsRecommend1)
        randPercentList = randPercentList = randomPercentGenerator(pointSize, dataSize)

        pointList = fill(0.0, pointSize, 4)
        for i in 1:pointSize
            pointList[i, 1] = randPercentList[i]
            pointList[i, 2] = resultsRecommend1[i][3]
            pointList[i, 3] = resultsRecommend2[i][3]
            pointList[i, 4] = resultsRecommend3[i][3]
        end

        display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of Spotify's $playlistTitle Recommendations\nAmong Our Recommendations:\nComparison of Score Calculation Methods", xlabel="Spotify Recommendations Songs Ordered by Recommendation Ranking", ylabel="Percent Placement", label = ["Random" "Sum" "Median" "Trim Average"]))
    end

end


###################################################################################################
# Procedure:
#     tester_Multipliers
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songList - a list of song Ids corresponding to Spotify's Id's in the dataset
#     columnsList - a list song attribute columns
#     yearMin(optional) - a year, filters out all songs released before yearMin
#     yearMax(optional) - a year, filters out all songs released after yearMax
#     recList(optional) - a list of song Ids corresponding to Spotify's Id's in the dataset used for extra comparison
#     print(optional) - Whether to print additional information while running
#     playlistTitle(optional) - the name of the playlist to add to graph titles
# Purpose:
#     Used to test different calculations for determining playlist attribute multipliers by
#         checking the placement of the playlist's songs among the recommendations.
# Produces:
#     Returns nothing.
#     Displays a scatter plot where each dot represents a song from the inputted song
#         list and the y-axis is its placement among the recommendations.
#     A low value on the y-axis means that a song is recommended more. The exact
#         value represents the percent of songs in the dataset that are recommended before that song.
#     Each set of colored dots represents a different method of multiplier calculations.
#     If recList is provided a similar scatter plot is also displayed except the dots represent
#         songs from the recList and their placements among the songList's recommendations.
#     If print is set to true the multiplier values for each case are printed
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songList - a list of strings
#     columnList - a list of ints
#     yearMin(optional) - an int
#     yearMax(optional) - an int
#     recList(optional) - a list of strings
#     print(optional) - a boolean
#     playlistTitle(optional) - a string
# Postconditions
#     No Additional
function tester_Multipliers(dataset, songList, columnsList; yearMin=0, yearMax=0, recList=0, print=false, playlistTitle="Playlist")
    # Reduce Data Set
    testingData = datasetFilter(dataset, yearMin=yearMin, yearMax=yearMax)
    dataSize = size(testingData)[1]

    # Build Playlist
    songIndices = getSongIndices(testingData, songList)

    # Build Recommedations
    if recList != 0
        recommedationIndices = getSongIndices(testingData, recList)
    end

    # Generate song attribute dictionary
    attDict = generateAttDict(testingData, songIndices, columnsList)

    # Test Cases

    # No multipliers
    attDictNull = copy(attDict)
    for key in keys(attDictNull)
        attDictNull[key]["multiplier"] = 1
    end
    GNull = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(GNull, testingData, songIndices, attDictNull)
    sortedWeightsNull = getScores_TotalWeight(testingData, GNull, songIndices)
    resultsPlaylistNull = recommendationComparison(testingData, sortedWeightsNull, songIndices)

    if print
        println("Null")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDictNull[att]["multiplier"])")
        end
    end

    # Median difference multiplier
    attDict1 = copy(attDict)
    attDict1 = getPlaylistMultipliers_Median(testingData, songIndices, attDict1)
    G1 = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G1, testingData, songIndices, attDict1)
    sortedWeights1 = getScores_TotalWeight(testingData, G1, songIndices)
    resultsPlaylist1 = recommendationComparison(testingData, sortedWeights1, songIndices)

    if print
        println("Median")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDict1[att]["multiplier"])")
        end
    end

    # Average difference multiplier
    attDict2 = copy(attDict)
    attDict2 = getPlaylistMultipliers_Average(testingData, songIndices, attDict2)
    G2 = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G2, testingData, songIndices, attDict2)
    sortedWeights2 = getScores_TotalWeight(testingData, G2, songIndices)
    resultsPlaylist2 = recommendationComparison(testingData, sortedWeights2, songIndices)

    if print
        println("Average")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDict2[att]["multiplier"])")
        end
    end

    # Max difference multiplier
    attDict3 = copy(attDict)
    attDict3 = getPlaylistMultipliers_MaxRange(testingData, songIndices, attDict3)
    G3 = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G3, testingData, songIndices, attDict3)
    sortedWeights3 = getScores_TotalWeight(testingData, G3, songIndices)
    resultsPlaylist3 = recommendationComparison(testingData, sortedWeights3, songIndices)

    if print
        println("Max")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDict3[att]["multiplier"])")
        end
    end

    # Min difference multiplier
    attDict4 = copy(attDict)
    attDict4 = getPlaylistMultipliers_MinRange(testingData, songIndices, attDict4)
    G4 = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G4, testingData, songIndices, attDict4)
    sortedWeights4 = getScores_TotalWeight(testingData, G4, songIndices)
    resultsPlaylist4 = recommendationComparison(testingData, sortedWeights4, songIndices)

    if print
        println("Min")
        for att in columnsList
                println("   $(names(testingData)[att]): $(attDict4[att]["multiplier"])")
        end
    end

    # Random Song Recommendations
    pointSize = length(resultsPlaylist1)
    randPercentList = randPercentList = randomPercentGenerator(pointSize, dataSize)

    pointList = fill(0.0, pointSize, 6)
    for i in 1:pointSize
        pointList[i, 1] = randPercentList[i]
        pointList[i, 2] = resultsPlaylistNull[i][3]
        pointList[i, 3] = resultsPlaylist1[i][3]
        pointList[i, 4] = resultsPlaylist2[i][3]
        pointList[i, 5] = resultsPlaylist3[i][3]
        pointList[i, 6] = resultsPlaylist4[i][3]
    end

    display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of $playlistTitle Songs\nAmong Our Recommendations:\nComparison of Multiplier Calculation Methods", xlabel="Playlist Songs Ordered by Recommendation Ranking", ylabel="Percent Placement\n", label = ["Random" "No Playlist Multipliers" "Median" "Average" "Max in Range" "Min in Range"]))


    if recList != 0
        resultsPlaylistNull = recommendationComparison(testingData, sortedWeightsNull, recommedationIndices)
        resultsRecommend1 = recommendationComparison(testingData, sortedWeights1, recommedationIndices)
        resultsRecommend2 = recommendationComparison(testingData, sortedWeights2, recommedationIndices)
        resultsRecommend3 = recommendationComparison(testingData, sortedWeights3, recommedationIndices)
        resultsRecommend4 = recommendationComparison(testingData, sortedWeights4, recommedationIndices)
        pointSize = length(resultsRecommend1)
        randPercentList = randomPercentGenerator(pointSize, dataSize)

        pointList = fill(0.0, pointSize, 6)
        for i in 1:pointSize
            pointList[i, 1] = randPercentList[i]
            pointList[i, 2] = resultsPlaylistNull[i][3]
            pointList[i, 3] = resultsRecommend1[i][3]
            pointList[i, 4] = resultsRecommend2[i][3]
            pointList[i, 5] = resultsRecommend3[i][3]
            pointList[i, 6] = resultsRecommend4[i][3]
        end

        display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of Spotify's $playlistTitle Recommendations\nAmong Our Recommendations:\nComparison of Multiplier Calculation Methods", ylabel="Percent Placement", xlabel="Spotify Recommendations Songs Ordered by Recommendation Ranking", label = ["Random" "No Playlist Multipliers" "Median" "Average" "Max in Range" "Min in Range"]))
    end

end

###################################################################################################
# Procedure:
#     tester_Simplified
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songList - a list of song Ids corresponding to Spotify's Id's in the dataset
#     columnsList - a list song attribute columns
#     yearMin(optional) - a year, filters out all songs released before yearMin
#     yearMax(optional) - a year, filters out all songs released after yearMax
#     recList(optional) - a list of song Ids corresponding to Spotify's Id's in the dataset used for extra comparison
#     playlistTitle(optional) - the name of the playlist to add to graph titles
# Purpose:
#     Used to test the base version of our song recommender by checking the placement of the playlist's songs among the recommendations.
# Produces:
#     Returns nothing.
#     Displays a scatter plot where each dot represents a song from the inputted song
#         list and the y-axis is its placement among the recommendations.
#     A low value on the y-axis means that a song is recommended more. The exact
#         value represents the percent of songs in the dataset that are recommended before that song.
#     If recList is provided a similar scatter plot is also displayed except the dots represent
#         songs from the recList and their placements among the songList's recommendations.
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songList - a list of strings
#     columnList - a list of ints
#     yearMin(optional) - an int
#     yearMax(optional) - an int
#     recList(optional) - a list of strings
#     playlistTitle(optional) - a string
# Postconditions
#     No Additional
function tester_Simplified(dataset, songList, columnsList; yearMin=0, yearMax=0, recList=0, playlistTitle="Playlist Title")
    # Reduce Data Set
    testingData = datasetFilter(dataset, yearMin=yearMin, yearMax=yearMax)
    dataSize = size(testingData)[1]

    # Build Playlist
    songIndices = getSongIndices(testingData, songList)

    # Build Recommedations
    if recList != 0
        recommedationIndices = getSongIndices(testingData, recList)
    end

    # Generate song attribute dictionary
    attDict = generateAttDict(testingData, songIndices, columnsList)
    attDict = getPlaylistMultipliers_Median(testingData, songIndices, attDict)
    G = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G, testingData, songIndices, attDict)
    sortedWeights = getScores_TotalWeight(testingData, G, songIndices)
    resultsPlaylist = recommendationComparison(testingData, sortedWeights, songIndices)

    # Random Song Recommendations
    pointSize = length(resultsPlaylist)
    randPercentList = randPercentList = randomPercentGenerator(pointSize, dataSize)

    pointList = fill(0.0, pointSize, 2)
    for i in 1:pointSize
        pointList[i, 1] = randPercentList[i]
        pointList[i, 2] = resultsPlaylist[i][3]
    end

    display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of $playlistTitle Songs\nAmong Our Recommendations", xlabel="Playlist Songs Ordered by Recommendation Ranking", ylabel="Percent Placement\n", label = ["Random" "Playlist Recommendations"]))


    if recList != 0
        resultsRecommend = recommendationComparison(testingData, sortedWeights, recommedationIndices)
        pointSize = length(resultsRecommend)
        randPercentList = randomPercentGenerator(pointSize, dataSize)

        pointList = fill(0.0, pointSize, 2)
        for i in 1:pointSize
            pointList[i, 1] = randPercentList[i]
            pointList[i, 2] = resultsRecommend[i][3]
        end

        display(plot(1:pointSize, pointList, seriestype = :scatter, legend = :topleft, title = "Placement of Spotify's $playlistTitle Recommendations\nAmong Our Recommendations", ylabel="Percent Placement", xlabel="Spotify Recommendations Songs Ordered by Recommendation Ranking", label = ["Random" "Playlist Recommendations"]))
    end

end


###################################################################################################
# Procedure:
#     tester_Recommendations
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songList - a list of song Ids corresponding to Spotify's Id's in the dataset
#     columnsList - a list song attribute columns
#     yearMin(optional) - A year, filters out all songs released before yearMin
#     yearMax(optional) - A year, filters out all songs released after yearMax
#     count(optional) - The number of recommendations to print out
#     print(optional) - Whether to print additional information while running
# Purpose:
#     Used to test the base version of our song recommender and check recommendations.
# Produces:
#     Returns nothing.
#     Prints out the top recommendations for the given playlist.
#     Prints information about the inputted playlist is print is set to true
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songList - a list of strings
#     columnList - a list of ints
#     yearMin(optional) - an int
#     yearMax(optional) - an int
#     count(optional) - an int
#     print(optional) - a boolean
# Postconditions
#     No Additional
function getPlaylistRecommendations(dataset, songList, columnsList; yearMin=0, yearMax=0, count=10, print=false)
    # Reduce Data Set
    testingData = datasetFilter(dataset, yearMin=yearMin, yearMax=yearMax)
    dataSize = size(testingData)[1]

    # Build Playlist
    songIndices = getSongIndices(testingData, songList)

    # Print playlist
    if print
        println("#####################       Playlist        #####################")
        printSongIndices(testingData, songIndices, columnsList = columnsList)
    end

    # Generate song attribute dictionary
    attDict = generateAttDict(testingData, songIndices, columnsList)
    attDict = getPlaylistMultipliers_Median(testingData, songIndices, attDict)

    # Print playlist value ranges and multipliers
    if print
        println("#####################    Values Ranges      #####################")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDict[att]["range"])")
        end
        println("#####################     Mulitpliers      ##################### ")
        for att in columnsList
            println("   $(names(testingData)[att]): $(attDict[att]["multiplier"])")
        end
    end

    # Generate Graph
    G = SimpleWeightedGraph(size(testingData)[1])
    addEdges_Playlist(G, testingData, songIndices, attDict)

    # Get Recommendations
    sortedWeights = getScores_TrimAverageWeight(testingData, G, songIndices)

    println("#####################    Recommendations    #####################")
    printTopRecommendations(testingData, sortedWeights, count)

end