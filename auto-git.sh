#!/bin/bash

selected=$(git branch | fzf +m \
	--height 40% \
	--layout reverse \
	--border \
	--preview \
		'git log --oneline $(echo {} | tr -d "* ")' \
	--color bg:#222222,preview-bg:#333333)



if [ $? -eq 130 ]; then
	echo "Exiting..."
	exit 1
fi



selected=$(echo $selected | tr -d "* ")

echo "$selected"

git switch "$selected"

function exit_exception () {
        if [ $? -eq 130 ]; then
        echo "Exiting..."
        exit 1

        fi
}

function switch_branch (){

	selected=$(git branch | fzf +m \
        --height 40% \
        --layout reverse \
        --border\
        --preview\
				'git -c color.ui=always --oneline $(echo {} | tr -d "* ")'  \
        --color bg:#222222,preview-bg:#333333)

	exit_exception

	selected=$(echo $selected | tr -d "* ")

	git switch "$selected"
}

function merge (){

	selected=$(git branch | fzf +m \
        --height 100%\
        --layout reverse\
        --border\
        --preview\
	'git -c color.ui=always diff $(git branch | grep "^*" | tr -d "* ") $(echo {} | tr -d "* ")'  \
        --color bg:#222222,preview-bg:#333333)

exit_exception

selected=$(echo $selected | tr -d "* ")

git merge "$selected"
}

function delete_branch (){

	selected=$(git branch | fzf +m \
		--height 40% \
		--layout reverse \
		--border\
		--preview\
				'git -c color.ui=always diff $(git branch | grep "^*" | tr -d "* ") $(echo {} | tr -d "* ")'  \
		--color bg:#222222,preview-bg:#333333)

	exit_exception

	selected=$(echo $selected | tr -d "* ")

	git branch -d "$selected"
}

function main_menu () {
	
	options=(\
		"1 - Switch Branch" \
		"2 - Merge Branch" \
		"3 - Delete Branch" \
		"4 - Exit" \
	)

	selected=$(( for option in "${options[@]}"; do echo "$option"; done | fzf +m \
	 		--height 40% \
			--layout reverse \
			--border \
			--color bg:#222222)

	exit_exception

	case "$selected" in
		"${options[0]}" in
				switch_branch
				exit 0
		;;
		"${options[1]}" in
				merge
				exit 0
		;;
		"${options[2]}" in
				delete_branch
				exit 0
		;;
		"${options[3]}" in
				echo "Exiting..."
				exit 0
		;;
		*)
				echo "Invalid option"
				exit 1

}

