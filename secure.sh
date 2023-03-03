#!/bin/bash

# TLDR
# - create a tarball to ~/.ssh
# - print sha256sum of the tarball
# - add sha256sum of the tarball to a checksum file
# - encrypt tarball
# - print sha256sum of the encrypted tarball
# - add sha256sum of the encrypted tarball to checksum file
###################################################################################################

TARBALL_NAME=secrets.tar.gz
ENCRYPTED_TARBALL_NAME="$TARBALL_NAME".encrypted
SHA256SUM_FILE=sha256sum.txt
###################################################################################################
# remove existing tarball, encrypted tarball and sha256sum.txt

echo "> Removing $TARBALL_NAME"
shred --remove "$TARBALL_NAME" 2> /dev/null
echo "> Removing $ENCRYPTED_TARBALL_NAME"
shred --remove "$ENCRYPTED_TARBALL_NAME" 2> /dev/null
echo "> Removing sha256sum.txt"
shred --remove $SHA256SUM_FILE 2> /dev/null

###################################################################################################
# create an TARBALL_NAME

printf "> Creating Tarball\n\n"

# obtained from https://stackoverflow.com/a/3035446
tar -czvf "$TARBALL_NAME" -C ~/.ssh \
  --exclude .git/ \
  --exclude .gitignore \
  --exclude README.md \
  --exclude allowed_signers \
  --exclude "*.sh" \
  --exclude known_hosts \
  --exclude sha256sum.txt \
  --exclude "$TARBALL_NAME" \
  --exclude "$ENCRYPTED_TARBALL_NAME" \
  .

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
