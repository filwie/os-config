#!/usr/bin/env zsh
# vim: set sw=2:

ANSIBLE_PLUGINS=("https://github.com/kewlfft/ansible-aur.git aur")
ANSIBLE_PLUGINS_DIR="${HOME}/.ansible/plugins/modules"

declare -a ANSIBLE_PLAYBOOK_ARGS
declare -a ARGS

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
RESET="$(tput sgr0)"

function usage () {
  echo -e "USAGE:\t${0} [-h/--help] [-g/--git] [-f/--fonts] [] [-p/--packages] [-v/--virtualization] [-d/--hidpi] [ANSIBLE_PLAYBOOK_ARGUMENTS]" > /dev/stderr
  echo -e "EXAMPLE:\t${0} -f -p -i inventory --ask-pass --ask-become-pass"
  exit 1
}

local help fonts packages virtualization hidpi extra_vars
zparseopts -a ARGS -D -E \
           h=help -help=help \
           f=fonts -fonts=fonts \
           p=packages -packages=packages \
           v=virtualization -virtualization=virtualization \
           d=hidpi -hidpi=hidpi \
           e+:=extra_vars -extra-vars+:=extra_vars

[[ -n "${help}" ]]           && usage
[[ -n "${git}" ]]          && ANSIBLE_PLAYBOOK_ARGS+=("-e git=true")
[[ -n "${fonts}" ]]          && ANSIBLE_PLAYBOOK_ARGS+=("-e fonts=true")
[[ -n "${packages}" ]]       && ANSIBLE_PLAYBOOK_ARGS+=("-e packages=true")
[[ -n "${virtualization}" ]] && ANSIBLE_PLAYBOOK_ARGS+=("-e virtualization=true")
[[ -n "${hidpi}" ]]          && ANSIBLE_PLAYBOOK_ARGS+=("-e hidpi=true")
[[ -n "${extra_vars}" ]]     && ANSIBLE_PLAYBOOK_ARGS+=("${extra_vars[@]}")
ANSIBLE_PLAYBOOK_ARGS+="${@}"

function info_msg () {
  local msg="${GREEN}[$(date +'%T')] INFO: "
  echo -e "${msg}${1}${RESET}"
}

function error_msg () {
  local msg="${RED}[$(date +'%T')] [${BASH_LINENO[0]}] ERROR: "
  echo -e "${msg}${1}${RESET}" > /dev/stderr
  return "${2:-0}"
}

function run_log_cmd () {
  local cmd
  cmd="${1}"
  echo -e "$(tput setaf 12)[$(date +'%H:%M:%S')] CMD: ${cmd}$(tput sgr0)"
  eval "${cmd}"
}
function install_ansible_plugins () {
  info_msg "Installing required Ansible plugins..."
  [[ -d "${ANSIBLE_PLUGINS_DIR}" ]] || mkdir "${ANSIBLE_PLUGINS_DIR}"
  for plugin_url_dir in "${ANSIBLE_PLUGINS[@]}"; do
    local plugin_dir plugin_url destination
    plugin_url="${plugin_url_dir% *}"
    plugin_dir="${plugin_url_dir#* }"
    destination="${ANSIBLE_PLUGINS_DIR}/${plugin_dir}"
    if ! [[ -d "${destination}" ]]; then
      if git clone "${plugin_url}" "${destination}" &> /dev/null; then
        info_msg "Installed ${plugin_dir} into ${destination}"
      else
        error_msg "Plugin ${plugin_dir} installation failed." 1
      fi
    else
      info_msg "${destination} already exists. Skipping..."
    fi
  done
}

function run_playbook () {
  pushd "${0:A:h}/ansible/"
  run_log_cmd "ansible-playbook os-config.yaml ${(j. .)@}"
  popd
}

function main () {
  install_ansible_plugins
  run_playbook "${(j. .)ANSIBLE_PLAYBOOK_ARGS[@]}"
}

main "${@}"
