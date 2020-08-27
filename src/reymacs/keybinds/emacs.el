;; FIXME: Implement default emacs keybinds

if evil then
	define keys
elif viper then
	define Keys
else
	fatal error, unimplemented
fi
