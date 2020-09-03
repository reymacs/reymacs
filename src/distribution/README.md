This directory is used to generate `.emacs.d` directory

---

# Krey's emacs (reymacs)

I am a perfectionist and i want my code to be as close to the perfection as possible which is why this emacs distribution has been created.

Expecting the project to make it painless to use emacs for code development where by default it should be bare minimum for regular file editing with linting and ability to have a custom environment per project i.e using configuration directory alike `.theia/` directory in ![gitpod](https://gitpod.io) to allow defining a standard integrated development environment for contributors.

## Expected usecase

### Regular
Expecting environment for editing any file with bare-minimum linting and spell checking

End-user is expected to be allowed to do whatever they want with their emacs for this usecase where directory `.reymacs` or `editors/reymacs` is expected to overwrite this.

FIXME-DOCS: Define these directories into something more managable
End-user should have a method to install "permanent" packages or configuration in their `$XDG_CONFIG_HOME/reymacs` directory that overrides the `.reymacs` or `editors/reymacs`.

### Code development
Expected to be configured through either `editors/reymacs` or `.reymacs` directory in the root of gitted repository to allow project specific configuration.

Everything is expected to be done through emacs without the need to escape the editor

The directory should have a support for elisp, but is expected to have a user-friendly configuration file
