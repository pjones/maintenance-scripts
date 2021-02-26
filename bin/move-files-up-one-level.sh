#!/usr/bin/env bash

################################################################################
set -eu
set -o pipefail

################################################################################
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Read file names from stdin, delimited by a NULL character, and move
them one directory up, if that's safe to do.

  -d      Dry run, don't actually move files
  -h      This message

Example:

  $ find . -type f -print0 > /tmp/files-to-move
  $ move-files-up-one-level.sh -d < /tmp/files-to-move
  $ rm /tmp/files-to-move

  In the above example, the file list is first written to a file and
  then that file is used to make the moves.  This ensures that find(1)
  won't see a moved file and report it twice to the moving script.
  Using a pipe directly may result in files moving all the way up to
  the starting directory.
EOF
}

################################################################################
option_dry_run=0
global_error_count=0

################################################################################
parse_command_line() {
  # Option arguments are in $OPTARG
  while getopts "dh" o; do
    case "${o}" in
    d)
      option_dry_run=1
      ;;

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
}

################################################################################
move_file() {
  local file=$1

  local base
  base=$(basename "$file")

  local dir
  dir=$(dirname "$file")

  local new_name
  new_name=$(dirname "$dir")/$base

  echo "$file ==> $new_name"

  if [ -e "$new_name" ]; then
    global_error_count=$((global_error_count + 1))
    echo >&2 "ERROR: $new_name already exists!"
  elif [ "$option_dry_run" -eq 0 ]; then
    mv --no-clobber "$file" "$new_name"
  fi
}

################################################################################
main() {
  parse_command_line "$@"

  local file

  while IFS= read -r -d '' file; do
    move_file "$file"
  done

  if [ "$global_error_count" -gt 0 ]; then
    exit 1
  fi
}

################################################################################
main "$@"
