#!/bin/bash

selected=$(git branch | fzf \
	--height 40% \
	--layout reverse \
	--border \
	--preview \
		'git log --oneline $(echo {} | tr -d "* ")' \
	--color bg:#222222,preview-bg:#333333)

selected=$(echo $selected | tr -d "* ")

echo "$selected"

git switch "$selected"

