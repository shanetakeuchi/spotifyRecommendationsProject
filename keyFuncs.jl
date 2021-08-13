using Pkg
Pkg.add("LightGraphs");
# Pkg.add("SimpleWeightedGraphs");
# using SimpleWeightedGraphs
using LightGraphs


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# KEY FUNCTIONS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

###################################################################################################
# Procedure:
#     datasetFilter
# Parameters:
#     dataset - the dataset of songs and their attributes
#     yearMin(optional) - remove all songs released before this year
#     yearMax(optional) - remove all songs released after this year
# Purpose:
#     Filters out songs from the dataset to improve runtimes
# Produces:
#     Returns a data set with songs filtered out by specified year cutoffs
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     yearMin(optional) - an int
#     yearMax(optional) - an int
# Postconditions
#     Returns a ...
#     If no filters are specified it returns a copy of the dataset
function datasetFilter(dataset; yearMin=0, yearMax=0)

    if yearMin != 0
        filter(x -> (getproperty(x, 19) >= yearMin),  dataset)
    end

     if yearMax != 0
        filter(x -> (getproperty(x, 19) <= yearMax),  dataset)
    end

end


###################################################################################################
# Procedure:
#     getSongIndices
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songList - a list of spotify song IDs
# Purpose:
#     Locates songs within the dataset based on their Spotify song Id
# Produces:
#     Returns a list of song indices within the dataset
#     If a song Id is not found in the dataset, it prints out the Id that was not found
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songList - a list of strings
# Postconditions
#     Returns a list of ints in the range 1 to the size of the dataset
function getSongIndices(dataset, songList)
    tmpList = copy(songList)
    songIndices = []
    for i in 1:size(dataset)[1]
        if isempty(tmpList)
            break
        end

        curSong = dataset[i]
        curId = getproperty(curSong, 7)
        for x in 1:size(tmpList)[1]
            songId = tmpList[x]
            if curId == songId
                push!(songIndices, i)
                deleteat!(tmpList, x)
                break
            end
        end
    end

    for id in tmpList
        # Can be used to alert user of when an Id is wrong or if a filtered dataset is excluding some songs.
#             error("Song ID not found in dataset: $id")
#             println("Song ID not found in dataset: $id")
    end
  
    return songIndices
end


###################################################################################################
# Procedure:
#     generateAttDict
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     columnsList - a list song attribute columns
# Purpose:
#     Creates a dictionary containing the ranges of each song attribute to be considered
# Produces:
#     Returns a dictionary with attribute columns as keys and values of dictionarys containing the range of the attribute
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     columnsList - a list ints in the range 1 to 19
# Postconditions
#     Returns a dictionary of dictionaries for each attribute
#         The outer dictionary's keys are column numbers(ints) with dictionary values
#         The inner dictionary's key is "range" with float values
function generateAttDict(dataset, songIndices, columnsList)
    attDict = Dict()
    for att in columnsList
        attDict[att] = Dict()
        attDict[att]["max"] = getproperty(dataset[1], att)
        attDict[att]["min"] = getproperty(dataset[1], att)
    end

    for song in dataset
        for att in columnsList
            newVal = getproperty(song, att)
            if newVal > attDict[att]["max"]
                attDict[att]["max"] = newVal
            elseif newVal < attDict[att]["min"]
                attDict[att]["min"] = newVal
            end
        end
    end

    for att in columnsList
        attDict[att]["range"] = attDict[att]["max"] - attDict[att]["min"]
    end
    return attDict
end


###################################################################################################
# Procedure:
#     recommendationComparison
# Parameters:
#     dataset - the dataset of songs and their attributes
#     sortedScores - a list of song indices in the order that they are recommended
#     compareIndices - a list of song indices in the dataset to return results for
# Purpose:
#     Checks where songs in compareIndices are recommended
# Produces:
#     Returns a list of 3-tuples of song index, recommendation rank, and recommendation percentage
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     sortedScores - a list of pairs
#                     song index(int)
#                     total score(float)
#     compareIndices - a list of ints in the range 1 to the size of the dataset
# Postconditions
#     Returns a list of 3-tuples
#         song index(int) in the range 1 to the size of the dataset
#         recommendation rank(int) in the range 1 to the size of the dataset
#         recommendation percentage(float) between in the range 0 to 100
function recommendationComparison(dataset, sortedScores, compareIndices)
    compareCount = length(compareIndices)
    positionList = []
    rank = 1
    dataLength = size(dataset)[1]
    for rank in 1:dataLength
        index = sortedScores[rank][1]
        if index in compareIndices
            compareCount = compareCount - 1
            percent = (rank/dataLength) * 100
            push!(positionList, (index, rank, percent))
        end
        if compareCount == 0
            break
        end
    end
    return positionList
end

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# FUNCTIONS TO MODIFY
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

###################################################################################################
# Procedure:
#     getPlaylistMultipliers_MaxRange
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     attDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Calculates a multiplier for each attribute and adds a multiplier key to the inner dictionary
#     Version: Chooses the multiplier to be 1 minus the largest value in the list of attribute differences between songs in the songIndices
# Produces:
#     Returns a dictionary with attribute columns as keys and values of dictionarys containing the range and multiplier of the attribute
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     attDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     Returns a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's keys are "range" and "multiplier" with float values
function getPlaylistMultipliers_MaxRange(dataset, songIndices, attDict)
    numSongs = length(songIndices)
    # For each attribute
    for key in keys(attDict)
        if numSongs == 1
            attDict[key]["multiplier"] =  1
        else
            values = []
            # For each unique pair of songs
            for i in 1:numSongs
                index1 = songIndices[i]
                for j in i+1:numSongs
                    index2 = songIndices[j]
                    # Calculate the difference in attribute values
                    push!(values, abs(getproperty(dataset[index1], key) - getproperty(dataset[index2], key)))
                end
            end
            # Take the average of the differences and calculate its percent of the attributes range
            # Subtract that percent from 1 to get the multiplier
            maxDif = maximum(values)
            percentVal = maxDif/attDict[key]["range"]
            attDict[key]["multiplier"] = 1 - percentVal
        end
    end
    return attDict
end


###################################################################################################
# Procedure:
#     getPlaylistMultipliers_MinRange
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     attDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Calculates a multiplier for each attribute and adds a multiplier key to the inner dictionary
#     Version: Chooses the multiplier to be 1 minus the smallest value in the list of attribute differences between songs in the songIndices
# Produces:
#     Returns a dictionary with attribute columns as keys and values of dictionarys containing the range and multiplier of the attribute
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     attDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     Returns a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's keys are "range" and "multiplier" with float values
function getPlaylistMultipliers_MinRange(dataset, songIndices, attDict)
    numSongs = length(songIndices)
    # For each attribute
    for key in keys(attDict)
        if numSongs == 1
            attDict[key]["multiplier"] =  1
        else
            values = []
            # For each unique pair of songs
            for i in 1:numSongs
                index1 = songIndices[i]
                for j in i+1:numSongs
                    index2 = songIndices[j]
                    # Calculate the difference in attribute values
                    push!(values, abs(getproperty(dataset[index1], key) - getproperty(dataset[index2], key)))
                end
            end
            # Take the average of the differences and calculate its percent of the attributes range
            # Subtract that percent from 1 to get the multiplier
            minDif = minimum(values)
            percentVal = minDif/attDict[key]["range"]
            attDict[key]["multiplier"] = 1 - percentVal
        end
    end
    return attDict
end


###################################################################################################
# Procedure:
#     getPlaylistMultipliers_Average
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     attDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Calculates a multiplier for each attribute and adds a multiplier key to the inner dictionary
#     Version: Chooses the multiplier to be 1 minus the average value in the list of attribute differences between songs in the songIndices
# Produces:
#     Returns a dictionary with attribute columns as keys and values of dictionarys containing the range and multiplier of the attribute
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     attDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     Returns a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's keys are "range" and "multiplier" with float values
function getPlaylistMultipliers_Average(dataset, songIndices, attDict)
    numSongs = length(songIndices)
    # For each attribute
    for key in keys(attDict)
        if numSongs == 1
            attDict[key]["multiplier"] =  1
        else
            values = []
            # For each unique pair of songs
            for i in 1:numSongs
                index1 = songIndices[i]
                for j in i+1:numSongs
                    index2 = songIndices[j]
                    # Calculate the difference in attribute values
                    push!(values, abs(getproperty(dataset[index1], key) - getproperty(dataset[index2], key)))
                end
            end
            # Take the average of the differences and calculate its percent of the attributes range
            # Subtract that percent from 1 to get the multiplier
            averageDif = sum(values)/length(values)
            percentVal = averageDif/attDict[key]["range"]
            attDict[key]["multiplier"] = 1 - percentVal
        end
    end
    return attDict
end


###################################################################################################
# Procedure:
#     getPlaylistMultipliers_Average
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     attDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Calculates a multiplier for each attribute and adds a multiplier key to the inner dictionary
#     Version: Chooses the multiplier to be 1 minus the median value in the list of attribute differences between songs in the songIndices
# Produces:
#     Returns a dictionary with attribute columns as keys and values of dictionarys containing the range and multiplier of the attribute
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     attDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     Returns a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's keys are "range" and "multiplier" with float values
function getPlaylistMultipliers_Median(dataset, songIndices, attDict)
    numSongs = length(songIndices)
    # For each attribute
    for key in keys(attDict)
        if numSongs == 1
            attDict[key]["multiplier"] =  1
        else
            values = []
            # For each unique pair of songs
            for i in 1:numSongs
                index1 = songIndices[i]
                for j in i+1:numSongs
                    index2 = songIndices[j]
                    # Calculate the difference in attribute values
                    push!(values, abs(getproperty(dataset[index1], key) - getproperty(dataset[index2], key)))
                end
            end
            # Take the median of the differences and calculate its percent of the attributes range
            # Subtract that percent from 1 to get the multiplier
            attDict[key]["multiplier"] = (1 - (median(values)/attDict[key]["range"]))
        end
    end
    return attDict
end


###################################################################################################
# Procedure:
#     addEdges_Complete
# Parameters:
#     graph - a simple weighted graph
#     dataset - the dataset of songs and their attributes
#     columnsDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Creates edges between every pair of songs in the dataset.
#     Edge weights are the sum of the differences in specified attributes with the multiplier applied to each attributes difference.
# Produces:
#     Nothing
# Preconditions
#     graph - no additional
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     columnsDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     The graph now has weighted edges between each node
function addEdges_Complete(graph, dataset, columnsDict)
    numSongs = size(dataset)[1]
    if numSongs == 1
        return
    end
    for i in 1:numSongs
        for j in i+1:numSongs
            weight = 0
            for att in keys(columnsDict)
                dif = abs(getproperty(dataset[i], att) - getproperty(dataset[j], att))
                attWeight = (dif / columnsDict[att]["range"]) * columnsDict[att]["multiplier"]
                weight += attWeight
            end
            add_edge!(graph, i, j, weight)
        end
    end
end


###################################################################################################
# Procedure:
#     addEdges_Playlist
# Parameters:
#     graph - a simple weighted graph
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     columnsDict - a dict of song attribute with attribute column keys, and dictionary values
# Purpose:
#     Creates edges between every pair of songs in the dataset that contain at least one song from the songIndices list.
#     Edge weights are the sum of the differences in specified attributes with the multiplier applied to each attributes difference.
# Produces:
#     Nothing
# Preconditions
#     graph - no additional
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints in the range 1 to the size of the dataset
#     columnsDict - a dict of dictionaries for each attribute
#               The outer dictionary's keys are column numbers(ints) with dictionary values
#               The inner dictionary's key is "range" with a float value
# Postconditions
#     The graph now has every possible weighted edge that contains at least one song in songIndices
function addEdges_Playlist(graph, dataset, songIndices, columnsDict)
    numSongs = size(dataset)[1]
    if numSongs == 1
        return
    end
    for i in songIndices
        for j in 1:numSongs
            if i == j
                continue
            end
            weight = 0
            for att in keys(columnsDict)
                dif = abs(getproperty(dataset[i], att) - getproperty(dataset[j], att))
                attWeight = (dif / columnsDict[att]["range"]) * columnsDict[att]["multiplier"]
                weight += attWeight
            end
            add_edge!(graph, i, j, weight)
        end
    end
end


###################################################################################################
# Procedure:
#     getScores_TotalWeight
# Parameters:
#     dataset - the dataset of songs and their attributes
#     graph - a simple weighted graph
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Purpose:
#     Creates a list of song indices sorted by the overall score values
#     Version: The overall score value for a song is the sum of the edge weights for each edge to a song in the songIndices
# Produces:
#     Returns a list of song index and score pairs, sorted from smallest to largest score
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     graph - no additional
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Postconditions
#     Returns a list of pairs sorted by smallest overall weight to largest
#         a song index(int) in the range 1 to the size of the dataset
#         a overall score(float)
function getScores_TotalWeight(dataset, graph, songIndices)

    songDict = Dict()
    for i in 1:nv(graph)
        songDict[i] = 0
        for song in songIndices
            if i == song
                continue
            end
            songDict[i] += graph.weights[song, i]
        end
    end

    sortedScores = sort(collect(songDict), by=x->x[2])

    return sortedScores
end


###################################################################################################
# Procedure:
#     getScores_MedianWeight
# Parameters:
#     dataset - the dataset of songs and their attributes
#     graph - a simple weighted graph
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Purpose:
#     Creates a list of song indices sorted by the overall score values
#     Version: The overall score value for a song is the median of the edge weights for each edge to a song in the songIndices
# Produces:
#     Returns a list of song index and score pairs, sorted from smallest to largest score
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     graph - no additional
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Postconditions
#     Returns a list of pairs sorted by smallest overall weight to largest
#         a song index(int) in the range 1 to the size of the dataset
#         a overall score(float)
function getScores_MedianWeight(dataset, graph, songIndices)

    songDict = Dict()
    for i in 1:nv(graph)
        songDict[i] = []
        for song in songIndices
            if i == song
                continue
            end
            push!(songDict[i], graph.weights[song, i])
        end

        songDict[i] = median(songDict[i])

    end

    sortedScores = sort(collect(songDict), by=x->x[2])

    return sortedScores
end


###################################################################################################
# Procedure:
#     getScores_TrimAverageWeight
# Parameters:
#     dataset - the dataset of songs and their attributes
#     graph - a simple weighted graph
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Purpose:
#     Creates a list of song indices sorted by the overall scores values
#     Version: The overall score value for a song is the average of the edge weights for each edge to a song in the songIndices
#              Excludes at most 20% of the edge weights in the average calculation (floor(playlistSize/10))
# Produces:
#     Returns a list of song index and score pairs, sorted from smallest to largest score
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     graph - no additional
#     songIndices - a list of ints in the range 1 to the size of the dataset
# Postconditions
#     Returns a list of pairs sorted by smallest overall weight to largest
#         a song index(int) in the range 1 to the size of the dataset
#         a overall score(float)
function getScores_TrimAverageWeight(dataset, graph, songIndices)
    playlistSize = length(songIndices)

    cutPercent = 20
    cutoff = cutPercent/2
    cutCount = Int(floor(playlistSize/cutoff))

    # if cutCount >= playlistSize
    #     cutCount = playlistSize-1

    songDict = Dict()
    for i in 1:nv(graph)
        weightList = []
        for song in songIndices
            if i == song
                continue
            end
            push!(weightList, graph.weights[song, i])
        end
        sort!(weightList)

        weightList = weightList[(1+cutCount):(length(weightList)-cutCount)]

        songDict[i] = sum(weightList)
    end

    sortedScores = sort(collect(songDict), by=x->x[2])
 
    return sortedScores
end