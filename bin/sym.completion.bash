#!/usr/bin/env bash
#
# Sym Command Line completion and other utilities
# 
# © 2015-2018, Konstantin Gredeskoul,  https://github.com/kigster/sym
#
# MIT LICENSE
#
###########################################################################

( [[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] || \
  [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && _s_=1 || _s_=0

bash_version=$(bash --version | awk '{FS="version"}{print $4}')
bash_version=${bash_version:0:1}

[[ -z $(type _filedir 2>/dev/null) ]] && {
  declare -a bash_completion_locations=(/usr/local/etc/bash_completion /usr/etc/bash_completion /etc/bash_completion)
  loaded=false
  for file in ${bash_completion_locations[@]}; do
    [[ -s ${file} ]] && {
      source ${file}
      break
    }
  done
}

_sym_long_opts() {
    sym -h | grep -- '--' | egrep '^  -' | awk '{print $2}' | sort
}

_sym_short_opts() {
    sym -h | grep -- '--' | egrep '^  -' | awk '{print $1}' | sed 's/,//g' | sort
}

unset _SYM_COMP_LONG_OPTIONS
unset _SYM_COMP_SHORT_OPTIONS

_sym()
{
    local cur prev shell i path

    COMPREPLY=()
    cur=`_get_cword`
    prev=${COMP_WORDS[COMP_CWORD-1]}

    _expand || return 0

    case "$prev" in
        --@(key|file|output|negate))
            _filedir
            return 0
            ;;
        -@(f|k|o|n))
            _filedir
            return 0
            ;;
    esac

    case "$cur" in
        --*)
            export _sym_comp_long_options=${_sym_comp_long_options:-$(_sym_long_opts)}
            COMPREPLY=($( compgen -W "$_sym_comp_long_options" -- "$cur" ))
            ;;
        -*)
            export _sym_comp_short_options=${_sym_comp_short_options:-$(_sym_short_opts)}
            COMPREPLY=($( compgen -W "$_sym_comp_short_options" -- "$cur" ))
            ;;
        *)
            _filedir
            ;;
    esac

    return 0
} && complete -F _sym $nospace $filenames sym

sym-encrypt() {
  local key=$1
  local from=$2
  local to=$3
  local args=

  [[ -n $key ]] && args="${args} -ck ${key}"

  if [[ -n $to ]]; then
    args="${args} -o ${to}"
    [[ -n $from ]] && args="${args} -f ${from}"
  else
    [[ -n $from ]] && args="${args} -n ${from}"
  fi

  if [[ -z $args ]]; then
    echo "usage: sym-encrypt key file [ outfile ]"
  else
    sym -e ${args}
  fi
}

sym-decrypt() {
  local key=$1
  local from=$2
  local to=$3
  local args=

  [[ -n $key ]] && args="${args} -ck ${key}"

  if [[ -n $to ]]; then
    args="${args} -o ${to}"
    [[ -n $from ]] && args="${args} -f ${from}"
  else
    [[ -n $from ]] && args="${args} -n ${from}"
  fi

  if [[ -z $args ]]; then
    echo "usage: sym-decrypt key file [ outfile ]"
  else
    sym -d ${args}
  fi
}

alias syme="sym-encrypt"
alias symd="sym-decrypt"

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
