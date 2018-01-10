#!/usr/bin/env bash
#
# (c) 2017-2018 Konstantin Gredeskoul
#
# MIT License, distributed as part of `sym` ruby gem.
# • https://github.com/kigster/sym
#
#==============================================================================
#
# The purpose of this script is to transparently edit application secrets in
# Rails apps or other projects. It simplifies the process of key import, as well
# as the direct editing, as well as multi-file encryption/decryption routines.
#
# The idea is that you set some of the variables below to values specific to your
# system and working with encrypted files will become very easy.
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
#     export SYMIT__KEY="my-org.engineering.dev" # just a name
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


# Check if we are being sourced in, or run as a script:
(   [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
    [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && _s_=1 || _s_=0

(( $_s_ )) && _is_sourced=1
(( $_s_ )) || _is_sourced=0

# Set all the defaults
function __symit::init()  {
  export SYMIT__EXTENSION=${SYMIT__EXTENSION:-'.enc'}
  export SYMIT__FOLDER=${SYMIT__FOLDER:-'.'}
  export SYMIT__KEY=${SYMIT__KEY}
  export SYMIT__MIN_VERSION='latest'
}

# Returns name of the current shell, eg 'bash'
function __lib::shell::name() {
  echo $(basename $(printf $SHELL))
}

# Returns 'yes' if current shell is BASH
function __lib::shell::is_bash() {
  [[ $(__lib::shell::name) == "bash" ]] && echo yes
}

# Returns a number representing shell version, eg.
# 3 or 4 for BASH v3 and v4 respectively.
function __lib::bash::version_number() {
  echo $BASH_VERSION | awk 'BEGIN{FS="."}{print $1}'
}

# Enable all colors, but only if the STDOUT is a terminal
function __lib::color::setup()  {
  if [[ -t 1 ]]; then
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
  fi
}

# Unset all the colors, in case we a being piped into
# something else.
function __lib::color::reset()  {
  export txtblk=
  export txtred=
  export txtgrn=
  export txtylw=
  export txtblu=
  export txtpur=
  export txtcyn=
  export txtwht=

  export bldblk=
  export bldred=
  export bldgrn=
  export bldylw=
  export bldblu=
  export bldpur=
  export bldcyn=
  export bldwht=

  export unkblk=
  export undred=
  export undgrn=
  export undylw=
  export undblu=
  export undpur=
  export undcyn=
  export undwht=

  export bakblk=
  export bakred=
  export bakgrn=
  export bakylw=
  export bakblu=
  export bakpur=
  export bakcyn=
  export bakwht=

  export clr=
  export txtrst=
  export rst=
}

# Enable or disable the colors based on whether the STDOUT
# is a proper terminal, or a pipe.
function __lib::stdout::configure() {
  if [[ -t 1 ]]; then
    __lib::color::setup
  else
    __lib::color::reset
  fi
}

__lib::stdout::configure

# Check if we are being run as a script, and if so — bail.
(( $_s_ )) || {
  printf "${bldred}This script is meant to be sourced into your environment,\n"
  printf "not run on a command line.${clr} \n\n"

  printf "Please add 'source $0' to your BASH initialization file,\n"
  printf "or run the following command:\n\n"

  printf "    \$ ${bldgrn}sym -B ~/.bash_profile${clr}\n\n"

  printf "${bldblu}Thanks for using Sym!${clr}\n"
  exit 1
}

# Horizontal line, width of the full terminal
function __lib::color::hr()  {
  local cols=${1:-${COLUMNS}}
  local char=${2:-"—"}
  local color=${3:-${txtylw}}

  printf "${color}"
  eval "printf \"%0.s${char}\" {1..${cols}}"
  printf "${clr}\n"
}

# Large header, all caps
function __lib::color::h1()  {
  local title=$(echo "$*" | tr 'a-z' 'A-Z')
  len=${#title}
  printf "${bldylw}${title}\n"
  __lib::color::hr ${len} '─'
}

# Smaller header
function __lib::color::h2()  {
  printf "${bldpur}$*${clr}\n"
}

# Shift cursor by N positions to the right
function __lib::color::cursor-right-by()  {
  position=$1
  printf "\e[${position}C"
}

# Shift cursor by N positions to the left
function __lib::color::cursor-left-by()  {
  position=$1
  printf "\e[${position}D"
}

# Shift cursor by N positions up
function __lib::color::cursor-up-by()  {
  position=$1
  printf "\e[${position}A"
}

# Shift cursor by N positions down
function __lib::color::cursor-down-by()  {
  position=$1
  printf "\e[${position}B"
}

# Convert a version string such as "1.50.17" to an integer
# 101050017 for numeric comparison:
function __lib::ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

# Convert a result of __lib::ver-to-i() back to a regular version.
function __lib::i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

# Prints Usage
function __symit::usage()  {
  echo
  __lib::color::h1 "symit"

  printf "
  ${bldylw}symit${bldgrn} is a powerful BASH helper, that enhances the CLI encryption
  tool called ${bldred}Sym${clr}, which is a Ruby Gem.

  Sym has an extensive CLI interface, but it only handles one
  encryption/decryption operation per invocation. With this script, you can
  auto decrypt all files in a given folder, you can import the key in a
  simpler way, and you can save into the environment sym configuration that
  will be used. It also streamlines editing of encrypted files in a given
  folder. Symit can be configured either with the ENV variables, or using
  the CLI flags.\n"

  printf "
  The recommended way to use ${bldred}symit${clr} is to set the following
  environment variables, which removes the need to pass these values via the
  flags. These variables default to the shown values if not set elsewhere:

  Perhaps the most critically important variable to set is ${txtylw}SYMIT__KEY${clr}:
  ${txtylw}
       export SYMIT__KEY='my-org.my-app.dev'
   eg: export SYMIT__KEY='github.web.development' 
  ${clr}
  The ${txtcya}key${clr} can resolve to a file name, or a name of ENV variable,
  a keychain entry, or be the actual key (not recommended!). See the following
  link for more info:

  ${undblu}https://github.com/kigster/sym#resolving-the--k-argument${clr}

  Additional configuration is available through these variables:
  ${txtylw}
     export SYMIT__EXTENSION='${SYMIT__EXTENSION}'
     export SYMIT__FOLDER='${SYMIT__FOLDER}'
     export SYMIT__MIN_VERSION='latest'
  ${clr}
  The last variable defines the minimum Sym version desired. Set it to
  'latest' to have symit auto-upgrade Sym every time it is invoked.

  ${clr}\n"

  __lib::color::h2 "Usage:"
  printf "    ${bldgrn}symit [ action ] [ file-path/pattern ] [ flags ]${clr}\n\n"

  __lib::color::h2 "Actions:"
  printf "    Action is the first word that defaults to ${bldylw}edit${clr}.\n\n"
  printf "    ${bldcya}Valid actions are below, starting with the Key import or creation:${clr}\n\n"
  printf "    ${bldylw}— generate      ${clr}create a new secure key, and copies it to the\n"
  printf "                    clipboard (if supported), otherwise prints to STDOUT\n"
  printf "                    Key name (set via SYMIT__KEY or -k flag) is required,\n"
  printf "                    and is used as the KeyChain entry name for the new key.\n\n"
  printf "    ${bldylw}— import [insecure]\n"
  printf "                    ${clr}imports the key from clipboard and adds password\n"
  printf "                    encryption unless 'insecure' is passed in. Same as above\n"
  printf "                    in relation with the key parameter.\n\n"
  printf "    ${bldcya}The following actions require the file pattern/path argument:${clr}\n"
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
  printf "    -a | --all-files       ${clr}If provided ALL FILES are operated on${clr}\n"
  printf "                           ${clr}Use with CAUTION!${clr}\n"
  printf "    -v | --verbose         ${clr}Print more stuff${clr}\n"
  printf "    -q | --quiet           ${clr}Print less stuff${clr}\n"
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

  printf "  To import a key securely, first copy the key to your clipboard,\n"
  printf "  and then run the following command, pasting the key when asked:\n\n"
  printf "     ❯ ${bldgrn}symit${bldblu} import key ${clr}\n\n"

  printf "  To encrypt or decrypt ALL files in the 'config' directory:${clr}\n\n"
  printf "     ❯ ${bldgrn}symit${bldblu} encrypt|decrypt -a -f config ${clr}\n\n"

  printf "  To decrypt all *.yml.enc files in the 'config' directory:${clr}\n\n"
  printf "     ❯ ${bldgrn}symit${bldblu} decrypt '*.yml' -f config ${clr}\n\n"

  printf "  To edit an encrypted file ${txtblu}config/application.yml.enc${clr}\n\n"
  printf "     ❯ ${bldgrn}symit${bldblu} application.yml${clr}\n\n"

  printf "  To auto decrypt a file ${txtblu}config/settings/crypt/pass.yml.enc${clr}\n\n"
  printf "     ❯ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  To automatically decide to either encrypt or decrypt a file,\n"
  printf "  based on the file extension use 'auto' command. The first line below\n"
  printf "  encrypts the file, second decrypts it, because the file extension is .enc:${clr}\n\n"

  printf "     ❯ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml${clr}\n"
  printf "     ❯ ${bldgrn}symit${bldblu} auto config/settings/crypt/pass.yml.enc${clr}\n\n"

  printf "  To encrypt a file ${txtblu}config/settings.yml${clr}\n"
  printf "     ❯ ${bldgrn}symit${bldblu} encrypt config/settings.yml${clr}\n\n"
}

function __datum()   {
  date +"%m/%d/%Y.%H:%M:%S"
}

function __warn()  {
  __lib::color::cursor-left-by 1000
  printf "${bldylw}$* ${bldylw}\n"
}
function __err()  {
  __lib::color::cursor-left-by 1000
  printf "${bldred}ERROR: ${txtred}$* ${bldylw}\n"
}

function __inf()  {
  [[ ${cli__opts__quiet} ]] && return
  __lib::color::cursor-left-by 1000
  printf "${txtblu}$*${clr}\n"
}

function __dbg()  {
  [[ ${cli__opts__verbose} ]] || return
  __lib::color::cursor-left-by 1000
  printf "${txtgrn}$*${clr}\n"
}

function __lib::command::print() {
  __inf "${bldylw}❯ ${bldcya}$*${clr}"
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
  __inf "sym version ${bldylw}$(__lib::i-to-ver ${current_version}) was successfully installed."
}

function __symit::install::gem()  {
  if [[ -n ${__symit_last_checked_at} ]]; then
    now=$(date +'%s')
    if [[ $(( $now - ${__symit_last_checked_at} )) -lt 3600 ]]; then
      return
    fi
  fi

  export __symit_last_checked_at=${now:-$(date +'%s')}

  __inf "Verifying current sym version, please wait..."
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
      __dbg "installing latest version of ${bldylw}sym..."
    fi
  fi
}

function __symit::files()  {
  eval $(__symit::files::cmd)
}

function __symit::files::cmd() {
  if [[ -n ${cli__opts__file} && -n ${cli__opts__extension} ]]; then
    local folder
    if [[ ${cli__opts__file} =~ '/' ]]; then
      folder="${cli__opts__folder}/$(dirname ${cli__opts__file})"
    else
      folder="${cli__opts__folder}"
    fi
    local file="$(basename ${cli__opts__file})"
    local ext="${cli__opts__extension}"

    if [[ "${cli__opts__action}" == "auto" || "${cli__opts__action}" == "encrypt" ]] ; then
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
  if [[ -n "${cli__opts__key}" && -n "${cli__opts__extension}" ]]; then
    action="${cli__opts__action}"
    v="sym__actions__${action}"
    flags="${!v}"
    if [[ ${action} =~ "key" ]]; then
      [[ -n ${cli__opts__verbose} ]] && printf "processing key import action ${bldylw}${action}${clr}\n" >&2
      printf "sym ${flags} ${cli__opts__key} "
    elif [[ ${action} =~ "generate" ]] ; then
      [[ -n ${cli__opts__verbose} ]] && printf "processing generate key action ${bldylw}${action}${clr}\n" >&2
      if [[ -n $(which pbcopy) ]]; then
        out_key=/tmp/outkey
        command="sym ${flags} ${cli__opts__key} -q -o ${out_key}; cat ${out_key} | pbcopy; rm -f ${out_key}"
        printf "${command}"
      else
        printf "sym ${flags} ${cli__opts__key} "
      fi
    elif [[ -n ${file} ]] ; then
      ext="${cli__opts__extension}"
      [[ -z ${ext} ]] && ext='.enc'
      ext=$(echo ${ext} | sed -E 's/[\*\/,.]//g')
      if [[ ${action} =~ "encrypt" ]]; then
        printf "sym ${flags} ${file} -ck ${cli__opts__key} -o ${file}.${ext}"
      elif [[ ${action} =~ "decrypt" ]]; then
        new_name=$(echo ${file} | sed "s/\.${ext}//g")
        [[ "${new_name}" == "${file}" ]] && name="${file}.decrypted"
        printf "sym ${flags} ${file} -ck ${cli__opts__key} -o ${new_name}"
      else
        printf "sym ${flags} ${file} -ck ${cli__opts__key} "
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
  __dbg "action     ${bldylw}: ${cli__opts__action}${clr}"
  __dbg "key        ${bldylw}: ${cli__opts__key}${clr}"
  __dbg "file       ${bldylw}: ${cli__opts__file}${clr}"
  __dbg "extension  ${bldylw}: ${cli__opts__extension}${clr}"
  __dbg "folder     ${bldylw}: ${cli__opts__folder}${clr}"
  __dbg "verbose    ${bldylw}: ${cli__opts__verbose}${clr}"
  __dbg "dry_run    ${bldylw}: ${cli__opts__dry_run}${clr}"
}

function __symit::args::needs_file()  {
  if [[ "${cli__opts__action}" == 'edit' || \
  "${cli__opts__action}" == 'auto' || \
  "${cli__opts__action}" == 'encrypt' || \
  "${cli__opts__action}" == 'decrypt' ]]; then
    printf 'yes'
  fi
}

function __symit::validate_args()  {
  if [[ -n $(__symit::args::needs_file) && -z ${cli__opts__file} ]]; then
    __err "missing file argument, config/application.yml"
    return $(__symit::exit 2)
  fi

  if [[ -z "${cli__opts__key}" ]]; then
    __err "Key was not defined, pass it with ${bldblu}-k KEY_ID${bldred}"
    __err "or set it via ${bldgrn}\$SYMIT__KEY${bldred} variable."
    return $(__symit::exit 4)
  fi

  if [[ -z ${cli__opts__extension} ]]; then
    cli__opts__extension='.enc'
  fi
}

function __symit::run()  {
  __symit::cleanup
  __symit::init

  cli__opts__verbose=''
  cli__opts__quiet=''
  cli__opts__key=${SYMIT__KEY}
  cli__opts__extension=${SYMIT__EXTENSION}
  cli__opts__folder=${SYMIT__FOLDER}
  cli__opts__dry_run=''
  cli__opts__action=edit
  cli__opts__file=''

  sym__actions__generate=' -cpgx '
  sym__actions__edit=' -t '
  sym__actions__encrypt='-e -f '
  sym__actions__decrypt='-d -f '
  sym__actions__auto=' -n '
  sym__actions__key_secure=' -iqcpx '
  sym__actions__key_insecure=' -iqcx '
  sym__actions__install='install'

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
            cli__opts__key=$1
            shift
          fi
          ;;

      -x|--extension)
          shift
          if [[ -z $1 ]]; then
            __err "-x/--extension requires an argument" && return $(__symit::exit 1)
          else
            cli__opts__extension=${1}
            shift
          fi
          ;;

      -f|--folder)
          shift
          if [[ -z $1 ]]; then
            __err "-f/--folder requires an argument" && return $(__symit::exit 1)
          else
            cli__opts__folder=${1}
            shift
          fi
          ;;

      -a|--all-files)
          shift
          cli__opts__file="'*'"
          ;;

      -n|--dry-run)
          shift
          cli__opts__dry_run="yes"
          ;;

      -v|--verbose)
          shift
          cli__opts__verbose="yes"
          ;;

      -q|--quiet)
          shift
          cli__opts__quiet="yes"
          ;;

      import|key)
          shift
          cli__opts__action="key_secure"
          ;;

      insecure)
          shift
          if [[ "${cli__opts__action}" == 'key_secure' ]] ; then
            cli__opts__action="key_insecure"
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
          v="sym__actions__${param}"
          if [[ ! ${param} =~ '.' && -n "${!v}" ]]; then
            __dbg "Action ${bldylw}${param}${clr} is a valid action."
            cli__opts__action=${param}
          else
            __dbg "Parameter ${bldylw}${param}${clr} is not a valid action,"
            __dbg "therefore it must be a file pattern."
            cli__opts__file=${1}
          fi
          shift
          ;;

      *) # Default case: If no more options then break out of the loop.
          break
          shift
    esac
  done

  [[ -n "${cli__opts__verbose}" ]] && __symit::print_cli_args

  if [[ "${cli__opts__action}" == 'install' ]]; then
    if [[ -n ${cli__opts__dry_run} ]]; then
      __dbg "This command verifies that Sym is properly installed,"
      __dbg "and if not found — installs it."
      return $(__symit::exit 0)
    else
      __symit::install::gem
      return $(__symit::exit 0)
    fi
  fi

  __symit::validate_args

  code=$?
  if [[ ${code} != 0 ]]; then
    return $(__symit::exit ${code})
  fi

  __symit::install::gem

  changed_count=0

  if [[ -n "${cli__opts__dry_run}" ]] ; then
    __lib::color::h1 "DRY RUN"
    for file in $(__symit::files); do
      printf "   \$ ${bldblu}$(__symit::command ${file})${clr}\n"
    done
  else
    if [[ -n "${cli__opts__file}" ]]; then
      [[ -n ${cli__opts__verbose} ]] && __dbg $(__symit::files)
      declare -a file_list

      for file in $(__symit::files); do
        local cmd="$(__symit::command ${file})"
        __lib::command::print "${cmd}"
        eval "${cmd}"
        code=$?; [[ ${code} != 0 ]] && __err "command '${bldblu}${cmd}${bldred}' exited with code ${bldylw}${code}"
        changed_count=$(( ${changed_count} + 1))
      done

      if [[ ${changed_count} == 0 ]]; then
        printf "${undylw}Bad news:${clr}\n\n"
        __warn "  No files matched your specification. The following 'find' command"
        __warn "  ran to find the file you requested. Please change the name, and "
        __warn "  try again.\n"
        __warn "   ${bldblu}$(__symit::files::cmd)${clr}\n\n"
        return $(__symit::exit 5)
      fi

    else # opts[file]
      cmd=$(__symit::command)
      __lib::command::print "${cmd}"
      eval "${cmd}"
      code=$?; [[ ${code} != 0 ]] && return $(__symit::exit ${code})
      changed_count=$(( ${changed_count} + 1))
    fi
  fi
}

function symit()  {
  __lib::stdout::configure
  __symit::run $@
}
