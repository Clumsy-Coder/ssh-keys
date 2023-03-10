#!/bin/bash

# Usage:
# - to encrypt ssh keys
# ./secure.sh
#
###################################################################################################
# - to descrypt ssh keys
# ./secure.sh -d
#
# or
#
# ./secure.sh --decrypt
###################################################################################################
###################################################################################################
###################################################################################################
# TLDR decrypting SSH keys
# - check if encryption file doesn't exist
#   - exit program
# - check file integrity of encrypted tarball
# - decrypt the encrypted tarball
# - check file integrity of tarball
# - extract tarball contents in the current directory
# - check integrity of ssh keys
# - remove tarball
# - exit program

# TLDR encrypting SSH keys
# - generate sha256sum for ssh keys to a file
# - print sha256sum of ssh keys
# - create a tarball of ssh keys to ~/.ssh
# - print sha256sum of the tarball
# - generate sha256sum of the tarball to a file
# - encrypt tarball
# - print sha256sum of the encrypted tarball
# - generate sha256sum of the encrypted tarball to a file
###################################################################################################

TARBALL_NAME=secrets.tar.gz
ENCRYPTED_TARBALL_NAME="$TARBALL_NAME".encrypted
SHA256SUM_FILE=sha256sum.txt
SSH_KEY_SHA256SUM_FILE=ssh-keys-checksum.txt
###################################################################################################

###################################################################################################
###################################### DECRYPT SSH KEYS ###########################################
###################################################################################################
if [ "$1" == "-d" ] || [ "$1" == "--decrypt" ]; then
  if [ ! -f "$ENCRYPTED_TARBALL_NAME" ]; then
    echo "> Encrypted file $ENCRYPTED_TARBALL_NAME doesn't exist"
    exit 1
  fi

  echo "> Checking integrity of $ENCRYPTED_TARBALL_NAME"
  sha256sum --check "$SHA256SUM_FILE" --ignore-missing
  echo ""

  echo "> Decrypting $ENCRYPTED_TARBALL_NAME"
  gpg --decrypt --no-symkey-cache --output "$TARBALL_NAME" "$ENCRYPTED_TARBALL_NAME"
  echo ""

  echo "> Checing integrity of $TARBALL_NAME"
  sha256sum --check "$SHA256SUM_FILE" --ignore-missing
  echo ""

  echo "> Extracting tarball contents"
  tar xf "$TARBALL_NAME"
  echo ""

  echo "> Checking integrity of ssh keys"
  sha256sum --check "$SSH_KEY_SHA256SUM_FILE"
  echo ""

  echo "> Removing $TARBALL_NAME"
  shred --remove "$TARBALL_NAME"

  exit
fi

###################################################################################################
###################################### ENCRYPT SSH KEYS ###########################################
###################################################################################################
# remove existing tarball, encrypted tarball and sha256sum.txt

echo "> Removing $TARBALL_NAME"
shred --remove "$TARBALL_NAME" 2> /dev/null
echo "> Removing $ENCRYPTED_TARBALL_NAME"
shred --remove "$ENCRYPTED_TARBALL_NAME" 2> /dev/null
echo "> Removing $SHA256SUM_FILE"
shred --remove $SHA256SUM_FILE 2> /dev/null
echo "> Removing $SSH_KEY_SHA256SUM_FILE"
shred --remove $SSH_KEY_SHA256SUM_FILE 2> /dev/null

###################################################################################################
# generate sha256sum file for ssh keys
echo "Generating sha256sum for ssh keys into file $SSH_KEY_SHA256SUM_FILE"

# obtained from
#   https://unix.stackexchange.com/a/468747
#   https://askubuntu.com/a/1091369
find . \( -exec [ -f {}/.git ] \; -prune \) -o \( -name .git -prune \) -o \
! -name "." \
! -name .gitignore \
! -name README.md \
! -name allowed_signers \
! -name "*.sh" \
! -name known_hosts \
! -name sha256sum.txt \
! -name ssh-keys-checksum.txt \
! -name "*.tar.*" \
-exec sha256sum {} \; >> $SSH_KEY_SHA256SUM_FILE

echo "sha256sum for ssh keys"
cat $SSH_KEY_SHA256SUM_FILE
echo ""

###################################################################################################
# create a tarball
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
# remove tarball
shred --remove $TARBALL_NAME
shred --remove $SSH_KEY_SHA256SUM_FILE

###################################################################################################
