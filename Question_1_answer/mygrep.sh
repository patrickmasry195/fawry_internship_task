#!/bin/bash

show_help() {
    echo "Usage: $0 [OPTIONS] SEARCH_STRING FILE"
    echo ""
    echo "OPTIONS:"
    echo "  -n          Show line numbers"
    echo "  -v          Invert match (show non-matching lines)"
    echo "  --help      Show this help message"
}

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi

show_line_numbers=false
invert_match=false

if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

while getopts ":nv" opt; do
    case $opt in
    n) show_line_numbers=true ;;
    v) invert_match=true ;;
    \?)
        echo "Invalid option: -$OPTARG"
        show_help
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

search_string="$1"
file="$2"

if [ -z "$search_string" ] || [ -z "$file" ]; then
    echo "Error: Missing search string or file."
    show_help
    exit 1
fi

if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

line_number=0
while IFS= read -r line; do
    ((line_number++))
    match=$(echo "$line" | grep -i "$search_string")

    if $invert_match; then
        if [ -z "$match" ]; then
            if $show_line_numbers; then
                echo "${line_number}:$line"
            else
                echo "$line"
            fi
        fi
    else
        if [ -n "$match" ]; then
            if $show_line_numbers; then
                echo "${line_number}:$line"
            else
                echo "$line"
            fi
        fi
    fi
done <"$file"
