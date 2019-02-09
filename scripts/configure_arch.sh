#!/usr/bin/env zsh

declare -a USERS GROUPS PACKAGES

GROUPS=("users" "sudo")
PACKAGES=("base" "base-devel" "sudo" "vim" "tmux" "openssh" "python" "python-pip")

GROUP_ID=666
USER_ID=666

function parse_arguments () {
  local users groups
  zparseopts -D -E u+:=users g+:=groups
  USERS=("${users[@]:#-u}")
  GROUPS+=("${groups[@]:#-g}")
}

function info_msg () {
  echo -e "$(tput setaf 3)${1}$(tput sgr0)"
}

function error_msg () {
  echo -e "$(tput setaf 3)${1}$(tput sgr0)" > /dev/stderr
  return "${1:-1}"
}

function run_log_cmd () {
  local cmd
  cmd="${1}"
  echo -e "$(tput setaf 12)[$(date +'%H:%M:%S')] CMD: ${cmd}$(tput sgr0)"
  eval "${cmd}"
}

function create_groups () {
  local add_group_cmd
  for group in "${GROUPS[@]}"; do
    if [[ "${group}" == "${GROUPS[1]}" ]]; then
      add_group_cmd="groupadd -g ${GROUP_ID}"
    else
      add_group_cmd="groupadd"
    fi
    run_log_cmd "${add_group_cmd} ${group}"
  done

}

function create_users () {
  local create_user_cmd
  create_user_cmd="useradd -m -s $(which zsh) -G ${(j.,.)GROUPS[@]} -g ${GROUPS[1]}"
  [[ ${#USERS[@]} -eq 1 ]] && create_user_cmd+=" -u ${USER_ID}"

  for user in "${USERS[@]}"; do
    run_log_cmd "${create_user_cmd} ${user}"
  done
}

function set_passwords () {
  local users
  users=("${USERS[@]}" "root")
  for user in "${users[@]}"; do
    run_log_cmd "passwd ${user}"
  done
}

function update_sort_mirrors () {
  run_log_cmd "pacman -Sy --noconfirm --needed reflector"
  run_log_cmd "reflector --sort rate --protocol https --save /etc/pacman.d/mirrorlist"
}

function install_packages () {
  local packages
  packages="${(j. .)PACKAGES}"
  run_log_cmd "pacman -S --noconfirm --needed ${packages}"
}

function start_sshd () {
  run_log_cmd "systemctl start sshd"
}

function enable_sudo () {
  run_log_cmd "sudo sed -i 's/^#\s*\(%sudo\s\+ALL=(ALL)\s\+ALL\)/\1/' /etc/sudoers"
}

function main () {
  parse_arguments "${@}"
  create_groups
  create_users
  set_passwords
  update_sort_mirrors
  install_packages
  start_sshd
}

main "${@}"
# vim: set sw=2 ts=2:
