
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/cparis/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/cparis/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/cparis/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/cparis/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# >>> Personal styling preferences >>

# Git support
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%F{5}(%fgit%F{5})%F{3}-%F{5}[%F{2}noci-cparis-update-bazel_master%F{5}]%f"

# Git tab-completion
autoload -Uz compinit && compinit

function prompt-length() {
  emulate -L zsh
  local COLUMNS=${2:-$COLUMNS}
  local -i x y=$#1 m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done
    local xy
    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done
  fi
  echo $x
}

# Usage: fill-line LEFT RIGHT
#
# Prints LEFT<spaces>RIGHT with enough spaces in the middle
# to fill a terminal line.
function fill-line() {
  emulate -L zsh
  local left_len=$(prompt-length $1)
  local right_len=$(prompt-length $2 9999)
  local pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
  if (( pad_len < 1 )); then
    # Not enough space for the right part. Drop it.
    echo -E - ${1}
  else
    local pad=%F{yellow}${(pl.$pad_len..-.)}  # pad_len spaces
    echo -E - ${1}${pad}${2}
  fi
}

# Sets PROMPT and RPROMPT.
#
# Requires: prompt_percent and no_prompt_subst.
function set-prompt() {
  emulate -L zsh
  local git_branch=${vcs_info_msg_0_}

  # ~/foo/bar                     master
  # % █                            10:51
  #
  # Top left:     Blue current directory.
  # Top right:    Green Git branch.
  # Bottom left:  '#' if root, '%' if not; green on success, red on error.
  # Bottom right: Yellow current time.

  local top_left='%F{green}%~%f'
  local top_right="${git_branch}%f"
  local bottom_left='%F{green}%T %f%B%F{%(?.green.red)}%#%f%b '
  # local bottom_right='%F{yellow}%T%f'

  PROMPT="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
  # RPROMPT=$bottom_right
  RPROMPT=""
}

setopt noprompt{bang,subst} prompt{cr,percent,sp}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt

# Print a newline line before printing the prompt
precmd() { 
	vcs_info
	print "" 
}