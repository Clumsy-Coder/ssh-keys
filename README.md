# ssh-keys

Contains all SSH keys as an encrypted tarball

## Getting started

Clone the repo to `$HOME/.ssh/` directory

```bash
git clone git@github.com:Clumsy-Coder/ssh-keys.git ~/.ssh
```

### Cloning onto an existing `~/.ssh` folder

Since the folder already exists, you will have to:

1. init a git repo in the `~/.ssh` folder

    ```bash
    git init
    ```

2. add the repo remote url

    ```bash
    git remote add origin git@github.com:Clumsy-Coder/ssh-keys.git
    ```

3. stash any of the files just in case

    ```bash
    git stash -u -m "Stashing ssh keys before pulling commits from origin"
    ```

4. pull the commits from origin

    ```bash
    git pull origin master
    ```

5. apply the stash

    ```bash
    git stash apply
    ```

6. generate a new encrypted tarball

    ```bash
    ./secure.sh
    ```

7. commit the changes and push to origin

## Usage

### encrypting

This is used to archive and compress the ssh keys and then encrypt the tarball using `gpg`.

run command

```bash
./secure.sh
```

This will create a file `secrets.tar.gz.encrypted` and `sha256sum.txt`

- `secrets.tar.gz.encrypted` is the encrypted tarball that contains the ssh keys
- `sha256sum.txt` contains sha256sum of the **encrypted** tarball and the **decrypted** tarball

These are the only files allowed to be committed to git

### decrypting

This is used to decrypt the tarball and extract the ssh keys.

run command

```bash
./secure.sh --decrypt
```

This will:

1. check if encrypted tarball exists (exits if not found)
2. check file integrity of the encrypted tarball
3. decrypt the encrypted tarball
4. check integrity of the tarball
5. extract tarball contents to the current directory
6. check integrity of ssh keys
7. remove tarball

---

## Credits

Inspired by

- https://medium.com/@dyaa/pgp-and-ssh-keys-generate-export-backup-and-restore-c27baa109031
- https://medium.com/@retprogramisto/how-to-use-symmetric-password-encryption-with-gpg-af0d9734d08c
