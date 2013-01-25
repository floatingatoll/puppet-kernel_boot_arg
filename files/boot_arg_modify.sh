#!/bin/bash

: Enable verbose debugging, when uncommented.
set -x

: Exit if there are any errors.
set -e

: Parse command line arguments.
[[ -n "$1" ]]
boot_arg_script="$1"
shift
config_var="$1"
shift
modify_command="$1"
shift
title_value="$1"
shift
config_file="$1"
[[ -z "$config_file" ]]

: Prepare the backup file.
old="${config_file}.orig"
cp -p "${config_file}" "${old}"

: Prepare the replacement file.
new="${config_file}.temp"
cp -p "${config_file}" "${new}"

: Generate the replacement, using the provided arguments.
"${boot_arg_script}" "${config_var}" "${modify_command}" "${title_value}" < "${config_file}" > "${new}"

: Overwrite the file with its replacement.
mv -f "${new}" "${config_file}"
