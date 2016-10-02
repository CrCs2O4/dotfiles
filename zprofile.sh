# load shared shell configuration
source ~/.shprofile

# Enable completions
autoload -U compinit && compinit

if which brew &>/dev/null
then
  [ -w $BREW_PREFIX/bin/brew ] && \
    [ ! -f $BREW_PREFIX/share/zsh/site-functions/_brew ] && \
    mkdir -p $BREW_PREFIX/share/zsh/site-functions &>/dev/null && \
    ln -s $BREW_PREFIX/Library/Contributions/brew_zsh_completion.zsh \
          $BREW_PREFIX/share/zsh/site-functions/_brew
  export FPATH="$BREW_PREFIX/share/zsh/site-functions:$FPATH"
fi

# Enable regex moving
autoload -U zmv

# Style ZSH output
zstyle ':completion:*:descriptions' format '%U%B%F{red}%d%f%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Case insensitive globbing
setopt no_case_glob

# Expand parameters, commands and aritmatic in prompts
setopt prompt_subst

# Colorful prompt with Git and Subversion branch
autoload -U colors && colors

git_branch() {
  GIT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  [ -n "$GIT_BRANCH" ] && echo "($GIT_BRANCH) "
}

svn_branch() {
  [ -d .svn ] || return
  SVN_INFO=$(svn info 2>/dev/null) || return
  SVN_BRANCH=$(echo $SVN_INFO | grep URL: | grep -oe '\(trunk\|branches/[^/]\+\|tags/[^/]\+\)')
  [ -n "$SVN_BRANCH" ] || return
  # Display tags intentionally so we don't write to them by mistake
  echo "(${SVN_BRANCH#branches/}) "
}

if [ $USER = "root" ]
then
  PROMPT='%{$fg_bold[magenta]%}%m %{$fg_bold[blue]%}# %b%f'
elif [ -n "${SSH_CONNECTION}" ]
then
  PROMPT='%{$fg_bold[cyan]%}%m %{$fg_bold[blue]%}# %b%f'
else
  PROMPT='%{$fg_bold[green]%}%m %{$fg_bold[blue]%}# %b%f'
fi
RPROMPT='%{$fg_bold[red]%}$(git_branch)%{$fg_bold[yellow]%}$(svn_branch)%b[%{$fg_bold[blue]%}%~%b%f]'

# more OS X/Bash-like word jumps
export WORDCHARS=''

# use emacs bindings even with vim as EDITOR
bindkey -e

# fix backspace on Debian
[ $LINUX ] && bindkey "^?" backward-delete-char

# fix delete key on OSX
[ $OSX ] && bindkey "\e[3~" delete-char

# alternate mappings for Ctrl-U/V to search the history
bindkey "^u" history-beginning-search-backward
bindkey "^v" history-beginning-search-forward

export TERM="xterm-256color"

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# zplug "plugins/brew", from:oh-my-zsh, nice:10
# zplug "plugins/brew-cask", from:oh-my-zsh, nice:10
zplug "plugins/command-not-found", from:oh-my-zsh
# zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh, nice:10
zplug "plugins/osx", from:oh-my-zsh, nice:10
zplug "plugins/npm", from:oh-my-zsh
zplug "lukechilds/zsh-nvm"
zplug "zsh-users/zsh-autosuggestions", nice:10
zplug "zsh-users/zsh-syntax-highlighting", nice:18
zplug "lib/history", from:oh-my-zsh
zplug "zsh-users/zsh-history-substring-search", nice:19

# Theme.
setopt prompt_subst # Make sure propt is able to be generated properly.
zplug "caiogondim/bullet-train-oh-my-zsh-theme", use:bullet-train.zsh-theme
# zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
# # Theme config
# POWERLEVEL9K_MODE='awesome-patched'
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
# POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
# POWERLEVEL9K_STATUS_VERBOSE=false
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status os_icon load dir vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
# POWERLEVEL9K_SHOW_CHANGESET=true
# POWERLEVEL9K_CHANGESET_HASH_LENGTH=6

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
  zplug install
fi
# Then, source plugins and add commands to $PATH
zplug load
