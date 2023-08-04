#!/usr/bin/env bash
# shellcheck disable=2034

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
## 7    | image      | Display the file directly as an image

FILE_PATH=""
FILE_SIZE=0
PREVIEW_WIDTH=10
PREVIEW_HEIGHT=10
PREVIEW_X_COORD=0
PREVIEW_Y_COORD=0
IMAGE_CACHE_PATH=""

# echo "$@"

while [ "$#" -gt 0 ]; do
  case "$1" in
  "--path")
    shift
    FILE_PATH="$1"
    ;;
  "--preview-width")
    shift
    PREVIEW_WIDTH="$1"
    ;;
  "--preview-height")
    shift
    PREVIEW_HEIGHT="$1"
    ;;
  "--x-coord")
    shift
    PREVIEW_X_COORD="$1"
    ;;
  "--y-coord")
    shift
    PREVIEW_Y_COORD="$1"
    ;;
  "--image-cache")
    shift
    IMAGE_CACHE_PATH="$1"
    ;;
  esac
  shift
done

if [ "$(uname)" == "Darwin" ]; then
  FILE_SIZE=$(stat -f%z "$FILE_PATH")
elif [ "$(uname)" == "Linux" ]; then
  FILE_SIZE=$(stat --printf="%s" "$FILE_PATH")
fi

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"
FILE_NAME="${FILE_PATH##*/}"
MIMETYPE=$(file --mime-type -Lb "${FILE_PATH}")

## Settings
HIGHLIGHT_SIZE_MAX=262143 # 256KiB
HIGHLIGHT_TABWIDTH="${HIGHLIGHT_TABWIDTH:-8}"
HIGHLIGHT_STYLE="${HIGHLIGHT_STYLE:-pablo}"
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE="${PYGMENTIZE_STYLE:-autumn}"
OPENSCAD_IMGSIZE="${RNGR_OPENSCAD_IMGSIZE:-1000,1000}"
OPENSCAD_COLORSCHEME="${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}"

bat() {
  command bat "$@" \
    --color=always --paging=never \
    --style=plain \
    --wrap=character \
    --line-range :500 \
    --terminal-width="${PREVIEW_WIDTH}"
}

handle_text() {
  # if [ $FILE_SIZE -ge $HIGHLIGHT_SIZE_MAX ]; then
  # 	head -c$HIGHLIGHT_SIZE_MAX "${FILE_PATH}" | bat --color && exit 5
  # else
  # jq --color-output . "${FILE_PATH}" && exit 5
  bat "$@" "${FILE_PATH}" && exit 5
  # fi
}

handle_image() {
  if [ "$FILE_SIZE" -le 30000000 ]; then
    ## Preview as text conversion
    # img2txt --gamma=0.6 --width="${PREVIEW_WIDTH}" -- "${FILE_PATH}" && exit 4
    viu -b -w "${PREVIEW_WIDTH}" "${FILE_PATH}" && exit 4
    # tiv "${FILE_PATH}" && exit 4
  fi
  exiftool "${FILE_PATH}" && exit 5
}

handle_extension() {
  case "${FILE_EXTENSION_LOWER}" in
  ## Archive
  a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | \
    rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip)
    atool --list -- "${FILE_PATH}" && exit 5
    bsdtar --list --file "${FILE_PATH}" && exit 5
    exit 1
    ;;
  rar)
    ## Avoid password prompt by providing empty password
    unrar lt -p- -- "${FILE_PATH}" && exit 5
    exit 1
    ;;
  7z)
    ## Avoid password prompt by providing empty password
    7z l -p -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  mp3 | flac | wav)
    # exiftool "$FILE_PATH" && exit 5
    ffprobe -loglevel error -show_entries format_tags "${FILE_PATH}" && exit 5
    exit 1
    ;;

    ## PDF
    ## pdf)
    ## Preview as text conversion
  ##    pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | \
  ##      fmt -w "${PREVIEW_WIDTH}" && exit 5
  ##    mutool draw -F txt -i -- "${FILE_PATH}" 1-10 | \
  ##      fmt -w "${PREVIEW_WIDTH}" && exit 5
  ##    exiftool "${FILE_PATH}" && exit 5
  ##    exit 1;;

  ## BitTorrent
  torrent)
    transmission-show -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## OpenDocument
  odt | ods | odp | sxw)
    ## Preview as text conversion
    odt2txt "${FILE_PATH}" && exit 5
    ## Preview as markdown conversion
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## XLSX
  xlsx)
    ## Preview as csv conversion
    ## Uses: https://github.com/dilshod/xlsx2csv
    xlsx2csv -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## HTML
  htm | html | xhtml)
    ## Preview as text conversion
    w3m -dump "${FILE_PATH}" && exit 5
    lynx -dump -- "${FILE_PATH}" && exit 5
    elinks -dump "${FILE_PATH}" && exit 5
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
    ;;

  ## JSON
  json)
    handle_text
    ;;

  ipynb)
    # jupyter-nbconvert "${FILE_PATH}" --to markdown --stdout | glow -s dracula - && exit 5
    handle_text
    ;;

  toml | tmpl)
    handle_text
    ;;

  ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
  ## by file(1).
  dff | dsf | wv | wvc)
    mediainfo "${FILE_PATH}" && exit 5
    exiftool "${FILE_PATH}" && exit 5
    ;; # Continue with next handler on failure

  uc!)
    nc2mp3 --info "$FILE_PATH" | bat -l json
    exit 5
    ;;
  esac
}

handle_mime() {
  local mimetype="${1}"

  case "${mimetype}" in
  ## RTF and DOC
  text/rtf | *msword)
    ## Preview as text conversion
    ## note: catdoc does not always work for .doc files
    ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
    catdoc -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## DOCX, ePub, FB2 (using markdown)
  ## You might want to remove "|epub" and/or "|fb2" below if you have
  ## uncommented other methods to preview those formats
  *wordprocessingml.document | */epub+zip | */x-fictionbook+xml)
    ## Preview as markdown conversion
    pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## E-mails
  message/rfc822)
    ## Parsing performed by mu: https://github.com/djcb/mu
    mu view -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## XLS
  *ms-excel)
    ## Preview as csv conversion
    ## xls2csv comes with catdoc:
    ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
    xls2csv -- "${FILE_PATH}" && exit 5
    exit 1
    ;;

  text/* | */xml)
    handle_text
    exit 2
    ;;

  */json)
    handle_text -l json
    exit 2
    ;;

  ## DjVu
  image/vnd.djvu)
    ## Preview as text conversion (requires djvulibre)
    djvutxt "${FILE_PATH}" | fmt -w "${PREVIEW_WIDTH}" && exit 5
    exiftool "${FILE_PATH}" && exit 5
    exit 1
    ;;

  ## Image
  image/*)
    handle_image
    exit 1
    ;;

  ## Video and audio
  video/* | audio/*)
    mediainfo "${FILE_PATH}" && exit 5
    exiftool "${FILE_PATH}" && exit 5
    exit 1
    ;;
  esac
}

# Reset
Color_Off='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

# Bold
BBlack='\033[1;30m'  # Black
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BBlue='\033[1;34m'   # Blue
BPurple='\033[1;35m' # Purple
BCyan='\033[1;36m'   # Cyan
BWhite='\033[1;37m'  # White

# Underline
UBlack='\033[4;30m'  # Black
URed='\033[4;31m'    # Red
UGreen='\033[4;32m'  # Green
UYellow='\033[4;33m' # Yellow
UBlue='\033[4;34m'   # Blue
UPurple='\033[4;35m' # Purple
UCyan='\033[4;36m'   # Cyan
UWhite='\033[4;37m'  # White

# Background
On_Black='\033[40m'  # Black
On_Red='\033[41m'    # Red
On_Green='\033[42m'  # Green
On_Yellow='\033[43m' # Yellow
On_Blue='\033[44m'   # Blue
On_Purple='\033[45m' # Purple
On_Cyan='\033[46m'   # Cyan
On_White='\033[47m'  # White

# High Intensity
IBlack='\033[0;90m'  # Black
IRed='\033[0;91m'    # Red
IGreen='\033[0;92m'  # Green
IYellow='\033[0;93m' # Yellow
IBlue='\033[0;94m'   # Blue
IPurple='\033[0;95m' # Purple
ICyan='\033[0;96m'   # Cyan
IWhite='\033[0;97m'  # White

# Bold High Intensity
BIBlack='\033[1;90m'  # Black
BIRed='\033[1;91m'    # Red
BIGreen='\033[1;92m'  # Green
BIYellow='\033[1;93m' # Yellow
BIBlue='\033[1;94m'   # Blue
BIPurple='\033[1;95m' # Purple
BICyan='\033[1;96m'   # Cyan
BIWhite='\033[1;97m'  # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'  # Black
On_IRed='\033[0;101m'    # Red
On_IGreen='\033[0;102m'  # Green
On_IYellow='\033[0;103m' # Yellow
On_IBlue='\033[0;104m'   # Blue
On_IPurple='\033[0;105m' # Purple
On_ICyan='\033[0;106m'   # Cyan
On_IWhite='\033[0;107m'  # White

handle_chezmoi() {
  # shellcheck disable=2086
  diff="$(chezmoi diff $FILE_PATH)"

  # shellcheck disable=2181
  if [ $? -gt 0 ]; then
    # echo "chezmoi nomanaged"
    :
  elif [ -z "$diff" ]; then
    echo -e "$BGreen---chezmoi clean---\n$Color_Off"
  else
    echo -e "$BRed---chezmoi diff---\n$Color_Off"
  fi
}

echo_long_file_name() {
  if [ ${#FILE_NAME} -gt 20 ]; then
    echo -e "$UCyan$FILE_NAME\n$Color_Off" | fold -w "$PREVIEW_WIDTH"
  fi
}

echo_stat() {
  stat "${FILE_PATH}" | fold -w "$PREVIEW_WIDTH"
}

handle_fallback() {
  [[ "$FILE_NAME" =~ ^\.[a-z]*rc$ ]] && handle_text
  echo -e "----- File Type Classification -----\n$MIMETYPE\n\n"
  echo_stat && exit 5
  exit 1
}

echo_long_file_name

if [ "$FILE_SIZE" -ge 30000000 ]; then
  echo_stat && exit 5
  exit 1
fi

handle_chezmoi
MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback
