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


# returns 3 for 3.2.57(1)-release
# returns 4 for 4.... etc.

function __lib::shell::name() {
  echo $(basename $(printf $SHELL))
}

function __lib::shell::is_bash() {
  [[ $(__lib::shell::name) == "bash" ]] && echo yes
}

function __lib::bash::version_number() {
  echo $BASH_VERSION | awk 'BEGIN{FS="."}{print $1}'
}

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

((${setup_colors_loaded})) || __lib::color::setup

if [[ $(__lib::bash::version_number) -lt 4 ]]; then
  printf "${bldred}On noes, Symit requires BASH version 4+.\n"

  if [[ $(uname -s) == 'Darwin' ]]; then

    printf "Since you are on OS-X, we refer you to either the following
blog post ${undblu}https://johndjameson.com/blog/updating-your-shell-with-homebrew/${clr}

Or, you can run the following commands yourself to use Brew to change
your shell to the latest BASH:\n"

    printf "${bldylw}"
    printf '
    [[ $(which brew) ]] || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install bash
    [[ $(grep "/usr/local/bin/bash" /etc/shells) ]] || sudo echo /usr/local/bin/bash >> /etc/shells
    [[ ${SHELL} != /usr/local/bin/bash && -x /usr/local/bin/bash ]] && chsh -s /usr/local/bin/bash

    echo "NOTE: do not close your current session. Start a new terminal,"
    echo "to verify you are on a new shell by running: echo $BASH_VERSION"
    '
    printf "${clr}"
  fi
fi
  
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
  __lib::color::hr ${len} '─'
}

function __lib::color::h2()  {
  printf "${bldpur}$*${clr}\n"
}

function __lib::color::cursor-right-by()  {
  position=$1
  echo -en "\e[${position}C"
}

function __lib::color::cursor-left-by()  {
  position=$1
  echo -en "\e[${position}D"
}

function __lib::color::cursor-up-by()  {
  position=$1
  echo -en "\e[${position}A"
}

function __lib::color::cursor-down-by()  {
  position=$1
  echo -en "\e[${position}B"
}

# Convert a version string such as "1.50.17" to an integer
# 101050017
function __lib::ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

function __lib::i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

################################################################################

function __symit::init()  {
  export SYMIT__EXTENSION=${SYMIT__EXTENSION:-'.enc'}
  export SYMIT__FOLDER=${SYMIT__FOLDER:-'.'}
  export SYMIT__KEY=${SYMIT__KEY}
  export SYMIT__MIN_VERSION='latest'
}

function __symit::usage()  {
  __lib::color::setup
  __lib::color::h1 "symit"
  printf "
  ${bldylw}symit${bldgrn} is a BASH helper for the encryption tool ${bldred}Sym${clr}. 

  Sym has an extensive CLI interface, but it only handles one encryption/decryption
  operation per invocation. With this script, you can auto decrypt all files in 
  a given folder, you can import the key in a simpler way, and you can save into the
  environment sym configuration that will be used. It also streamlines editing of 
  encrypted files in a given folder. Symit can be configured with ENV variables, 
  or using CLI flags, use whichever you prefer.\n"

  printf "
  The recommended way to use ${bldred}symit${clr} is to set the following
  environment variables, which removes the need to pass these values via the
  flags. These variables default to the shown values if not set elsewhere:

  Perhaps the most critically important variable to set is ${txtylw}SYMIT__KEY${clr}:

       export SYMIT__KEY='my-org.my-app.dev'
   eg: export SYMIT__KEY='github.web.development' 

  If you have a different key per 'environment' you can have a script change
  SYMIT__KEY when you change the environment.

  Additional configuration is available through these variables:

     export SYMIT__EXTENSION='${SYMIT__EXTENSION}'
     export SYMIT__FOLDER='${SYMIT__FOLDER}'
     export SYMIT__MIN_VERSION='latest'

  The last variable defines the minimum Sym version desired. Set it to
  'latest' to have symit auto-upgrade Sym every time its called.

  ${clr}\n"

  __lib::color::h2 "Usage:"
  printf "    ${bldgrn}symit [ action ] [ partial-file-path ] [ flags ]${clr}\n\n"

  __lib::color::h2 "Actions:"
  printf "    Action is the first word that defaults to ${bldylw}edit${clr}.\n\n"
  printf "    Valid actions are:\n"
  printf "    ${bldylw}— install       ${clr}ensures you are on the latest gem version\n"
  printf "    ${bldylw}— generate      ${clr}create a new secure key, and copies it to \n"
  #printf '                    clipboard (if supported), otherwise prints to STDOUT'; echo
  printf "                    Key is required, and used as a name within OSX KeyChain\n\n"
  printf "    ${bldylw}— import [key] [insecure]\n"
  printf "                    ${clr}imports the key from clipboard and adds password\n"
  printf "                    encryption unless 'insecure' is passed in\n\n"
  printf "    ${bldylw}— edit          ${clr}Finds all files, and opens them in $EDITOR\n"
  printf "    ${bldylw}— encrypt       ${clr}Encrypts files matching file-path\n"
  printf "    ${bldylw}— decrypt       ${clr}Adds the extension to file pattern and decrypts\n"
  printf "    ${bldylw}— auto          ${clr}encrypts decrypted file, and vice versa\n"

  echo
  __lib::color::h2 "Flags:"
  printf "    -f | --folder    DIR   ${clr}Top level folder to search.${clr}\n"
  printf "    -k | --key       KEY   ${clr}Key identifier${clr}\n"
  printf "    -x | --extension EXT   ${clr}Default extension of encrypted files.${clr}\n"
  printf "    -n | --dry-run         ${clr}Print stuff, but dont do it${clr}\n"
  printf "    -h | --help            ${clr}Show this help message${clr}\n"

  echo
  __lib::color::h2 'Encryption key identifier can be:'
  printf "${clr}"

  printf '
  1. name of the keychain item storing the keychain (secure)
  2. name of the environment variable storing the Key (*)
  3. name of the file storing the key (*)
  4. the key itself (*)'

  echo
  printf "${bldred}"
  printf '
  (*) 2-4 are insecure UNLESS the key is encrypted with a password.'; echo
  printf "${clr}\
  Please refer to README about generating password protected keys:\n
  ${bldblu}${undblu}https://github.com/kigster/sym#generating-the-key--examples${clr}\n\n"
  echo

  __lib::color::h1 'Examples:'

  printf "  Ex1: To import a key securely,\n"
  printf "     \$ ${bldgrn}symit${bldblu} import key ${clr}\n\n"

  printf "  Ex2.: To encrypt or decrypt ALL files in the 'config' directory:${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} encrypt|decrypt -a -f config ${clr}\n\n"

  printf "  Ex3: To decrypt all *.yml.enc files in the 'config' directory:${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} decrypt '*.yml' -f config ${clr}\n\n"

  printf "  Ex4: To edit an encrypted file ${txtblu}config/application.yml.enc${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} application.yml${clr}\n\n"

  printf "  Ex5.: To auto decrypt a file ${txtblu}config/settings/crypt/pass.yml.enc${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  Ex6.: To automatically decide to either encrypt or decrypt a file,\n"
  printf "       based on the file extension. First example encrypts the file, second\n"
  printf "       decrypts it, because the file extension is .enc:${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  Ex7.: To encrypt a file ${txtblu}config/settings.yml${clr}\n"
  printf "     \$ ${bldgrn}symit${bldblu} encrypt config/settings.yml${clr}\n\n"
}

function __datum()   {
  date +"%m/%d/%Y.%H:%M:%S"
}

function __err()  {
  __lib::color::cursor-left-by 1000
  printf "${txtpur}[$(__datum)]  ${bldred}ERROR: ${txterr}$* ${bldylw}\n"
}

function __inf()  {
  [[ ${cli__opts[quiet]} ]] && return

  __lib::color::cursor-left-by 1000
  printf "${txtpur}[$(__datum)]  ${bldgrn}INFO:  ${clr}${bldblu}$*${clr}\n"
}

function __symit::sym::installed_version() {
  __lib::ver-to-i $(gem list | grep sym | awk '{print $2}' | sed 's/(//g;s/)//g')
}

function __symit::sym::latest_version() {
  __lib::ver-to-i $(gem query --remote -n '^sym$' | awk '{print $2}' | sed 's/(//g;s/)//g')
}

function __symit::install::update() {
  local desired_version=$1
  shift
  local current_version=$2
  shift
  local version_args=$*

  __inf "updating sym to version ${bldylw}$(__lib::i-to-ver ${desired_version})${clr}..."
  printf "${bldblu}" >&1
  echo y | gem uninstall sym --force -x  2>/dev/null
  printf "${clr}" >&1

  command="gem install sym ${version_args} "
  eval "${command}" >/dev/null
  code=$?
  printf "${clr}" >&2
  if [[ ${code} != 0 ]]; then
    __err "gem install returned ${code}, with command ${bldylw}${command}"
    return 127
  fi
  current_version=$(__symit::sym::installed_version)
  __inf "installed sym version ${bldylw}$(__lib::i-to-ver ${current_version})"
}

function __symit::install::gem()  {
  __inf "Verifying current Sym version, please wait..."
  current_version=$(__symit::sym::installed_version)
  if [[ -n ${SYMIT__MIN_VERSION} ]]; then
    if [[ ${SYMIT__MIN_VERSION} -eq 'latest' ]]; then
      desired_version=$(__symit::sym::latest_version)
      version_args=''
    else
      desired_version=$( __lib::ver-to-i ${SYMIT__MIN_VERSION})
      version_args=" --version ${SYMIT__MIN_VERSION}"
    fi

    if [[ "${desired_version}" != "${current_version}" ]]; then
      __symit::install::update "${desired_version}" "${current_version}" "${version_args}"
    else
      __inf "${bldgrn}sym${clr} ${txtblu}is on the correct version ${bldylw}$(__lib::i-to-ver ${desired_version})${txtblu} already"
    fi
  else
    if [[ -z ${current_version} ]] ; then
      __inf "installing latest version of ${bldylw}sym..."
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
    [quiet]=''
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
    [install]='# N/A'
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

      -q|--quiet)
          shift
          cli__opts[quiet]="yes"
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
            __inf "Action ${bldylw}${sym__actions[${param}]}${clr} recognized"
            cli__opts[action]=${param}
          else
            __inf "Parameter ${bldylw}${param}${clr} is not a valid action"
            __inf "⇨  Interpreting it as a file pattern to search for..."
            cli__opts[file]=${1}
          fi
          shift
          ;;

      *) # Default case: If no more options then break out of the loop.
          break
          shift
    esac
  done

  [[ -n "${cli__opts[verbose]}" ]] && __symit::print_cli_args

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
  __symit::install::gem

  changed_count=0

  if [[ -n "${cli__opts[dry_run]}" ]] ; then
    __lib::color::h1 "DRY RUN"
    for file in $(__symit::files); do
      printf "   \$ ${bldblu}$(__symit::command ${file})${clr}\n"
    done
  else
    if [[ -n "${cli__opts[file]}" ]]; then
      [[ -n ${cli__opts[verbose]} ]] && __inf $(__symit::files)
      declare -a file_list

      for file in $(__symit::files); do
        __inf "❯ ${bldblu}$(__symit::command ${file})${clr}"
        local cmd="$(__symit::command ${file})"
        eval "${cmd}"
        code=$?; [[ ${code} != 0 ]] && __err "command '${bldblu}${cmd}${bldred}' exited with code ${bldylw}${code}"
        changed_count=$(( ${changed_count} + 1))
      done

      if [[ ${changed_count} == 0 ]]; then
        __inf "No files matched your specification. The following 'find' command"
        __inf "ran to find them: \n"
        __inf "   ${bldylw}$(__symit::files::cmd)${clr}\n\n"
        return $(__symit::exit 5)
      fi

    else # opts[file]
      [[ -n ${cli__opts[verbose]} ]] && __inf $(__symit::command)
      eval $(__symit::command)
      code=$?; [[ ${code} != 0 ]] && return $(__symits::exit ${code})
      changed_count=$(( ${changed_count} + 1))
    fi
  fi
}

function symit()  {
  __symit::run $@
}
