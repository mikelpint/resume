#!/usr/bin/env bash

BASE="$(dirname $(realpath "$0"))"
PWD="$BASE"
OUT="$BASE/out"
MAIN="$BASE/main.tex"

function onexit() {
    [ -d "$OUT" ] && latexmk -outdir="$OUT" -c

    exit 0
}
trap 'onexit' 2 # SIGINT

[ ! -d "$OUT" ] && mkdir "$OUT"

langs=("en" "es")

case "${1:-}" in
    "clean")
        rm -rf "$OUT"
    ;;

    "watch")
        latexmk \
            -xelatex \
            -shell-escape \
            -usepretex="\newcommand\langver{${langs[0]}}" \
            -e '$pdf_previewer=q[xdg-open %S];' \
            -outdir="$OUT" \
            -jobname="${langs[0]}" \
            -pvc \
            "$MAIN"
        onexit
    ;;

    "")
        for lang in "${langs[@]}"
        do
        latexmk \
            -xelatex \
            -shell-escape \
            -usepretex="\newcommand\langver{${lang}}" \
            -e '$pdf_previewer=q[xdg-open %S];' \
            -outdir="${OUT}" \
            -jobname="${lang}" \
            "$MAIN"
        done
    ;;

    *)
        exit 1
    ;;
esac
