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

  local patterns=$(
    printf -- "-type d -name $1 " && shift
    printf -- "$*" | xargs -n 1 -I {} printf -- "-or -type d -name {} "
    printf -- '-print'
  )

  local downrc="$HOME/.downrc"
  local result=

  if [ -r "$downrc" ]
  then
    result="$(find "$(pwd)" $(< "$downrc") $patterns)"
  else
    result="$(find "$(pwd)" $patterns)"
  fi

  # not found
  [ -z "$result" ] && return 2

  # found
  # `grep -c` equals to `wc -l`
  local count=$(printf "$result" | grep -c '')

  # found
  if [ "$count" -eq 1 ]
  then
    cd "$result"
  else
    if type peco >/dev/null 2>&1
    then
      cd "$(printf "$result" | peco --select-1)"
    else
      printf 'match to some files:\n' >&2
      printf "${result}\n" >&2

      return 3
    fi
  fi
}

_down_usage() {
  # CAUTION: do not delete tabs
  cat <<-USAGE >&2
	Usage:
	  down pattern
	USAGE
}

alias ${_DOWN_CMD:-down}='_down'
