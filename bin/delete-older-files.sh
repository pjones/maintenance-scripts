#!/usr/bin/env bash

################################################################################
set -eu
set -o pipefail

################################################################################
usage() {
  cat <<EOF
Usage: $(basename "$0") [options] directory [directory...]

Delete old files from one or more directories.  Empty subdirectories
will also be removed.

  -h      This message
  -d NUM  Delete files older than NUM days [$option_days]

EOF
}

################################################################################
parse_opts() {
  while getopts "hd:" o; do
    case "${o}" in
    h)
      usage
      exit
      ;;

    d)
      option_days=$OPTARG
      ;;

    *)
      exit 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ $# -eq 0 ]; then
    echo >&2 "ERROR: you must provide one or more directories to clean"
    exit 1
  fi

  option_dirs=("$@")
}

################################################################################
option_days=14
option_dirs=()

################################################################################
main() {
  local bin
  bin=$(realpath "$(dirname "$0")")

  parse_opts "$@"

  find "${option_dirs[@]}" -depth -type f -mtime "+$option_days" -delete
  "$bin/delete-empty-directories.sh" "${option_dirs[@]}"
}

################################################################################
main "$@"
