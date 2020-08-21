#!/bin/sh
# shellcheck shell=sh # Make to be POSIX-compatible

# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under all rights reserved in 17/08/2020 03:27:20 CEST

#& BUILD-CHECK
printf 'NOT_BUILT: %s\n' "This script is not built, refusing to run - Use 'make build' and reinvoke the script from build directory"; exit 88

###! Script designed to manage reymacs repository, because i have enough of Makefile

# Maintainer info
UPSTREAM="https://github.com/reymacs/reymacs"
UPSTREAM_NAME="reymacs"
UPSTREAM_EMAIL="reymacs@rixotstudio.cz"
MAINTAINER_EMAIL="kreyren@rixotstudio.cz"
MAINTAINER_NICKNAME="kreyren"
MAINTAINER_NAME="Jacob"
MAINTAINER_SURNAME="Hrbek"

## CONFIGURATION ##
# Allow the end-user to change used docker distribution
[ -n "$dockerImage" ] || dockerImage="silex/emacs:latest"

# FIXME-SUGGESTION: _=${var:="some text"} is less verbose and less error prone than [ -z "$var" ] && var="some text"

# Command overrides
## These may be required on some systems
[ -z "$PRINTF" ] && PRINTF="printf"
[ -z "$WGET" ] && WGET="wget"
[ -z "$CURL" ] && CURL="curl"
[ -z "$ARIA2C" ] && ARIA2C="aria2c"
[ -z "$CHMOD" ] && CHMOD="chmod"
[ -z "$UNAME" ] && UNAME="uname"
[ -z "$TR" ] && TR="tr"
[ -z "$SED" ] && SED="sed"
[ -z "$GREP" ] && GREP="grep"
[ -z "$EMACS" ] && EMACS="emacs"
[ -z "$DOCKER" ] && DOCKER="docker"
[ -z "$COMMAND" ] && COMMAND="command"

# Customization of the output
## efixme
[ -z "$EFIXME_FORMAT_STRING" ] && EFIXME_FORMAT_STRING="FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_LOG" ] && EFIXME_FORMAT_STRING_LOG="${logPrefix}FIXME: %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG" ] && EFIXME_FORMAT_STRING_DEBUG="FIXME($myName:$LINENO): %s\n"
[ -z "$EFIXME_FORMAT_STRING_DEBUG_LOG" ] && EFIXME_FORMAT_STRING_DEBUG_LOG="${logPrefix}FIXME($myName:$LINENO): %s\n"
## eerror
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$0): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$0): %s\n"
## edebug
[ -z "$EERROR_FORMAT_STRING" ] && EERROR_FORMAT_STRING="ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_LOG" ] && EERROR_FORMAT_STRING_LOG="${logPrefix}ERROR: %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG" ] && EERROR_FORMAT_STRING_DEBUG="ERROR($myName:$0): %s\n"
[ -z "$EERROR_FORMAT_STRING_DEBUG_LOG" ] && EERROR_FORMAT_STRING_DEBUG_LOG="${logPrefix}ERROR($myName:$0): %s\n"
## einfo
[ -z "$EINFO_FORMAT_STRING" ] && EINFO_FORMAT_STRING="INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_LOG" ] && EINFO_FORMAT_STRING_LOG="${logPrefix}INFO: %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG" ] && EINFO_FORMAT_STRING_DEBUG="INFO($myName:$0): %s\n"
[ -z "$EINFO_FORMAT_STRING_DEBUG_LOG" ] && EINFO_FORMAT_STRING_DEBUG_LOG="${logPrefix}INFO($myName:$0): %s\n"
## die
### Generic
[ -z "$DIE_FORMAT_STRING" ] && DIE_FORMAT_STRING="FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}FATAL: %s in script '$myName' located at '$0'\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="FATAL($myName:$1): %s\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s\\n"
### Success trap
[ -z "$DIE_FORMAT_STRING_SUCCESS" ] && DIE_FORMAT_STRING_SUCCESS="SUCCESS: Script '$myName' located at '$0' finished successfully\\n"
[ -z "$DIE_FORMAT_STRING_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}$DIE_FORMAT_STRING_SUCCESS"
[ -z "$DIE_FORMAT_STRING_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="SUCCESS($myName:$1): Script '$myName' located at '$0' finished successfully\\n"
[ -z "$DIE_FORMAT_STRING_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_DEBUG_LOG"
### Syntax error (syntaxerr) trap
[ -z "$DIE_FORMAT_STRING_SYNTAXERR" ] && DIE_FORMAT_STRING_SYNTAXERR="SyntaxErr: Invalid argument(s) '$0' '$1' '$2' '$3' '$4' has been provided to $myName\\n"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_LOG" ] && DIE_FORMAT_STRING_LOG="${logPath}$DIE_FORMAT_STRING_SUCCESS"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_DEBUG" ] && DIE_FORMAT_STRING_DEBUG="SyntaxErr($myName:$1): Invalid argument(s) '$0' '$1' '$2' '$3' '$4' has been provided to $myName\\n"
[ -z "$DIE_FORMAT_STRING_SYNTAXERR_DEBUG_LOG" ] && DIE_FORMAT_STRING_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_DEBUG_LOG"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$1): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s, fixme?\\n"
### Bug Trap
[ -z "$DIE_FORMAT_STRING_BUG" ] && DIE_FORMAT_STRING_BUG="BUG: Unexpected happend while processing %s in script '$myName' located at '$0'\\n\\nIf you think that this is a bug, the report it to $UPSTREAM to @$MAINTAINER_NICKNAME with output from $logPath for relevant runtime"
[ -z "$DIE_FORMAT_STRING_BUG_LOG" ] && DIE_FORMAT_STRING_BUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG" ] && DIE_FORMAT_STRING_BUG_DEBUG="BUG:($myName:$1): ${DIE_FORMAT_STRING_BUG%%BUG:}"
[ -z "$DIE_FORMAT_STRING_BUG_DEBUG_LOG" ] && DIE_FORMAT_STRING_BUG_DEBUG_LOG="${logPrefix}$DIE_FORMAT_STRING_BUG_DEBUG"
### Fixme trap
[ -z "$DIE_FORMAT_STRING_FIXME" ] && DIE_FORMAT_STRING_FIXME="FATAL: %s in script '$myName' located at '$0', fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_LOG" ] && DIE_FORMAT_STRING_FIXME_LOG="${logPrefix}FATAL: %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG" ] && DIE_FORMAT_STRING_FIXME_DEBUG="FATAL($myName:$1): %s, fixme?\n"
[ -z "$DIE_FORMAT_STRING_FIXME_DEBUG_LOG" ] && DIE_FORMAT_STRING_FIXME_DEBUG_LOG="${logPrefix}FATAL($myName:$1): %s, fixme?\\n"
### Unexpected trap
[ -z "$DIE_FORMAT_STRING_UNEXPECTED" ] && DIE_FORMAT_STRING_UNEXPECTED="FATAL: Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_LOG="${logPrefix}FATAL: Unexpected happend while %s\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="FATAL($myName:$1): Unexpected happend while %s in $myName located at $0\\n"
[ -z "$DIE_FORMAT_STRING_UNEXPECTED_DEBUG_LOG" ] && DIE_FORMAT_STRING_UNEXPECTED_DEBUG="${logPrefix}FATAL($myName:$1): Unexpected happend while %s\\n"
# elog
[ -z "$ELOG_FORMAT_STRING_DEBUG_LOG" ] && ELOG_FORMAT_STRING_DEBUG_LOG="${logPrefix}LOG: %s\\n"
# ebench
[ -z "$EBENCH_FORMAT_STRING_START" ] && EBENCH_FORMAT_STRING_START="BENCHMARK: Starting benchmark for action %s\n"
[ -z "$EBENCH_FORMAT_STRING_RESULT" ] && EBENCH_FORMAT_STRING_RESULT="BENCHMARK: Action %s took $SECONDS seconds\n"
# invoke_privileged
[ -z "$INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION" ] && INVOKE_PRIVILEGED_FORMAT_STRING_QUESTION="### PRIVILEGED ACCESS REQUEST ###\n\n\s\n"

# Exit on anything unexpected
set -e

# NOTICE(Krey): By default busybox outputs a full path in '$0' this is used to strip it
myName="${0##*/}"

# Used to prefix logs with timestemps, uses ISO 8601 by default
logPrefix="[ $(date -u +"%Y-%m-%dT%H:%M:%SZ") ] "
# Path to which we will save logs
# NOTICE(Krey): To avoid storing file '$HOME/.some-name.sh.log' we are stripping the '.sh' here
# FIXME-QA: Make sure the the directory path is present or this fails
# FIXME-COMPAT: Make sure this works on Windows and Darwin
logPath="${XDG_DATA_HOME:-$HOME/.local/share}/${myName%%.sh}.log"

# inicialize the script in logs
# FIXME: Allow end-users to customize this
"$PRINTF" '%s\n' "Started $myName on $("$UNAME" -s) at $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$logPath"

# DIE
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/die.sh

# EINFO
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/einfo.sh

# EERROR
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/eerror.sh

# EFIXME
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/efixme.sh

# EDEBUG
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/output/edebug.sh

# cmd_check - check wether the command is executable else exits with a nice message
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/wrappers/cmd_check.sh

# invoke_privileged - Wrapper for sane root elevation
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/wrappers/invoke_privileged.sh

# Assign HOSTNAME variable if needed
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/identifiers/hostname.sh

# Identify system - Logic used to identify the system
#& APPEND vendor/zernit/src/RXT0112-1/downstream-classes/zeres-0/bash/identifiers/operating-system.sh

# DNM: HOTFIX!
privileged="false"

while [ "$#" -gt 0 ]; do case "$1" in
	runtime-test) # Test emacs in runtime without altering the system
		case "$KERNEL" in
			linux)
				case "$("$EMACS" --version | head -n1)" in
					*)
						einfo "As of 17/08/2020 emacs doesn't know how to use a different ~/.emacs.d directory thus we are using a docker"

						cmd_check "$DOCKER"

						# Run the reymacs in non-persistent environment (using docker)
						case "$dockerImage" in
							"silex/emacs:latest")
									invoke_privileged docker run -it -v "$(pwd)/src/bin/$UPSTREAM_NAME:/tmp/$UPSTREAM_NAME" "$dockerImage"
									die true "Logically determined that the argument '$1' finished successfully"
							;;
							"debian:latest")
								[ -n "$USER" ] || ewarn "Environment variable 'USER' is storing a blank variable which is unexpected, using 'unknown' used in docker environment to avoid fatal failure"

								# DNM: Add repository path for our emacs.d
								invoke_privileged docker run -it -v "$(pwd)/src/bin/$UPSTREAM_NAME:/tmp/$UPSTREAM_NAME" "$dockerImage" bash -c "true \
									&& printf '%s\n' \"Configuring docker environment..\" \
									&& : Create the user to invoke emacs from \
									&& useradd -m -G sudo ${USER:-unknown} \
									&& : Update repositories to install emacs \
									&& apt-get update -y \
									&& : Install Emacs \
									&& apt-get install -y emacs \
									&& : Remove the ~/.emacs.d of the user if it exists so that it can be replaced with ours \
									&& { [ ! -d \"/home/${USER:-unknown}/.emacs.d\" ] || rm -r \"/home/${USER:-unknown}/.emacs.d\" ;} \
									&& : Import $UPSTREAM_NAME \
									&& mv \"/tmp/$UPSTREAM_NAME\" \"/home/${USER:-unknown}/.emacs.d\" \
									&& su \"${USER:-unknown}\" -c emacs \
									"

								die true "Logically determined that the argument '$1' finished successfully"
							;;
							*)
								die fixme "Docker image '$dockerImage' is not implemented, unable to test $UPSTREAM_NAME in docker environment"
						esac
				esac
			;;
			*) die fixme "script $myName is not implemented to run on kernel '$KERNEL'"
		esac
	;;
esac; done
