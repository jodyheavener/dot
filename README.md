# Jody's Dot Files

Make sure you look through everything and tailor it to your needs first.

Just run `sh setup.sh` and follow the prompts. Restart your computer after.

### Also install

- nvm
- rbenv
- brew (see `brew-list`)
- Docker
- Lando

### Manual setups

- SSH (`~/.ssh`)
- AWS (`~/.aws/credentials`):

  ```
  [default]
  aws_access_key_id = ACCESS_KEY
  aws_secret_access_key = SECRET_KEY

  [environment]
  aws_access_key_id = ACCESS_KEY
  aws_secret_access_key = SECRET_KEY

  ...
  ```
