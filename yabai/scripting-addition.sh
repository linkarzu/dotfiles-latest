#!/bin/bash

# Filename: ~/github/dotfiles-latest/yabai/scripting-addition.sh

echo
echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Configuring scripting additions"
yabai_path=$(which yabai)
user_name=$(whoami)
hash_val=$(shasum -a 256 $yabai_path | awk '{print $1}')

# Create a temporary file
# mktemp generates a unique filename for the temporary file, so there is no
# risk of name collision with existing files.
temp_file=$(mktemp)

# Write the new sudoers content to the temp file
# Specifies that the command `$yabai_path --load-sa` is allowed to be run by `$user_name` as root without a password only if the sha256 hash of the `$yabai_path` binary matches `$hash_val`
echo "$user_name ALL=(root) NOPASSWD: sha256:$hash_val $yabai_path --load-sa" >$temp_file

# Validate the temporary sudoers file to make sure its correct
# visudo will return non-zero if there is a syntax error
sudo visudo -c -f $temp_file

# If validation succeeds, move the tmp file to the sudoers dir
# If the sudoers file already exists, it will be replaced
if [ $? -eq 0 ]; then
	sudo mv $temp_file /private/etc/sudoers.d/yabai
	echo
	echo "File created successfully"
else
	# If validation fails, remove the temporary file and print an error message
	rm $temp_file
	echo "Failed to validate the sudoers file."
fi

echo
echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Changing file permissions, sudoers file created has to be owned by root"
sudo chown root:wheel /private/etc/sudoers.d/yabai
sudo chmod 0440 /private/etc/sudoers.d/yabai

echo
echo -e "${boldPurple}>>>>>>>>>>>>>>>>>>>>>>>>>>${noColor}"
echo "Restarting the yabai service..."
yabai --restart-service
# Generate the required data

echo -e "
If you still don't see your windows applying the changes, keep restarting
the service, if there are any errors, you will see them after restarting it

yabai --restart-service
"
