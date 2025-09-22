#!/usr/bin/env bash

BASE="$(dirname $(realpath "$0"))"
PWD="${BASE}"
OUT="${BASE}/out"
PREVIEW="${BASE}/preview"
MAIN="${BASE}/main.tex"

langs=("en" "es")

function onexit() {
    [ -d "${OUT}" ] && \
        for lang in "${langs[@]}"
        do
            latexmk \
                -outdir="$OUT" \
                -jobname="${lang}" \
                -c
        done

    exit 0
}
trap 'onexit' 2 # SIGINT

function create_out() {
    [ ! -d "${OUT}" ] && mkdir "${OUT}"
}

function create_preview() {
    [ ! -d "${PREVIEW}" ] && mkdir "${PREVIEW}"
}

case "${1:-}" in
    "clean")
        rm -rf "${OUT}"
    ;;

    "watch")
        create_out

        latexmk \
            -xelatex \
            -shell-escape \
            -usepretex="\newcommand\langver{${langs[0]}}" \
            -e '$pdf_previewer=q[xdg-open %S];' \
            -outdir="${OUT}" \
            -jobname="${langs[0]}" \
            -pvc \
            "${MAIN}"
        onexit
    ;;

    "")
        create_out
        create_preview

        for lang in "${langs[@]}"
        do
            latexmk \
                -xelatex \
                -shell-escape \
                -usepretex="\newcommand\langver{${lang}}" \
                -outdir="${OUT}" \
                -jobname="${lang}" \
                "${MAIN}"

            magick \
                convert \
                -density 1200 \
                -resize 25% \
                -background white \
                -alpha remove \
                -alpha off \
                "${OUT}/${lang}.pdf" \
                "${PREVIEW}/${lang}.png"
        done

        echo -e "![Resume preview](${PREVIEW}/${langs[0]}.png)" > README.md

        onexit
    ;;

    *)
        exit 1
    ;;
esac
