#!/bin/bash

path=$1
hash=$2
echo "Path: $path"
echo "Hash: $hash"
filename=$(basename "$path")
echo "Filename: $filename"

# Regex pattern to match the filename
pattern='\[([A-Za-z0-9 &-]+)\]([^\[]+)((\[[A-Za-z0-9 -]+\])+)\.([A-Za-z0-9]+)'

# Check if the filename matches the regex pattern
if [[ "$filename" =~ $pattern ]]; then
    echo "Filename matches pattern"

    # Extract the relevant information from the filename
    translation_team="${BASH_REMATCH[1]}"
    show_name="${BASH_REMATCH[2]}"
    meta="${BASH_REMATCH[3]}"
    format="${BASH_REMATCH[5]}"

    # trim whitespace from meta
    meta=$(echo "$meta" | xargs)
    # replace ][ with a space
    meta=${meta//][/\ }
    # replace [ or ] with nothing
    meta=${meta//[\[\]]/}

    # show name is something like "show name S01 - 01" or "show name - 01"
    # extract show name and the season and episode number using regex
    show_name_pattern='(.+) S([0-9]+) - ([0-9]+)'
    if [[ "$show_name" =~ $show_name_pattern ]]; then
        echo "Show name matches pattern"
        show_name="${BASH_REMATCH[1]}"
        season="${BASH_REMATCH[2]}"
        episode="${BASH_REMATCH[3]}"
    else
        show_name_pattern='(.+) - ([0-9]+)'
        if [[ "$show_name" =~ $show_name_pattern ]]; then
            echo "Show name matches pattern"
            show_name="${BASH_REMATCH[1]}"
            season="01"
            episode="${BASH_REMATCH[2]}"
        else
            echo "Show name does not match pattern"
            exit 1
        fi
    fi

    # trim whitespace from the show name
    show_name=$(echo "$show_name" | xargs)

    echo "Show name: $show_name"
    echo "Season: $season"
    echo "Episode: $episode"

    # Construct the new filename
    new_filename="${show_name} S${season}E${episode} ${meta}.${format}"
    echo "Renaming $filename to $new_filename"

    # get the directory of the file
    root_dir=$(dirname "$path")
    echo "Directory: $root_dir"
    
    # make show name lowercase and assign to sub dir name, remove any special characters and replace spaces with underscores
    sub_dir=$(echo "$show_name" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] ' | tr ' ' '_')
    echo "new Show name: $sub_dir"

    # Create the directory if it doesn't already exist, maybe unnecessary
    show_dir="$root_dir/$sub_dir"
    if [ ! -d "$show_dir" ]; then
        echo "Directory $show_dir does not exist"
        mkdir "$show_dir"
        echo "Created directory $show_dir"
    fi
    echo "Directory $show_dir exists"
    
    path=$(basename "$path")

    # use qbittorrent web api to rename the file, in order to keep seeding
    # make a POST request to http://localhost:6363/api/v2/torrents/renameFile with url encoded data: hash oldPath newPath閿涘疅et response from server
    curl -X POST -d "hash=$hash&oldPath=$path&newPath=$sub_dir/$new_filename" http://localhost:6363/api/v2/torrents/renameFile
fi
