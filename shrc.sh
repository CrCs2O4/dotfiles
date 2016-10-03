#!/bin/sh
# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Print field by number
field() {
  ruby -ane "puts \$F[$1]"
}

# Setup paths
remove_from_path() {
  [ -d $1 ] || return
  # Doesn't work for first item in the PATH but I don't care.
  export PATH=$(echo $PATH | sed -e "s|:$1||") 2>/dev/null
}

add_to_path_start() {
  [ -d $1 ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  which $1 &>/dev/null
}

add_to_path_end "$HOME/Documents/Scripts"
add_to_path_end "$HOME/Documents/Scripts/thirdparty"
add_to_path_end "$HOME/Scripts"
add_to_path_end "$HOME/Scripts/thirdparty"
add_to_path_end "$HOME/Library/Python/2.7/bin"
add_to_path_end "$HOME/.gem/ruby/2.1.0/bin"
add_to_path_end "$HOME/.gem/ruby/2.0.0/bin"
add_to_path_end "$HOME/.gem/ruby/1.8/bin"
add_to_path_end "$HOME/.rbenv/bin"
add_to_path_end "$HOME/.cabal/bin"
add_to_path_end "/Applications/GitX.app/Contents/Resources"
add_to_path_end "/Applications/TextMate.app/Contents/Resources"
add_to_path_end "/Applications/GitHub.app/Contents/MacOS"
add_to_path_end "/data/github/shell/bin"
add_to_path_start "/usr/local/bin"
add_to_path_start "/usr/local/sbin"
add_to_path_start "$HOME/Homebrew/bin"
add_to_path_start "$HOME/Homebrew/sbin"

# Run rbenv if it exists
quiet_which rbenv && add_to_path_start "$(rbenv root)/shims"

# Aliases
alias mkdir="mkdir -vp"
alias df="df -H"
alias rm="rm -iv"
alias mv="mv -iv"
alias zmv="noglob zmv -vW"
alias cp="cp -irv"
alias du="du -sh"
alias make="nice make"
alias less="less --ignore-case --raw-control-chars"
alias rsync="rsync --partial --progress --human-readable --compress"
alias rake="noglob rake"
alias be="noglob bundle exec"
alias gist="gist --open --copy"
alias svn="svn-git.sh"
alias sha256="shasum -a 256"
alias ack="ag"
alias z="zeus"
alias zt="zeus test"
# Enable color support
ls --color -d . &> /dev/null && alias ls='ls --color=auto' || alias ls='ls -G'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# clean trash
alias trash='rm -rf ~/.Trash && sudo rm -rf /Volumes/*/.Trashes'

alias als='subl ~/.dotfiles/shrc.sh'
alias subl="open -a 'Sublime Text'"

alias c="clear" # Typing the whole word is annoying
alias h="cd ~/" # Go home
# alias bru='brew update; brew upgrade; brew cleanup; brew doctor'
alias bru='brew -v update; brew -v upgrade --all; brew cleanup; brew cask cleanup; brew -v prune; brew doctor'

# vagrant
alias v='vagrant version && vagrant global-status'
alias vst='vagrant status'
alias vup='vagrant up'
alias vdo='vagrant halt'
alias vssh='vagrant ssh'
alias vkill='vagrant destroy'

# vip-quickstart
# alias vip='function __vip() { (cd ~/Documents/vip-quickstart/ && vagrant $*); unset -f __vip; }; __vip'
# alias vipup='appcatalyst-daemon start & vip reload'

# alias rbp='cat ~/.mackup/dotrbp | osascript'
# alias rsp='cat ~/.mackup/dotrsp | osascript'
# alias rqp='killall osascript'
# alias rwp='ps auxw | grep osascript'
# alias ral='rqp && rbp & rsp & clear'
# alias rbo='rqp && rbp & clear'

# get application bundle identifier using duti
app_id () {
    APPS=`find /Applications -maxdepth 1 -type d -iname "*$1*"`
    APP=`find /Applications -maxdepth 1 -type d -iname "*$1*" | head -n1`
    if [ "$APP" != "$APPS" ]
    then
        # found couple apps
        find /Applications -maxdepth 1 -type d -iname "*$1*" -print0 | while IFS= read -r -d $'\0' APP; do
            PLIST=$APP/Contents/Info.plist
            ID=`/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' $PLIST`
            echo "$APP => $ID"
        done
    else
        # found one app
        PLIST=$APP/Contents/Info.plist
        if [ -f $PLIST ]; then
            /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' $PLIST
        else
            echo "Sorry, app $1 not found!"
        fi
    fi
}

app_show () {
    if [ "$1" != "" ]
    then
        echo "$1 files are opening with this app:\n"
        duti -x $1
    fi
}

app_set () {
    if [ "$1" != "" ] && [ "$2" != "" ]; then
        app_show $1
        APP_ID=`app_id $2`
        # app not found
        if [[ $APP_ID == *"not found"* ]]
        then
            # show error message from app_id
            echo "\n$APP_ID"
        else
            # found couple apps
            if [[ $APP_ID == *"=>"* ]]
            then
                echo "\nFound couple apps, please clarify request and choose one:\n\n$APP_ID"
            else
                echo "\nSetting app $2 for opening all $1 files\n"
                duti -s $APP_ID $1 all
                app_show $1
            fi
        fi
    else
        echo "usage:\tapp_set extention application\n\tapp_set md MacDown\n\tapp_set public.source-code sublime"
    fi
}

# rails
alias r='rails'
alias rt='be rubocop -a && be brakeman && be rspec && be rails test'
alias rdb='be rails db:migrate && be rails db:migrate RAILS_ENV=test'
rc () { git add . && git commit -m $1 && git push }
function rls() {
    if [ "$1" != "" ]
    then
        lsof -i tcp:$1
    else
        lsof -i tcp:3000
    fi
}

function rlk() {
    if [ "$1" != "" ]
    then
        kill -9 $(lsof -ti tcp:$1)
    else
        kill -9 $(lsof -ti tcp:3000)
    fi
}

# Some more basic aliases
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -lah'
alias md='mkdir -p'
alias rd='rmdir'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd......='cd ../../../../..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Bundler
alias b='bundle'
alias be='bundle exec'
alias bi='bundle install'
alias bu='bundle update'

# Git
alias git='noglob git'
alias g='git'
alias ga='git add'
alias gapa='git add --patch'
alias gb='git branch'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcb='git checkout -b'
alias gcm='git checkout master'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdca='git diff --cached'
alias gf='git fetch'
alias ggpush='git push origin HEAD'
alias gl='git pull'
alias glg='git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d"'
alias glga='git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d" --all'
alias glgg='git log --graph --decorate'
alias glgga='git log --graph --decorate --all'
alias gp='git push'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grup='git remote update'
alias gst='git status'
alias gsta='git stash'
alias gstd='git stash drop'
alias gstp='git stash pop'

# Platform-specific stuff
if quiet_which brew
then
  export BINTRAY_USER="$(git config bintray.username)"
  export BREW_PREFIX=$(brew --prefix)
  export BREW_REPO=$(brew --repo)
  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_ANALYTICS=1
  export HOMEBREW_AUTO_UPDATE=1
  export HOMEBREW_FORCE_VENDOR_RUBY=1

  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if [ "$USER" = "brewadmin" ]
  then
    export HOMEBREW_CASK_OPTS="$HOMEBREW_CASK_OPTS --binarydir=$BREW_PREFIX/bin"
  fi

  alias hbc="cd $BREW_REPO/Library/Taps/homebrew/homebrew-core"
  alias hbv="cd $BREW_REPO/Library/Taps/homebrew/homebrew-versions"

  # Output whether the dependencies for a Homebrew package are bottled.
  brew_bottled_deps() {
    for DEP in "$@"; do
      echo "$DEP deps:"
      brew deps $DEP | xargs brew info | grep stable
      [ "$#" -ne 1 ] && echo
    done
  }

  # Output the most popular unbottled Homebrew packages
  brew_popular_unbottled() {
    brew deps --all |
      awk '{ gsub(":? ", "\n") } 1' |
      sort |
      uniq -c |
      sort |
      tail -n 500 |
      awk '{print $2}' |
      xargs brew info |
      grep stable |
      grep -v bottled
  }
fi

if [ $OSX ]
then
  export GREP_OPTIONS="--color=auto"
  export CLICOLOR=1
  # export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"
  if quiet_which diff-highlight
  then
    export GIT_PAGER='diff-highlight | less -+$LESS -RX'
  else
    export GIT_PAGER='less -+$LESS -RX'
  fi

  add_to_path_end /Applications/Xcode.app/Contents/Developer/usr/bin
  add_to_path_end /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
  add_to_path_end "$BREW_PREFIX/opt/git/share/git-core/contrib/diff-highlight"

  alias ls="ls -F"
  alias ql="qlmanage -p 1>/dev/null"
  alias locate="mdfind -name"
  alias cpwd="pwd | tr -d '\n' | pbcopy"
  alias finder-hide="setfile -a V"

  # Old default Curl is broken for Git on Leopard.
  [ "$OSTYPE" = "darwin9.0" ] && export GIT_SSL_NO_VERIFY=1
elif [ $LINUX ]
then
  quiet_which keychain && eval `keychain -q --eval --agents ssh id_rsa`

  alias su="/bin/su -"
  alias ls="ls -F --color=auto"
  alias open="xdg-open"
elif [ $WINDOWS ]
then
  quiet_which plink && alias ssh="plink -l $(git config shell.username)"

  alias ls="ls -F --color=auto"

  open() {
    cmd /C"$@"
  }
fi

# Set up editor
if [ -n "${SSH_CONNECTION}" ] && quiet_which rmate
then
  export EDITOR="rmate"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR=$GIT_EDITOR
elif quiet_which mate
then
  export EDITOR="mate"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR="$GIT_EDITOR"
elif quiet_which subl || quiet_which sublime_text
then
  quiet_which subl && export EDITOR="subl"
  quiet_which sublime_text && export EDITOR="sublime_text" \
    && alias subl="sublime_text"

  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR="$GIT_EDITOR"
elif quiet_which vim
then
  export EDITOR="vim"
elif quiet_which vi
then
  export EDITOR="vi"
fi

# Run dircolors if it exists
quiet_which dircolors && eval $(dircolors -b)

# More colours with grc
[ -f "$BREW_PREFIX/etc/grc.bashrc" ] && source "$BREW_PREFIX/etc/grc.bashrc"

# Save directory changes (opens new tab with last dir)
# cd() {
#   builtin cd "$@" || return
#   [ $TERMINALAPP ] && which set_terminal_app_pwd &>/dev/null \
#     && set_terminal_app_pwd
#   pwd > "$HOME/.lastpwd"
#   ls
# }

# Use ruby-prof to generate a call stack
ruby-call-stack() {
  ruby-prof --printer=call_stack --file=call_stack.html -- "$@"
}

# Look in ./bin but do it last to avoid weird `which` results.
force_add_to_path_start "bin"
