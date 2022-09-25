if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

[ -z "$PS1" ] && return

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi
