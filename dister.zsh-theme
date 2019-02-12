local ret_status="%(?:%{$fg[green]%}➞ :%{$fg[red]%}➞ %s)"

#function git_prompt_info() {
#  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
#  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX$(parse_git_dirty)"
#}

function get_pwd(){
  git_root=$PWD
  while [[ $git_root != / && ! -e $git_root/.git ]]; do
    git_root=$git_root:h
  done
  if [[ $git_root = / ]]; then
    unset git_root
    prompt_short_dir=%~
  else
    parent=${git_root%\/*}
    prompt_short_dir=${PWD#$parent/}
  fi
  echo $prompt_short_dir
}

PROMPT='$(get_pwd)  $(git_prompt_info)%{$reset_color%}$(git_prompt_status)%{$reset_color%}$(git_prompt_ahead)%{$reset_color%} $(git_time_since_commit)%{$reset_color%}'$'\n''$ret_status %{$fg[white]%}%{$reset_color%}%{$reset_color%}'

RPROMPT='${time}'

# local time, color coded by last return code
time_enabled="%(?.%{$fg[green]%}.%{$fg[red]%})%*%{$reset_color%}"
time_disabled="%{$fg[green]%}%*%{$reset_color%}"
time=$time_enabled

#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}"
#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✓%{$reset_color%}"

#ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}[git:"
#ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}+%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"

# Spacing meets the format for the width of each character and the expected following chars
ZSH_THEME_GIT_PROMPT_PREFIX="☁  %{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ☂  " # Ⓓ
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ☀ " # Ⓞ

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}✚ " # ⓐ ⑃
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚡"  # ⓜ ⑁
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}✭ " # ⓣ
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}♻ " # ⓧ ⑂
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}➜ " # ⓡ ⑄
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%}♒" # ⓤ ⑊
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[blue]%}𝝙"

ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$reset_color%}"

# More symbols to choose from:
# ☀ ✹ ☄ ♆ ♀ ♁ ♐ ♇ ♈ ♉ ♚ ♛ ♜ ♝ ♞ ♟ ♠ ♣ ⚢ ⚲ ⚳ ⚴ ⚥ ⚤ ⚦ ⚒ ⚑ ⚐ ♺ ♻ ♼ ☰ ☱ ☲ ☳ ☴ ☵ ☶ ☷
# ✡ ✔ ✖ ✚ ✱ ✤ ✦ ❤ ➜ ➟ ➼ ✂ ✎ ✐ ⨀ ⨁ ⨂ ⨍ ⨎ ⨏ ⨷ ⩚ ⩛ ⩡ ⩱ ⩲ ⩵  ⩶ ⨠
# ⬅ ⬆ ⬇ ⬈ ⬉ ⬊ ⬋ ⬒ ⬓ ⬔ ⬕ ⬖ ⬗ ⬘ ⬙ ⬟  ⬤ 〒 ǀ ǁ ǂ ĭ Ť Ŧ

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$HOURS" -gt 2 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 45 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 168 ]; then
                echo "$COLOR>w%{$reset_color%}"
            elif [ "$HOURS" -gt 48 ]; then
                echo "$COLOR${DAYS}d%{$reset_color%}"
            elif [ "$HOURS" -gt 24 ]; then
                echo "$COLOR>d%{$reset_color%}"
            elif [ "$MINUTES" -gt 120 ]; then
                echo "$COLOR${HOURS}h%{$reset_color%}"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "$COLOR>h%{$reset_color%}"
            else
                echo "$COLOR<h%{$reset_color%}"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "$COLOR~%{$reset_color%}"
        fi
    fi
}

