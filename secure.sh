#!/bin/bash

# TLDR
# - create a temp directory
# - copy all ssh keys to that directory
# - create a tarball to ~/.ssh
# - print sha256sum of the tarball
# - add sha256sum of the tarball to a checksum file
# - encrypt tarball
# - print sha256sum of the encrypted tarball
# - add sha256sum of the encrypted tarball to checksum file
# - remove files from the temp directory
# - remove temp directory
###################################################################################################

TARBALL_NAME=secrets.tar.gz
ENCRYPTED_TARBALL_NAME="$TARBALL_NAME".encrypted
SHA256SUM_FILE=sha256sum.txt

echo "> Removing $TARBALL_NAME"
shred --remove "$TARBALL_NAME" 2> /dev/null
echo "> Removing $ENCRYPTED_TARBALL_NAME"
shred --remove "$ENCRYPTED_TARBALL_NAME" 2> /dev/null
echo "> Removing sha256sum.txt"
shred --remove $SHA256SUM_FILE 2> /dev/null

###################################################################################################
# create a temp directory and copy all SSH keys to the directory

echo "> Creating temp directory"
TEMP_DIR=$(mktemp -d)
echo "> Temp dir location $TEMP_DIR"

echo "> Copying files to temp directory"
rsync -rvq \
  --exclude .git \
  --exclude .gitignore \
  --exclude README.md \
  --exclude allowed_signers \
  --exclude "*.sh" \
  --exclude known_hosts \
  --exclude sha256sum.txt \
  --exclude "$TARBALL_NAME" \
  --exclude "$ENCRYPTED_TARBALL_NAME" \
  . "$TEMP_DIR"

# echo "contents in $TEMP_DIR"
# ls -lah "$TEMP_DIR"

###################################################################################################
# create an TARBALL_NAME

printf "> Creating Tarball\n\n"
cd "$TEMP_DIR" || exit
tar -czvf "$HOME/.ssh/$TARBALL_NAME" .
cd ~/.ssh || exit

# printf "\n tarball contents\n"
# tar -tvf "$HOME/.ssh/$TARBALL_NAME"

echo ""
printf "> sha256sum of %s\n" $TARBALL_NAME
sha256sum "$TARBALL_NAME"
sha256sum "$TARBALL_NAME" > $SHA256SUM_FILE
echo ""

###################################################################################################
# encrypt the tarball
# openssl enc -aes256 -in $TARBALL_NAME -out $TARBALL_NAME.enc -salt 

printf "> Encrypting tarball %s\n" $TARBALL_NAME
gpg --symmetric --output "$ENCRYPTED_TARBALL_NAME" --armor "$TARBALL_NAME"
echo "> sha256sum of encrypted tarball $ENCRYPTED_TARBALL_NAME"
sha256sum "$ENCRYPTED_TARBALL_NAME"
sha256sum "$ENCRYPTED_TARBALL_NAME" >> $SHA256SUM_FILE
echo ""

###################################################################################################
# remove the temp directory contents

echo "> Removing files from temp directory"
find "$TEMP_DIR" -exec shred -vfuz {} + 2> /dev/null

# echo "contents in $TEMP_DIR"
# ls -lah "$TEMP_DIR"

# remove temp directory
echo "> Removing temp directory"
rm -rf "$TEMP_DIR"

###################################################################################################
