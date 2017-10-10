# git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

function bru      ; brew -v update; brew -v upgrade; brew cu -a -y; mas upgrade; brew cleanup; brew cask cleanup; brew -v prune; brew doctor ; end

# https://github.com/sindresorhus/quick-look-plugins
function quicklook ; brew cask reinstall qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package quicklookase qlvideo ; end

# Navigation
function ..       ; cd ..                               ; end
function ...      ; cd ../..                            ; end
function ....     ; cd ../../..                         ; end
function .....    ; cd ../../../..                      ; end
function l        ; tree --dirsfirst -aFCNL 1 $argv     ; end
function ll       ; tree --dirsfirst -ChFupDaLg 1 $argv ; end

# Utilities
function a        ; command ag --ignore=.git --ignore=log --ignore=tags --ignore=tmp --ignore=vendor --ignore=spec/vcr $argv               ; end
function b        ; bundle exec $argv                   ; end
function br       ; bundle exec rspec $argv             ; end
# function c        ; pygmentize -O style=monokai -f console256 -g $argv  ; end
function c        ; clear                               ; end
function d        ; du -h -d=1 $argv                    ; end
function df       ; command df -h $argv                 ; end
function digga    ; command dig +nocmd $argv[1] any +multiline +noall +answer   ; end
function f        ; foreman run bundle exec $argv       ; end
function g        ; git $argv                           ; end
function grep     ; command grep --color=auto $argv     ; end
function httpdump ; sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E "Host\: .*|GET \/.*" ; end
function ip       ; curl -s http://checkip.dyndns.com/ | sed 's/[^0-9\.]//g'    ; end
function localip  ; ipconfig getifaddr en0              ; end
function lookbusy ; cat /dev/urandom | hexdump -C | grep --color "ca fe"        ; end
function mp       ; nvim $argv                          ; end
function rkt      ; racket -il xrepl $argv              ; end
function t        ; command tree -C $argv               ; end
function tmux     ; command tmux -2 $argv               ; end
function tunnel   ; ssh -D 8080 -C -N $argv             ; end
function view     ; nvim -R $argv                       ; end
function vp       ; nvim $argv                          ; end

# Completions
function make_completion --argument-names alias command
    echo "
    function __alias_completion_$alias
        set -l cmd (commandline -o)
        set -e cmd[1]
        complete -C\"$command \$cmd\"
    end
    " | .
    complete -c $alias -a "(__alias_completion_$alias)"
end

make_completion b 'bundle exec'
make_completion f 'foreman run'
make_completion g 'git'
make_completion gco 'git checkout'

# vagrant
function v        ; vagrant version; and vagrant global-status    ; end
function vst      ; vagrant status                      ; end
function vup      ; vagrant up                          ; end
function vu       ; vagrant resume 53ea165              ; end
function vd       ; vagrant suspend 53ea165             ; end
function vdo      ; vagrant halt                        ; end
function vssh     ; vagrant ssh                         ; end
function vkill    ; vagrant destroy                     ; end

# git
function giamchromium  ; git config user.name "Chromium"; and git config user.email "email@email"                                   ; end
function ga       ; git add                             ; end
function gapa     ; git add --patch                     ; end
function gb       ; git branch                          ; end
function gc       ; git commit -v                       ; end
function gc!      ; git commit -v --amend               ; end
function gca      ; git commit -v -a                    ; end
function gca!     ; git commit -v -a --amend            ; end
function gcb      ; git checkout -b $argv               ; end
function gcm      ; git checkout master                 ; end
function gco      ; git checkout $argv                  ; end
function gcp      ; git cherry-pick                     ; end
function gd       ; git diff                            ; end
function gdca     ; git diff --cached                   ; end
function gf       ; git fetch                           ; end
function ggpush   ; git push origin HEAD                ; end
function gl       ; git pull                            ; end
function gcl      ; git clone $argv                     ; end
function glg      ; git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d"                      ; end
function glga     ; git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d" --all                ; end
function glgg     ; git log --graph --decorate          ; end
function glgga    ; git log --graph --decorate --all    ; end
function gp       ; git push $argv                      ; end
function gpup     ; git push --set-upstream origin (git branch | grep \* | cut -d ' ' -f2-)                                              ; end
function gpb      ; git add .; and git commit -m (git branch | grep \* | cut -d ' ' -f2-)                                                ; end
function gpp      ; git add .; and git commit -m $argv  ; end
function gpc      ; git add .; and git commit -m $argv; and git push  ; end
function gr       ; git remote                          ; end
function gra      ; git remote add                      ; end
function grb      ; git rebase                          ; end
function grba     ; git rebase --abort                  ; end
function grbc     ; git rebase --continue               ; end
# function grbi     ; git rebase -i                     ; end
function grbi     ; git rebase -i HEAD~$argv            ; end
function grup     ; git remote update                   ; end
function gst      ; git status                          ; end
function gsta     ; git stash                           ; end
function gstd     ; git stash drop                      ; end
function gstp     ; git stash pop                       ; end

set -g fish_user_paths "/usr/local/sbin" $fish_user_paths

set -x GOPATH (go env GOPATH)
set -x PATH $PATH (go env GOPATH)/bin

# bunch application functions
function app_show ()
  if count $argv > /dev/null
    echo "$argv files are opening with this app:"
    echo -en "\t"
    set APP (duti -x $argv)
    echo "$APP"
  end
end

# get application bundle identifier using duti
function app_id ()
  set APPS (find /Applications -maxdepth 1 -type d -iname "*$argv*")
  set APP (find /Applications -maxdepth 1 -type d -iname "*$argv*" | head -n1)
  if [ "$APP" != "$APPS" ]
    # found couple apps
    for APPS_APP in (find /Applications -maxdepth 1 -type d -iname "*$argv*")
      set PLIST "$APPS_APP/Contents/Info.plist"
      set ID (/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' $PLIST)
      echo "$APPS_APP => $ID"
    end
  else
    # found one app
    set PLIST "$APP/Contents/Info.plist"
    if test -e $PLIST
      /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' $PLIST
    else
      echo "Sorry, app $argv was not found!"
    end
  end
end

function app_set ()
  switch (count $argv)
    case 2
      app_show $argv[2]
      set APP_ID (app_id $argv[1])
      switch "$APP_ID"
        case '*not found*'
          echo $APP_ID
        case '*=>*'
          echo "Found couple apps, please clarify request and choose one:"
          for line in $APP_ID
            echo -e "\t$line"
          end
        case '*'
          duti -s $APP_ID $argv[2] all
          app_show $argv[2]
      end
    case '*'
        echo -e "usage:\tapp_set extention application\n\tapp_set md MacDown\n\tapp_set public.source-code sublime"
  end
end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
