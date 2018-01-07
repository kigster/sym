#!/usr/bin/env bash
#
# (c) 2017-2018 Konstantin Gredeskoul
#
# MIT License, distributed as part of `sym` ruby gem.
# • https://github.com/kigster/sym
#
#==============================================================================
#
# The purpose of this script is to transparently edit application secrets in a
# Rails apps or other repos. It simplifies the process of key import, as well
# as the direct editing.
#
# If you set some or (ideally) ALL variables below to values specific to your
# system, things will get easy.
#
# SYMIT__FOLDER is a relative folder to your project root, under which you
# might keep ALL of your encrypted files.  Alternatively, if you keep encrypted
# files sprinkled around your project, just leave it out, because it defaults
# to "." — the current folder, and search anything beneath.
#
# Variables:
#
#     # only search ./config folder
#     export SYMIT__FOLDER="config"
#
#     # this will be the name of your key in OS-X KeyChain
#     export SYMIT__KEY="MY_KEYCHAIN_NAME"
#
#     # This is the extension given to the encrypted files. Ideally, leave it
#     # be as ".enc"
#     export SYMIT__EXTENSION=".enc"
#
# And then
#
#     symit import key [ insecure ]           # import a key and password-protect it (or not)
#     symit auto application.yml.enc          # auto-decrypts it
#     symit auto application.yml              # auto-encrypts it
#     symit decrypt application.yml           # finds application.yml.enc and decrypts that.
#
#
# ...and vola! You are editing the encrypted file with sym from the root of
# your Rails application. Neat, no?
#

(   [[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] || \
    [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && _s_=1 || _s_=0

(( $_s_ )) && _is_sourced=1
(( $_s_ )) || _is_sourced=0

function __lib::color::setup()  {
  if [[ -z "${setup_colors_loaded}" ]]; then

    export txtblk='\e[0;30m' # Black - Regular
    export txtred='\e[0;31m' # Red
    export txtgrn='\e[0;32m' # Green
    export txtylw='\e[0;33m' # Yellow
    export txtblu='\e[0;34m' # Blue
    export txtpur='\e[0;35m' # Purple
    export txtcyn='\e[0;36m' # Cyan
    export txtwht='\e[0;37m' # White

    export bldblk='\e[1;30m' # Black - Bold
    export bldred='\e[1;31m' # Red
    export bldgrn='\e[1;32m' # Green
    export bldylw='\e[1;33m' # Yellow
    export bldblu='\e[1;34m' # Blue
    export bldpur='\e[1;35m' # Purple
    export bldcyn='\e[1;36m' # Cyan
    export bldwht='\e[1;37m' # White

    export unkblk='\e[4;30m' # Black - Underline
    export undred='\e[4;31m' # Red
    export undgrn='\e[4;32m' # Green
    export undylw='\e[4;33m' # Yellow
    export undblu='\e[4;34m' # Blue
    export undpur='\e[4;35m' # Purple
    export undcyn='\e[4;36m' # Cyan
    export undwht='\e[4;37m' # White

    export bakblk='\e[40m' # Black - Background
    export bakred='\e[41m' # Red
    export bakgrn='\e[42m' # Green
    export bakylw='\e[43m' # Yellow
    export bakblu='\e[44m' # Blue
    export bakpur='\e[45m' # Purple
    export bakcyn='\e[46m' # Cyan
    export bakwht='\e[47m' # White

    export clr='\e[0m' # Text Reset
    export txtrst='\e[0m' # Text Reset
    export rst='\e[0m' # Text Reset
    export GREP_COLOR=32
    export setup_colors_loaded=1
  else
    [[ -n ${DEBUG} ]] && echo "colors already loaded..."
  fi
}

((${setup_colors_loaded})) ||__lib::color::setup

(( $_s_ )) || {
  printf "${bldred}This script is meant to be sourced into your environment,\n"
  printf "not run on a command line.${clr} \n\n"

  printf "Please add 'source $0' to your BASH initialization file,\n"
  printf "or run the following command:\n\n"

  printf "    \$ ${bldgrn}sym -B ~/.bash_profile${clr}\n\n"
  
  printf "${bldblu}Thanks for using Sym!${clr}\n"
  exit 1
}

function __lib::color::hr()  {
  local cols=${1:-${COLUMNS}}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  eval "printf \"%0.s${char}\" {1..${cols}}"
  printf "${clr}\n"
}

function __lib::color::h1()  {
  local title=$(echo "$*" | tr 'a-z' 'A-Z')
  len=${#title}
  printf "${bldylw}${title}\n"
  __lib::color::hr ${len} '—'
}

function __lib::color::h2()  {
  printf "${bldpur}$*${clr}\n"
}

function __lib::color::cursor_to_col()  {
  position=$1
  echo -en "\e[${position}C"
}

function __lib::color::cursor_to_row()  {
  position=$1
  echo -en "\e[${position}H"
}

function __symit::init()  {
  export SYMIT__EXTENSION=${SYMIT__EXTENSION:-'.enc'}
  export SYMIT__FOLDER=${SYMIT__FOLDER:-'.'}
  export SYMIT__KEY=${SYMIT__KEY}
}
function __symit::usage()  {
  __lib::color::setup
  __lib::color::h1 "symit"
  printf "
  This a BASH wrapper for the encryption tool (ruby gem) 'Sym'. It streamlines
  editing encrypted of files, importing and securing your key, and other
  actions.  The wrapper can be configured with ENV variables, or CLI flags.\n"

  printf "
  The easiest way to take advantage of this wrapper is to set the following
  environment variables, which removes the need to pass these values via the
  flags. These variables default to the shown values if not set elsewhere:${txtylw}

  export SYMIT__EXTENSION='${SYMIT__EXTENSION}'
  export SYMIT__FOLDER='${SYMIT__FOLDER}'
  export SYMIT__KEY='${SYMIT__KEY}'
  ${clr}\n"

  __lib::color::h2 "Usage:"
  printf "    ${bldgrn}symit [ action ] [ partial-file-path ] [ flags ]${clr}\n\n"

  __lib::color::h2 "Actions:"
  printf "    Action is the first word that defaults to ${bldylw}edit${clr}.\n\n"
  printf "    Valid actions are:\n"
  printf "    ${bldylw}— install       ${bldblk}ensures you are on the latest gem version\n"
  printf "    ${bldylw}— generate      ${bldblk}create a new secure key, and copies it to \n"
  printf "                    clipboard (if supported), otherwise prints to STDOUT\n"
  printf "                    Key is required, and used as a name within OSX KeyChain\n\n"
  printf "    ${bldylw}— import [key] [insecure]\n"
  printf "                    ${bldblk}imports the key from clipboard and adds password\n"
  printf "                    encryption unless 'insecure' is passed in\n\n"
  printf "    ${bldylw}— edit          ${bldblk}Finds all files, and opens them in $EDITOR\n"
  printf "    ${bldylw}— encrypt       ${bldblk}Encrypts files matching file-path\n"
  printf "    ${bldylw}— decrypt       ${bldblk}Adds the extension to file pattern and decrypts\n"
  printf "    ${bldylw}— auto          ${bldblk}encrypts decrypted file, and vice versa\n"

  echo
  __lib::color::h2 "Flags:"
  printf "    -f | --folder    DIR   ${bldblk}Top level folder to search.${clr}\n"
  printf "    -k | --key       KEY   ${bldblk}Key identifier${clr}\n"
  printf "    -x | --extension EXT   ${bldblk}Default extension of encrypted files.${clr}\n"
  printf "    -n | --dry-run         ${bldblk}Print stuff, but don't do it${clr}\n"
  printf "    -h | --help            ${bldblk}Show this help message${clr}\n"

  echo
  __lib::color::h2 'Encryption key identifier can be:'
  printf "${clr}\
  1. name of the keychain item storing the keychain (secure)
  2. name of the environment variable storing the Key (*)
  3. name of the file storing the key (*)
  4. the key itself (*)

  ${bldred}(*) 2-4 are insecure UNLESS the key is encrypted with a password.${clr}

  Please refer to README about generating password protected keys:
  ${bldblu}${undblu}https://github.com/kigster/sym#generating-the-key--examples${clr}\n\n"

  echo

  __lib::color::h1 'Examples:'

  printf "  Ex1: To import a key securely,\n"
  printf "     \$ ${bldgrn}symit${bldblu} import key ${clr}\n\n"

  printf "  Ex2.: To encrypt (or decrypt) ALL files in the 'config' directory:${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} encrypt|decrypt -a -f config ${clr}\n\n"

  printf "  Ex3: To decrypt all *.yml.enc files in the 'config' directory:${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} decrypt '*.yml' -f config ${clr}\n\n"

  printf "  Ex4: To edit an encrypted file ${txtblu}config/application.yml.enc${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} application.yml${clr}\n\n"

  printf "  Ex5.: To auto decrypt a file ${txtblu}config/settings/crypt/pass.yml.enc${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  Ex6.: To automatically decide to either encrypt or decrypt a file,\n"
  printf "       based on the file extension. First example encrypts the file, second\n"
  printf "       decrypts it (because file extension is .enc):${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  Ex7.: To encrypt a file ${txtblu}config/settings.yml${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} encrypt config/settings.yml${clr}\n\n"

}
function __datum()   {
  date +"%m/%d/%Y.%H:%M:%S"
}

function __err()  {
  #__lib::color::cursor_to_col 0
  printf "${txtpur}[$(__datum)]  ${bldred}ERROR: ${txterr}$* ${bldylw}\n"
}

function __inf()  {
  #__lib::color::cursor_to_col 0
  printf "${txtpur}[$(__datum)]  ${bldgrn}INFO:  ${clr}${bldblu}$*${clr}\n"
}

function __symit::install::gem()  {
  __inf "Verifying current Sym version, please wait..."
  if [[ -z "${_symit__installed}" ]]; then
    current_version=$(gem list | grep sym | awk '{print $2}' | sed 's/(//g;s/)//g')
    if [[ -z "${current_version}" ]]; then
      gem install sym
    else
      local help=$(sym -h 2>&1)
      unset SYM_ARGS
      remote_version=$(gem search sym | egrep '^sym \(' | awk '{print $2}' | sed 's/(//g;s/)//g')
      if [[ "${remote_version}" != "${current_version}" ]]; then
        __inf "detected an older ${bldgrn}sym (${current_version})"
        __inf "installing ${bldgrn}sym (${remote_version})${clr}..."
        echo y | gem uninstall sym -a 2> /dev/null
        gem install sym
        export _symit__installed="yes"
        __inf "Installed sym version ${bldylw}$(sym --version)"
      else
        __inf "${bldgrn}sym${clr} ${txtblu}is on the latest version ${remote_version} already\n"
      fi
    fi
  fi
}

function __symit::files()  {
  eval $(__symit::files::cmd)
}

function __symit::files::cmd() {
  if [[ -n ${cli__opts[file]} && -n ${cli__opts[extension]} ]]; then
    local folder
    if [[ ${cli__opts[file]} =~ '/' ]]; then
      folder="${cli__opts[folder]}/$(dirname ${cli__opts[file]})"
    else
      folder="${cli__opts[folder]}"
    fi
    local file="$(basename ${cli__opts[file]})"
    local ext="${cli__opts[extension]}"

    if [[ "${cli__opts[action]}" == "auto" || "${cli__opts[action]}" == "encrypt" ]] ; then
      #find ${folder} -name "${file}" >&2
      printf "find ${folder} -name '${file}' -and -not -name '*${ext}'"
    else
      #find ${folder} -name "${file}${ext}" >&2
      printf "find ${folder} -name '${file}${ext}'"
    fi
  fi
}

function __symit::command()  {
  file=${1}
  if [[ -n "${cli__opts[key]}" && -n "${cli__opts[extension]}" ]]; then
    action="${cli__opts[action]}"
    flags="${sym__actions[${action}]}"
    if [[ ${action} =~ "key" ]]; then
      [[ -n ${cli__opts[verbose]} ]] && printf "processing key import action ${bldylw}${action}${clr}\n" >&2
      printf "sym ${flags} ${cli__opts[key]} "
    elif [[ ${action} =~ "generate" ]] ; then
      [[ -n ${cli__opts[verbose]} ]] && printf "processing generate key action ${bldylw}${action}${clr}\n" >&2
      if [[ -n $(which pbcopy) ]]; then
        out_key=/tmp/outkey
        command="sym ${flags} ${cli__opts[key]} -q -o ${out_key}; cat ${out_key} | pbcopy; rm -f ${out_key}"
        printf "${command}"
      else
        printf "sym ${flags} ${cli__opts[key]} "
      fi
    elif [[ -n ${file} ]] ; then
      ext="${cli__opts[extension]}"
      [[ -z ${ext} ]] && ext='.enc'
      ext=$(echo ${ext} | sed -E 's/[\*\/,.]//g')
      if [[ ${action} =~ "encrypt" ]]; then
        printf "sym ${flags} ${file} -ck ${cli__opts[key]} -o ${file}.${ext}"
      elif [[ ${action} =~ "decrypt" ]]; then
        new_name=$(echo ${file} | sed "s/\.${ext}//g")
        [[ "${new_name}" == "${file}" ]] && name="${file}.decrypted"
        printf "sym ${flags} ${file} -ck ${cli__opts[key]} -o ${new_name}"
      else
        printf "sym ${flags} ${file} -ck ${cli__opts[key]} "
      fi
    else
      printf "printf \"ERROR: not sure how to generate a correct command\\n\""
    fi
  fi
}

function __symit::cleanup()  {
  unset sym__actions
  unset cli__opts
}

function __symit::exit()  {
  code=${1:-0}
  __symit::cleanup
  echo -n ${code}
}

function __symit::print_cli_args()  {
  local -A args=$@
  __inf "action     ${bldylw}: ${cli__opts[action]}${clr}"
  __inf "key        ${bldylw}: ${cli__opts[key]}${clr}"
  __inf "file       ${bldylw}: ${cli__opts[file]}${clr}"
  __inf "extension  ${bldylw}: ${cli__opts[extension]}${clr}"
  __inf "folder     ${bldylw}: ${cli__opts[folder]}${clr}"
  __inf "verbose    ${bldylw}: ${cli__opts[verbose]}${clr}"
  __inf "dry_run    ${bldylw}: ${cli__opts[dry_run]}${clr}"
}

function __symit::args::needs_file()  {
  if [[ "${cli__opts[action]}" == 'edit' || \
  "${cli__opts[action]}" == 'auto' || \
  "${cli__opts[action]}" == 'encrypt' || \
  "${cli__opts[action]}" == 'decrypt' ]]; then
    printf 'yes'
  fi
}

function __symit::validate_args()  {
  if [[ -n $(__symit::args::needs_file) && -z ${cli__opts[file]} ]]; then
    __err "missing file argument, config/application.yml"
    return $(__symit::exit 2)
  fi

  if [[ -z "${cli__opts[key]}" ]]; then
    __err "Key was not defined, pass it with ${bldblu}-k KEY_ID${bldred}"
    __err "or set it via ${bldgrn}\$SYMIT__KEY${bldred} variable."
    return $(__symit::exit 4)
  fi

  if [[ -z ${cli__opts[extension]} ]]; then
    cli__opts[extension]='.enc'
  fi
}

function __symit::run()  {
  __symit::cleanup
  __symit::init

  declare -A cli__opts=(
    [verbose]=''
    [key]=${SYMIT__KEY}
    [extension]=${SYMIT__EXTENSION}
    [folder]=${SYMIT__FOLDER}
    [dry_run]=''
    [action]=edit
    [file]=''
  )

  declare -A sym__actions=(
    [generate]=' -cpgx '
    [edit]=' -t '
    [encrypt]='-e -f '
    [decrypt]='-d -f '
    [auto]=' -n '
    [key_secure]=' -iqcpx '
    [key_insecure]=' -iqcx '
  )

  if [[ -z $1 ]]; then
    __symit::usage
    return $(__symit::exit 0)
  fi

  while :; do
    case $1 in
      -h|-\?|--help)
          shift
          __symit::usage
          __symit::cleanup
          return $(__symit::exit 0)
          ;;

      -k|--key)
          shift
          if [[ -z $1 ]]; then
            __err "-k/--key requires an argument" && return $(__symit::exit 1)
          else
            cli__opts[key]=$1
            shift
          fi
          ;;

      -x|--extension)
          shift
          if [[ -z $1 ]]; then
            __err "-x/--extension requires an argument" && return $(__symit::exit 1)
          else
            cli__opts[extension]=${1}
            shift
          fi
          ;;

      -f|--folder)
          shift
          if [[ -z $1 ]]; then
            __err "-f/--folder requires an argument" && return $(__symit::exit 1)
          else
            cli__opts[folder]=${1}
            shift
          fi
          ;;

      -a|--all-files)
          shift
          cli__opts[file]="'*'"
          ;;

      -n|--dry-run)
          shift
          cli__opts[dry_run]="yes"
          ;;

      -v|--verbose)
          shift
          cli__opts[verbose]="yes"
          ;;

      import|key)
          shift
          cli__opts[action]="key_secure"
          ;;

      insecure)
          shift
          if [[ "${cli__opts[action]}" == 'key_secure' ]] ; then
            cli__opts[action]="key_insecure"
          fi
          ;;

      --) # End of all options.
          shift
          break
          ;;

      -?*)
          __err 'WARN: Unknown option: %s\n' "$1" >&2
          return $(__symit::exit 127)
          shift
          ;;


      ?*)
          param=$1
          if [[ -n "${sym__actions[${param}]}" ]]; then
            cli__opts[action]=${param}
          else
            cli__opts[file]=${1}
          fi
          shift
          ;;

      *) # Default case: If no more options then break out of the loop.
          break
          shift
    esac
  done

  [[ -n ${cli__opts[verbose]} ]] &&__symit::print_cli_args

  if [[ "${cli__opts[action]}" == 'install' ]]; then
    if [[ -n ${cli__opts[dry_run]} ]]; then
      __inf "This command verifies that Sym is properly installed,"
      __inf "and if not found — installs it."
      return $(__symit::exit 0)
    else
      __symit::install::gem
      return $(__symit::exit 0)
    fi
  fi

  __symit::validate_args

  changed_count=0

  if [[ -n "${cli__opts[dry_run]}" ]] ; then
    __lib::color::h1 "Dry Run — printing commands that would be run:"
    for file in $(__symit::files); do
      printf "   \$ ${bldblu}$(__symit::command ${file})${clr}\n"
    done
  else
    if [[ -n "${cli__opts[file]}" ]]; then
      [[ -n ${cli__opts[verbose]} ]] && __inf $(__symit::files)
      declare -a file_list
      for file in $(__symit::files); do
        file_list=(${file} "${file_list[*]}")
        __inf "❯ ${bldblu}$(__symit::command ${file})${clr}"
        eval $(__symit::command ${file})
        code=$?; [[ ${code} != 0 ]] && __err "sym returned non-zero code ${code}"
      done
      if [[ ${#file_list} == 0 ]]; then
        __inf "No files matched your specification. The following 'find' command"
        __inf "ran to find them: \n"
        __inf "   ${bldylw}$(__symit::files::cmd)${clr}\n\n"
        return $(__symit::exit 5)
      fi
    else
      [[ -n ${cli__opts[verbose]} ]] && __inf $(__symit::command)
      eval $(__symit::command)
      code=$?; [[ ${code} != 0 ]] && return $(__symits::exit ${code})
    fi
  fi
}

function symit()  {
  __symit::run $@
}
