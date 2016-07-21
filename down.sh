# (The MIT license)
#
# Copyright (c) 2016 sasa+1 <sasaplus1@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

_down() {
  # arguments not found
  [ "$#" -eq 0 ] && _down_usage && return 1

  # use peco
  if [ "$1" = '-p' ]
  then
    shift
    _down_peco $*
  else
    _down_move $*
  fi
}

_down_move() {
  local first=$1

  shift

  local pattern=$(
    printf -- "-name ${first} "

    for v in $*
    do
      printf -- "-and -name ${v} "
    done
  )

  local find_options="-type d ${pattern}-print"

  local downrc="$HOME/.downrc"
  local result=

  if [ -r "$downrc" ]
  then
    result="$(find "$(pwd)" $(< "$downrc") $(printf -- "$find_options"))"
  else
    result="$(find "$(pwd)" $(printf -- "$find_options"))"
  fi

  local count=0

  for file in $(printf "$result" | xargs -n 1)
  do
    count=$((count + 1))
  done

  if [ "$count" -eq 1 ]
  then
    cd "$result"
  elif [ "$count" -gt 1 ]
  then
    printf 'match to some files:\n' >&2
    printf "${result}\n" >&2

    return 2
  else
    printf 'no match' >&2

    return 3
  fi
}

_down_peco() {
  type peco 2>&1 >/dev/null

  if [ "$?" -ne 0 ]
  then
    echo 'peco is not found'

    return 4
  fi

  local find_options='-type d -print'
  local peco_options='--select-1 --query'

  local downrc="$HOME/.downrc"

  if [ -r "$downrc" ]
  then
    cd "$(find "$(pwd)" $(< "$downrc") $find_options | peco $peco_options "$*")"
  else
    cd "$(find "$(pwd)" $find_options | peco $peco_options "$*")"
  fi
}

_down_usage() {
  # CAUTION: do not delete tabs
  cat <<-USAGE >&2
	Usage:
	  down [-p] pattern
	
	Options:
	  -p  use peco
	USAGE
}

alias ${_DOWN_CMD:-down}='_down'
