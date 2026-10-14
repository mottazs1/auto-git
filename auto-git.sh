#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME="auto-git"

die() {
    printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "o comando obrigatório não foi encontrado: $1"
}

check_repository() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
        die "execute este script dentro de um repositório Git"
}

current_branch() {
    git branch --show-current
}

branch_list() {
    git for-each-ref --format='%(refname:short)' refs/heads/
}

select_branch() {
    local prompt="$1"
    local branches="$2"
    local selected

    if [[ -z "$branches" ]]; then
        printf 'Nenhuma branch disponível para esta operação.\n' >&2
        return 1
    fi

    if ! selected=$(printf '%s\n' "$branches" |
        fzf --no-multi \
            --header="$prompt" \
            --height=40% \
            --layout=reverse \
            --border \
            --preview='git log --color=always --decorate --oneline -n 20 -- {}' \
            --preview-window=right:60% \
            --color='bg:#222222,preview-bg:#333333'); then
        return 1
    fi

    [[ -n "$selected" ]] || return 1
    printf '%s\n' "$selected"
}

switch_branch() {
    local selected

    selected=$(select_branch "Selecione a branch para trocar:" "$(branch_list)") || return 0
    git switch -- "$selected"
}

merge_branch() {
    local selected
    local current

    current=$(current_branch)
    [[ -n "$current" ]] ||
        die "não é possível fazer merge enquanto o HEAD está detached"

    selected=$(select_branch "Selecione a branch para fazer merge:" "$(branch_list)") || return 0
    [[ "$selected" != "$current" ]] ||
        die "a branch atual não pode ser mesclada consigo mesma"

    git merge -- "$selected"
}

delete_branch() {
    local selected
    local current
    local branches

    current=$(current_branch)
    branches=$(branch_list)
    if [[ -n "$current" ]]; then
        branches=$(printf '%s\n' "$branches" | grep -Fvx -- "$current" || true)
    fi

    selected=$(select_branch "Selecione a branch para excluir:" "$branches") || return 0
    git branch --delete -- "$selected"
}

create_branch() {
    local branch_name

    printf 'Nome da nova branch: '
    read -r branch_name

    if [[ -z "$branch_name" ]]; then
        printf 'O nome da branch não pode ser vazio.\n' >&2
        return 1
    fi

    if ! git check-ref-format --branch "$branch_name" >/dev/null 2>&1; then
        printf 'Nome de branch inválido: %s\n' "$branch_name" >&2
        return 1
    fi

    git switch --create "$branch_name"
}

main_menu() {
    local choice

    while true; do
        choice=$(printf '%s\n' \
            "1 - Trocar branch" \
            "2 - Fazer merge" \
            "3 - Excluir branch" \
            "4 - Criar nova branch" \
            "5 - Sair" |
            fzf --no-multi \
                --header="Selecione uma operação:" \
                --height=40% \
                --layout=reverse \
                --border \
                --color='bg:#222222') || return 0

        case "$choice" in
            "1 - Trocar branch")
                switch_branch
                ;;
            "2 - Fazer merge")
                merge_branch
                ;;
            "3 - Excluir branch")
                delete_branch
                ;;
            "4 - Criar nova branch")
                create_branch
                ;;
            "5 - Sair")
                printf 'Saindo...\n'
                return 0
                ;;
            *)
                die "opção inválida: $choice"
                ;;
        esac
    done
}

require_command git
require_command fzf
check_repository
main_menu
