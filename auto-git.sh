#!/bin/bash

function exit_exception () {
        if [ $? -eq 127 ]; then
        echo "Exiting..."
        exit 153

        fi
}

function switch_branch (){

selected=$(git branch | fzf +m \
        --height 40% \
        --layout reverse \
        --border \
        --preview \
	'git log --oneline $(echo {} | tr -d "* ")'  \
        --color bg:#222222,preview-bg:#333333)

exit_exception

selected=$(echo $selected | tr -d "* ")

git switch "$selected"
}

function merge (){

selected=$(git branch | fzf +m \
        --height 100% \
        --layout reverse \
        --border \
        --preview \
	'git diff $(git branch | grep "^*" | tr -d "* ") $(echo {} | tr -d "* ")'  \
        --color bg:#222222,preview-bg:#333333)

exit_exception

selected=$(echo $selected | tr -d "* ")

git switch "$selected"
}
merge
