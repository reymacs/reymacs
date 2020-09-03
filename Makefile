PHONY: all clean vendor build list

# FIXME-QA: There is lots of duplicate code that is putting a strain on maintainance
# FIXME-QA: Readability of this file is horrible
# FIXME-TRANSLATE: Translate in other languages
# FIXME-CROSSPLATFORM: Make is problematic on windows, use elisp instead? [BRAINSTORM PRIOR TO IMPLEMENTATION!]

# Metadata
NAME ?= reymacs
VERSION = 0.0.0

# Directory overrides
BUILD ?= "$(PWD)/build"
VENDOR ?= vendor
DISTRO_DIR ?= src/distribution/
ZERNIT_ELISP_DIR ?= "$(VENDOR)/Zernit/src/RXT0112-1/downstream-classes/zeres-0/elisp/"

# Command overrides
READ ?= read
CHMOD ?= chmod
PRINTF ?= printf
EMACS ?= emacs
GREP ?= grep
SED ?= sed
CAT ?= cat
TRUE ?= true
MKDIR ?= mkdir
EXIT ?= exit
GIT ?= git
ED ?= ed
CP ?= cp
RM ?= rm
SH ?= sh
ENV ?= env
MAKE ?= make

KERNEL ?= $(shell uname -s)

#@ Default target invoked on 'make' (outputs syntax error on this project)
all:
	@ $(error Target 'all' is not allowed, use 'make list' to list available targets or read the 'Makefile' file)
	@ "$(EXIT)" 2

#@ List all targets
list:
	@ printf 'FIXME: %s\n' "Puts ': something' in the output, implement in a way that is comforming posix"
	@ "$(TRUE)" \
		&& "$(GREP)" -A 1 "^#@.*" Makefile | "$(SED)" s/--//gm | "$(SED)" "s/#@/#/gm" | while IFS= "$(READ)" -r line; do \
			case "$$line" in \
				"#"*|"") "$(PRINTF)" '%s\n' "$$line" ;; \
				*) "$(PRINTF)" '%s\n' "make $$line"; \
			esac; \
		done

#@ Remove temporary pathnames
clean:
	@ : "FIXME: Outputs: /bin/sh: 1: rm -f: not found if '$(RM)' is used"
	@ [ ! -d "$(BUILD)" ] || rm -rf "$(BUILD)"
	@ [ ! -d "$(VENDOR)" ] || rm -rf "$(VENDOR)"

#@ Get vendors
vendor: clean
	@ [ -d "$(VENDOR)" ] || "$(MKDIR)" "$(VENDOR)"
	@ [ -d "$$HOME/.cache/Zernit" ] || { true \
		&& printf '%s\n' "We need source code of the Zernit project <https://github.com/RXT0112/Zernit> on this repository. Can we cache it in '$$HOME/.cache/Zernit' so that it doesn't have to be cloned each build?" \
		&& read -r permissionToCache \
			&& [ "$$permissionToCache" != "yes" ] || "$(GIT)" clone https://github.com/RXT0112/Zernit "$$HOME/.cache/Zernit" \
			&& [ "$$permissionToCache" != "no" ] || true \
				&& printf '%s\n' "Zernit project won't be cached, cloning in vendor directory" \
				&& "$(GIT)" clone https://github.com/RXT0112/Zernit "$(VENDOR)/Zernit" ;}
	@ [ -d "$(VENDOR)/Zernit" ] || "$(CP)" -r "$$HOME/.cache/Zernit" "$(VENDOR)/Zernit"

#@ Build the distribution
build: clean vendor build-init-prepend build-codeblocks build-wrappers build-variables build-output build-init-append

#@ Build: Build the prepended part of init.el
build-init-prepend:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -f "$(BUILD)/$(NAME)/init.el" ] || "$(CAT)" "$(DISTRO_DIR)/00-init-prepend.el" | "$(SED)" "s/APPEND_DISTRO_NAME/$(NAME)/" > "$(BUILD)/$(NAME)/init.el"

#@ Build: Build the appended part of init.el
build-init-append:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ : "FIXME: Sanitize this step"
	@ "$(CAT)" "$(DISTRO_DIR)/00-init-append.el" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Codeblocks
build-codeblocks: build-codeblocks-find-emacs-dirs

#@ Build: Codeblock find-emacs-dirs
build-codeblocks-find-emacs-dirs:
	@ [ -d "$(BUILD)" ] || "$(MAKE)" build-init-prepend
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ "$(GREP)" -q "# find-emacs-dirs.el" "$(BUILD)/$(NAME)/init.el" || "$(CAT)" "$(DISTRO_DIR)/codeblocks/find-emacs-dirs.el" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output functions
build-output: build-output-die build-output-ewarn build-output-einfo build-output-eerror build-output-efixme build-output-edebug

#@ Build: Build output function die
build-output-die:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(build)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/die.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/die.el" "$(BUILD)/$(NAME)/output/die.el"
	@ [ -x "$(BUILD)/$(NAME)/output/die.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/die.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output function einfo
build-output-einfo:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/einfo.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/einfo.el" "$(BUILD)/$(NAME)/output/einfo.el"
	@ [ -x "$(BUILD)/$(NAME)/output/einfo.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/einfo.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output function ewarn
build-output-ewarn:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/ewarn.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/ewarn.el" "$(BUILD)/$(NAME)/output/ewarn.el"
	@ [ -x "$(BUILD)/$(NAME)/output/ewarn.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/ewarn.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output function ewarn
build-output-eerror:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/eerror.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/eerror.el" "$(BUILD)/$(NAME)/output/eerror.el"
	@ [ -x "$(BUILD)/$(NAME)/output/eerror.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/eerror.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output function ewarn
build-output-efixme:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/efixme.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/efixme.el" "$(BUILD)/$(NAME)/output/efixme.el"
	@ [ -x "$(BUILD)/$(NAME)/output/efixme.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/efixme.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build output function ewarn
build-output-edebug:
	@ [ -d "$(BUILD)" ] || "$(MKDIR)" "$(BUILD)"
	@ [ -d "$(BUILD)/$(NAME)" ] || "$(MKDIR)" "$(BUILD)/$(NAME)"
	@ [ -d "$(BUILD)/$(NAME)/output" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/output"
	@ [ -f "$(BUILD)/$(NAME)/output/edebug.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/edebug.el" "$(BUILD)/$(NAME)/output/edebug.el"
	@ [ -x "$(BUILD)/$(NAME)/output/edebug.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/output/edebug.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build readme file for output functions
build-output-readme:
	@ [ -f "$(BUILD)/$(NAME)/output/README.md" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/output/README.md" "$(BUILD)/$(NAME)/output/README.md"

## BUILD - VARIABLES ##

#@ Build: Build variables
build-variables: build-variables-emacs-log-file build-variables-emacs-debug build-variables-readme

#@ Build: Build variable emacs-debug
build-variables-emacs-debug:
	@ [ -d "$(BUILD)/$(NAME)/variables" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/variables"
	@ [ -f "$(BUILD)/$(NAME)/emacs-debug.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/variables/emacs-debug.el" "$(BUILD)/$(NAME)/variables/emacs-debug.el"
	@ [ -x "$(BUILD)/$(NAME)/emacs-debug.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/variables/emacs-debug.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build variable emacs-log-file
build-variables-emacs-log-file:
	@ [ -d "$(BUILD)/$(NAME)/variables" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/variables"
	@ [ -f "$(BUILD)/$(NAME)/emacs-log-file.el" ] || "$(CP)" "$(DISTRO_DIR)/variables/emacs-log-file.el" "$(BUILD)/$(NAME)/variables/emacs-log-file.el"
	@ [ -x "$(BUILD)/$(NAME)/emacs-log-file.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/variables/emacs-log-file.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build readme file for variables
build-variables-readme:
	@ [ -d "$(BUILD)/$(NAME)/variables" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/variables"
	@ [ -f "$(BUILD)/$(NAME)/variables/README.md" ] || "$(CP)" "$(DISTRO_DIR)/variables/README.md" "$(BUILD)/$(NAME)/variables/README.md"

## BUILD - WRAPPERS ##

#@ Build: Build wrapper functions
build-wrappers: build-wrappers-zn-defun build-wrappers-zn-defvar
	@ [ -f "$(BUILD)/$(NAME)/wrappers/README.md" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/wrappers/README.md" "$(BUILD)/$(NAME)/wrappers/README.md"

#@ Build: Build wrapper zn-defun
build-wrappers-zn-defun:
	@ [ -d "$(BUILD)/$(NAME)/wrappers" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/wrappers"
	@ [ -f "$(BUILD)/$(NAME)/wrappers/zn-defun.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/wrappers/zn-defun.el" "$(BUILD)/$(NAME)/wrappers/zn-defun.el"
	@ [ -x "$(BUILD)/$(NAME)/wrappers/zn-defun.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/wrappers/zn-defun.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

#@ Build: Build wrapper zn-defvar
build-wrappers-zn-defvar:
	@ [ -d "$(BUILD)/$(NAME)/wrappers" ] || "$(MKDIR)" "$(BUILD)/$(NAME)/wrappers"
	@ [ -f "$(BUILD)/$(NAME)/wrappers/zn-defvar.el" ] || "$(CP)" "$(ZERNIT_ELISP_DIR)/wrappers/zn-defvar.el" "$(BUILD)/$(NAME)/wrappers/zn-defvar.el"
	@ [ -x "$(BUILD)/$(NAME)/wrappers/zn-defvar.el" ] || "$(CHMOD)" +x "$(BUILD)/$(NAME)/wrappers/zn-defvar.el"
	@ true \
		&& myvar="$@" \
		&& export category="$$($(PRINTF) '%s\n' "$${myvar##??????}" | sed "s/-.*//")" \
		&& export function="$$($(PRINTF) '%s\n' "$${myvar##??????$$category?}")" \
		&& grep -q "(load (concat user-emacs-directory \"$$category/$$function.el\")" "$(BUILD)/$(NAME)/init.el" || "$(PRINTF)" '%s\n' "(load (concat user-emacs-directory \"$$category/$$function.el\"))" >> "$(BUILD)/$(NAME)/init.el"

## RUNTIME ##

#@ Runtime: Open emacs with distro release
runtime-emacs-gui: build
	@ "$(ENV)" EMACS_DIR="$(BUILD)/$(NAME)/" "$(EMACS)" -q --load "$(BUILD)/$(NAME)/init.el"

#@ Runtime: Run only the elisp script through emacs and output in terminal
runtime-emacs-script: build
	@ "$(ENV)" EMACS_DIR="$(BUILD)/$(NAME)/" "$(EMACS)" --script "$(BUILD)/$(NAME)/init.el"
