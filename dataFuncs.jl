#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# FUNCTIONS TO BUILD PLAYLIST
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

###################################################################################################
# Procedure:
#     readSongFile
# Parameters:
#     filename -  a file name in the current directory containing songs with artists
# Purpose:
#     A simple regex to get songs and artists to quickly build large playlist.
#     Because we don't have a direct link to Spotify we use this. We can copy and past a playlist into a text document from
#         Spotify and each line is in the general format "songTitle - artistName". We then convert this into a list of simplified
#         song title, artist pairs that we can search for in our dataset.
#     Only returns a single artist for simplification purposes
# Produces:
#     Returns a list of song, artist pairs
# Preconditions
#     filename - a string of a filename in your current working directory with song artist pairs in the format "song - artist"
# Postconditions
#     Returns a list of pairs
#         song title(string)
#         artist name(string)
function readSongFile(filename)
    songReg = r"(?<song>.*)(\s–\s)(?<artist>.*)"
    artistReg = r"(?<artist>.*?)(,|\z)"
    playlist = []
    f = open(filename, "r")
    for line in readlines(f) 
        songMatch = match(songReg, line)
        aritstMatch = match(artistReg, songMatch[:artist])

        push!(playlist, (songMatch[:song], aritstMatch[:artist]))
    end
    close(f)

    return playlist
end


###################################################################################################
# Procedure:
#     readSongFile_WithoutFeat
# Parameters:
#     filename -  a file name in the current directory containing songs with artists
# Purpose:
#     A simple regex to get songs and artists to quickly build large playlist.
#     Because we don't have a direct link to Spotify we use this. We can copy and past a playlist into a text document from
#         Spotify and each line is in the general format "songTitle - artistName". We then convert this into a list of simplified
#         song title, artist pairs that we can search for in our dataset.
#     Only returns a single artist for simplification purposes
#     Excludes specific parts of song titles for simplification
# Produces:
#     Returns a list of song, artist pairs
# Preconditions
#     filename - a string of a filename in your current working directory with song artist pairs in the format "song - artist"
# Postconditions
#     Returns a list of pairs
#         song title(string)
#         artist name(string)
function readSongFile_WithoutFeat(filename)
    splitReg = r"(?<song>.*)(\s–\s)(?<artist>.*)"
    songReg = r"(?<song>.*?)(\s\(feat.*|\z)"
    artistReg = r"(?<artist>.*?)(,|\z)"
    playlist = []
    f = open(filename, "r")
    for line in readlines(f) 
        splitMatch = match(splitReg, line)
        aritstMatch = match(artistReg, splitMatch[:artist])
        songMatch = match(songReg, splitMatch[:song])

        push!(playlist, (songMatch[:song], aritstMatch[:artist]))
    end
    close(f)

    return playlist
end


###################################################################################################
# Procedure:
#     getSongID
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songNameArtistPair - a pair including song title and artist
# Purpose:
#     Retreive the song Id from the dataset for single song
# Produces:
#     Returns a song Id corresponding to the first matching song and artist in the dataset
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songNameArtistPair - a pair
#         song title(string)
#         artist(string)
# Postconditions
#     Returns a string
function getSongID(dataset, songNameArtistPair)
    for i in 1:size(dataset)[1]
        song = dataset[i,:]
        if occursin(lowercase(songNameArtistPair[1]), lowercase(song[13])) && occursin(lowercase(songNameArtistPair[2]), lowercase(song[2]))
            return song[7]
        end
    end
    println("Could not find ", songNameArtistPair[1], " by ", songNameArtistPair[2])
    return "null"
end


###################################################################################################
# Procedure:
#     getPlaylist
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songNameArtistPairs - a list of pairs including song title and artist
# Purpose:
#     Retreive song Ids from the dataset for multiple songs
# Produces:
#     Returns a list of song Ids corresponding to the matching songs and artists in the dataset
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songNameArtistPairs - a list of pairs
#         song title(string)
#         artist(string)
# Postconditions
#     Returns a list of strings
function XgetPlaylist(dataset, songNameArtistPairs)
    IDs = []
    for pair in songNameArtistPairs
        ID = getSongID(dataset, pair)
        if(ID != "null")
            push!(IDs, ID)
        end
    end
    return IDs
end


###################################################################################################
# Procedure:
#     getPlaylist
# Parameters:
#     dataset - the dataset of songs and their attributes
#     songNameArtistPairs - a list of pairs including song title and artist
# Purpose:
#     Retreive song Ids from the dataset for multiple songs
# Produces:
#     Returns a list of song Ids corresponding to the matching songs and artists in the dataset
# Preconditions
#     dataset - a data frame with columns of song attributes and each row represenst an individual song
#     songNameArtistPairs - a list of pairs
#         song title(string)
#         artist(string)
# Postconditions
#     Returns a list of strings
function getPlaylist(dataset, songNameArtistPairs)
    IDs = []
    lowerPairs = []
    for pair in songNameArtistPairs
        push!(lowerPairs, (lowercase(pair[1]), lowercase(pair[2])))
    end

    for i in 1:size(dataset)[1]
        if isempty(songNameArtistPairs)
            break
        end

        song = dataset[i]
        title = lowercase(getproperty(song, 13))
        artist = lowercase(getproperty(song, 2))
        for x in 1:size(lowerPairs)[1]
            pair = lowerPairs[x]
            if occursin(pair[1], title) && occursin(pair[2], artist)
                push!(IDs, song[7])
                deleteat!(lowerPairs, x)
                deleteat!(songNameArtistPairs, x)
                break
            end
        end
    end

    for pair in songNameArtistPairs
        println("Could not find ", pair[1], " by ", pair[2])
    end

    return IDs
end