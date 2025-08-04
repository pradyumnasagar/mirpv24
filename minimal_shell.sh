#
# A minimal BASH profile.
#
# Sets up the environment for miRPV.
#
# This file is sourced by the .bashrc file.
#
# Don't edit this file directly, it may be rewritten by the install script.
#

# ls uses different flags for colors on Mac and Linux
if [ "$(uname)" == "Darwin" ]; then
  alias ls='ls -hG'
else
  alias ls='ls -h --color=auto'
fi

# Safe versions of the default commands.
# Ask permissions before overwriting files.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Extend the program search PATH and add the ~/bin and ~/edirect folders.
export PATH=~/bin:~/edirect:$PATH

# Makes the prompt more user friendly: colors, hostname, path, etc.
export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '

# Necessary for the command line sort to work correctly.
export LC_ALL=C

# This is used on macOS to turn off zsh warning.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Alias conda and mamba to micromamba
alias mamba=micromamba
alias conda=micromamba
