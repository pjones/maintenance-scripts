#!/usr/bin/env bash

################################################################################
set -eu
set -o pipefail

################################################################################
usage() {
  cat <<EOF
Usage: $(basename "$0") [options] directory

Delete any empty subdirectories of the given directory.

  -h      This message

EOF
}

################################################################################
while getopts "h" o; do
  case "${o}" in
  h)
    usage
    exit
    ;;

  *)
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
  echo >&2 "ERROR: please provide one or more directories"
  exit 1
fi

find "$@" -mindepth 1 -depth -empty -type d -exec rmdir '{}' ';'
