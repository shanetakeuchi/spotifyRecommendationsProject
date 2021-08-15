#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# PRINT FUNCTIONS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

###################################################################################################
# Procedure:
#     printSongIndices
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songIndices - a list of song indices in the dataset
#     columnsList(optional) - a list of additional attribute columns to print out
# Purpose:
#     Prints Song information for a list of song indices in data
# Produces:
#     Prints out song title, song artist, song index, and any other specified attribute columns
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songIndices - a list of ints where each int is in the range 1 to number of songs in the dataset
#     columnsList - a list of ints in the range 1 to 19
# Postconditions
#     No Additional
function printSongIndices(dataset, songIndices; columnsList=0)
    for songIndex in songIndices
        song = dataset[songIndex,:] 
        println("Song:   $(song[13])")
        println("Artist: $(song[2])")
        println("Index:  $songIndex")

        # names = propertynames(dataset)
        for col in columnsList
            println("   $(names(dataset)[col]): $(song[col])")
        end
        println("-----------------------------------------------------------------")
    end
end


###################################################################################################
# Procedure:
#     printTopRecommendations
# Parameters:
#     dataset - the dataset of songs and their attributes
#     sortedScores - a list of song indices in the order that they are recommended
#     count - the number of recommendations to be printed
# Purpose:
#     Prints song information for top song recommendations
# Produces:
#     Prints out song title, song artist, song year, and song Id
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     sortedScores - a list of pairs
#                     song index(int)
#                     total score(float)
#     count - an int in the range 1 to the size of sortedScores
# Postconditions
#     No Additional
function printTopRecommendations(dataset, sortedScores, count)
    for i in 1:count
        index = sortedScores[i][1]
        println("Artist:   $(dataset[index, 2])")
        println("Song:     $(dataset[index, 13])")
        println("Year:     $(dataset[index, 19])")
        println("Id:       $(dataset[index, 7])")
        println("-----------------------------------------------------------------")
    end
end


###################################################################################################
# Procedure:
#     printSong
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songName - the song's title
# Purpose:
#     Prints Song information for songs in the dataset that contain the specified song name.
# Produces:
#     Prints out song title, song artist, song year, song index, and song Id
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songName - a string
# Postconditions
#     No Additional
function printSong(dataset, songName)
    for i in 1:size(dataset)[1]
        song = dataset[i,:]
        if occursin(lowercase(songName), lowercase(getproperty(song, 13)))
            println("############################################")
            println("Artist:   $(dataset[index, 2])")
            println("Song:     $(dataset[index, 13])")
            println("Year:     $(dataset[index, 19])")
            println("Id:       $(dataset[index, 7])")
            println("Index:    $i")
            println("############################################")
        end
    end
end


###################################################################################################
# Procedure:
#     printRecommendationPositions
# Parameters:
#     dataset - the dataset of songs and their attributes
#     result - a list of 3-tuples containing song index, recommendation rank, and recommendation percentage
# Purpose:
#     Prints Song information for specific songs and their recommendation placements
# Produces:
#     Prints out song title, song artist, song index, song recommendation rank, and song recommendation percentage
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     result - a list of 3-tuples containing:
#         an int in the range 1 to the size of the dataset
#         an int in the range 1 to the size of the dataset
#         a float
# Postconditions
#     No Additional
function printRecommendationPositions(dataset, result)
    println("##################### Results       #####################")
    for set in result
        println("Artist:   $(dataset[set[1], 2]))")
        println("Song:     $(dataset[set[1], 13]))")
        println("Index:    $(set[1])")
        println("Position: $(set[2])")
        println("Percent:  $(set[3])%")
    end
end