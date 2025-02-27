echo "running ~/.oh-my-zsh/custom/00-script.zsh"

# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# For example: add yourself some shortcuts to projects you often work on.
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr
#

#---------------------#
# my standard aliases
#---------------------#
alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."
alias ll="ls -alFp"
alias iso8601='date -u "+%FT%T UTC"'
alias micros='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s000000"'
alias path='tr ":" "\n" <<< "$PATH"' 
alias paths='echo $PATH | tr ":" "\n"'
alias pythonpaths='echo $PYTHONPATH | tr ":" "\n"'
alias iterm2-kafka='echo -e "\033]50;SetProfile=kafka-streaming-pipeline\a"'
alias iterm2-default='echo -e "\033]50;SetProfile=Default\a"'
alias vault-serve='vault server -dev'
alias cdyt='pushd ~/workspace-youtube/youtube-search-app'
allas cdfk='pushd ~/workspace-flock/flock-of-postcards'

# the venv aliases
alias venv-activate='source ~/bin/venv-activate-project'
alias venv-deactivate='deactivate'
alias venv-make='~/bin/venv-create && source ~/bin/venv-activate-project'
alias venv-destroy='~/bin/venv-destroy && deactivate'

#---------------------------
# HashiCorp Vault
. ./.env-vault


#---------------------------
# OPENAI
. ./.env-openai

#---------------------#
PYCHARM_HOME=/Applications/PyCharm.app/Contents/MacOS
PATH=${PYCHARM_HOME}:${PATH}

#---------------------#
# vscode
export VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User"
#---------------------#
# my standard path
#---------------------#
export PATH=${PATH}:~/bin:./

#---------------------#
# multi-line prompt
# with iterm2 squelch mark inseted for Cmd-Shift-Up and Down arrow keys
#---------------------#
# PS1='
# \[$(iterm2_prompt_mark)\]$PWD
# >'


#-------------------------#
# iterm2 shell integration
#-------------------------#
# source ~/.iterm2_shell_integration.bash

#----------#
# python 3.8	
#-----------#
PYTHON3_HOME=/usr/local/opt/python@3.8
PATH=$PYTHON3_HOME/bin:$PATH

#----------#
# helm
#----------#
HELM_HOME=~/helm
PATH=$HELM_HOME:$PATH

#----------#
# google-cloud-api
#----------#
CLOUDSDK_PYTHON=~/google-cloud/google-cloud-sdk
PATH=$CLOUDSDK_PYTHON:$PATH


#------#
# java
# see https://stackoverflow.com/a/44169445
# go to /Library/Java/JavaVirtualMachines and rename Info.plist under all
# <jdk-version>/Contents directories to Info.plist.disabled except for one. 
# `/usr/libexec/java_home` will return the highest <jdk-version> that
# has a <jdk-version>/Contents/Info.plist file.
#------#
export JAVA_HOME=/usr/local/Cellar/openjdk@8/1.8.0+345
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home
export PATH=${PATH}:${JAVA_HOME}/bin

#-------------
# maven 3.6.2  
#-------------#
export M2_HOME=$HOME/.m2
export LDFLAGS="${LDFLAGS} -L/usr/local/opt/openssl/lib"

#-----------------------------------#
# awscli and command line completion
#-----------------------------------#
complete -C /usr/local/bin/aws_completer aws

#----------#
# postgres
#----------#
# export PG_HOME=/usr/local/opt/postgresql@9.4
# export PATH=${PATH}:${PG_HOME}/bin
# export PGDATA=/usr/local/var/postgres
# alias show-pg-status='pg_ctl status'
# alias open-pg-docs='open https://www.postgresql.org/docs/13/app-initdb.html'

#-----#
# X11 #
#-----#
export DISPLAY=:0.0
export PATH=${PATH}:/usr/X11R6/bin

#-----#
# brew services
#-----#
# alias list-services="brew services list"
# alias restart-postgresql="brew services restart postgresql"

#-----#
# AWS
#-----#

# export BASH_SILENCE_DEPRECATION_WARNING=1

# export PATH="/usr/local/sbin:$PATH"

# alias ip='ipconfig getifaddr en0'

# CLIPFILE
#export CF_WRK_BASE=~/workspace-clipfile
#export CF_SYS_ENV=scb-dev
#export CATALINA_HOME=/usr/local/opt/tomcat@8/libexec

# source <(kubectl completion bash)
# alias k=kubectl
# complete -F __start_kubectl k

alias code="/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron"

# test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

alias cd-tt='cd ~/workspace-angel/tuttle-twins-image-classification && activate'
alias aws-sso-login='aws sso login'

python --version
pip --version
alias pip-upgrade='python3 -m pip install --upgrade pip'
alias ubuntu-bash="docker run -it ubuntu:16.04 /bin/bash"

alias git-log="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"

. ~/.iterm2_shell_integration.zsh

echo "iterm2 running on $(uname -m)"



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sbecker11/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sbecker11/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sbecker11/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sbecker11/google-cloud-sdk/completion.zsh.inc'; fi

# add sbin to PATH
export PATH=${PATH}:/usr/local/sbin
