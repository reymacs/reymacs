.PHONY: all clean vendor build list

NAME ?= reymacs

# Command overrides
EMACS ?= emacs
GREP ?= grep
SED ?= sed
READ ?= read
PRINTF ?= printf
TRUE ?= true
MKDIR ?= mkdir
EXIT ?= exit
GIT ?= git
ED ?= ed
CP ?= cp

#@ Default target invoked on 'make' (outputs syntax error on this project)
all:
	@ $(error Target 'all' is not allowed, use 'make list' to list available targets or read the 'Makefile' file)
	@ "$(EXIT)" 2

#@ List all targets
list:
	@ "$(TRUE)" \
		&& "$(GREP)" -A 1 "^#@.*" Makefile | "$(SED)" s/--//gm | "$(SED)" s/:.*//gm | "$(SED)" "s/#@/#/gm" | while IFS= "$(READ)" -r line; do \
			case "$$line" in \
				"#"*|"") "$(PRINTF)" '%s\n' "$$line" ;; \
				*) "$(PRINTF)" '%s\n' "make $$line"; \
			esac; \
		done

#@ Fetch 3rd party dependencies for maxx
maxx-vendor:
	@ [ -d vendor ] || "$(MKDIR)" vendor
	@ $(info Caching Zernit project\'s zeres-0 downstream class in '$$USER/.cache/' which is needed for maxx.sh functions)
	@ [ -d /home ] || "$(MKDIR)" /home
	@ [ -d "/home/$$USER" ] || "$(MKDIR)" "/home/$$USER"
	@ [ -d "/home/$$USER/.cache" ] || "$(MKDIR)" "/home/$$USER/.cache"
	@ [ -d "/home/$$USER/.cache/Zernit" ] || "$(GIT)" clone https://github.com/RXT0112/Zernit.git "/home/$$USER/.cache/Zernit"
	@ [ -d vendor/zernit ] || "$(CP)" -r "/home/$$USER/.cache/Zernit" vendor/zernit

###! We are using '#& APPEND something' in the code that is being replaced with a code from a vendor using ed

# FIXME-SUGGESTION: btw that tr command is pointless; also consider using «cmd | while read -r var» instead of «for var in $(cmd)»
# FIXME-SUGGESTION: @ while IFS= read -r line; do case "$$line" in '#& APPEND '*) cat "$${line##'#& APPEND '}" ;; *) printf '%s\n' "$$line" ;; esac; done < src/bin/dockervuantor.sh > build/dockervuantor.sh
# FIXME-QA: This creates additional 3 lines in between comment and '#% APPEND ...'
# FIXME: Implement these in a way that doesn't mess with EOF
# && : "Remove comments" \
# && printf "g/#.*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
# && : "Remove blank lines" \
# && printf "s/^$/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
#@ Build the maxx management script
maxx-build: maxx-clean maxx-vendor
	$(info Building..)
	@ [ -d build ] || mkdir build
	@ [ -f build/maxx.sh ] || cp src/maxx/bin/maxx.sh build/maxx.sh
	@ true \
		&& printf 'INFO: %s\n' "Replacing '#& APPEND path' with requested code" \
		&& grep "^#& APPEND.*" src/maxx/bin/maxx.sh | while IFS= read -r string; do \
				true \
				&& printf '%s\n' "Processing $${string##*/} from appended" \
				&& cp "$${string##\#& APPEND }" "vendor/$${string##*/}" \
				&& : "Remove shebang from appended code" \
				&& printf "g/^#!\/.*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
				&& : "Remove documentation comments from appended code" \
				&& printf "g/###! .*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
				&& : "Remove shellcheck directives from appended code" \
				&& printf "g/# shellcheck .*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
				&& : "Remove comments from appended code" \
				&& printf "g/^# .*/d\nw\nq\n" | ed -s "vendor/$${string##*/}" \
				&& : "Remove the first three blank lines if they are present (mostly they are)" \
				&& printf "1;/./-d\\nw\\nq\\n" | ed -s "vendor/$${string##*/}" \
				&& : "Replace '#& APPEND ...' with content from the file" \
				&& printf "/^#& APPEND $$(printf '%s\n' "$${string##\#& APPEND }" | sed "s#\/#\\\/#gm")/d\n-1r vendor/$${string##*/}\\nw\\nq\\n" | ed -s build/maxx.sh \
				&& printf '%s\n' "File '$$string' has been processed" \
			;done \
		&& printf '%s\n' "Replaced all mensioning of '#& APPEND path' with requested code"
	@ true \
		&& printf '%s\n' "Removing tag 'BUILD-CHECK' allowing the script to run" \
		&& printf '/^#& BUILD-CHECK/d\nd\nw\nq\n' | ed -s build/maxx.sh \
		&& printf '%s\n' "tag 'BUILD-CHECK' and it's relevant code has been removed"
	@ [ -x build/maxx.sh ] || chmod +x build/maxx.sh
	@ $(info Build phase for maxx finished)

#@ Clean all data that was generated
clean:
	@ [ -d vendor ] || rm -rf vendor
	@ [ -d build ] || rm -rf build

#@ Clean maxx dependencies
maxx-clean:
	@ [ ! -d vendor/zernit ] || rm -rf vendor/zernit
	@ [ ! -f build/maxx.sh ] || rm build/maxx.sh

# Emacs doesn't know how to use a different ~/.emacs.d/ directory so we have to use a docker
# Relevant: https://github.com/bradyt/docker-emacs/
#@ Test the distribution in emacs
runtime-test: maxx-build
	@ build/maxx.sh runtime-test

# --eval is evaluated after init.el (?)
#@ Tests the distribution in system emacs (experimental)
experimental-runtime-test:
	@ "$(EMACS)" -l "$$(pwd)/src/$(NAME)/init.el" --eval "(setq user-emacs-directory \"$$(pwd)/src/$(NAME)\")"
