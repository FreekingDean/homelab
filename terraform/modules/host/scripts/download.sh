#! /bin/bash

set -e

download_files() {
  curl -L ${remote_url}.xz.sig > ./${filename}.xz.sig
  curl -L ${remote_url}.xz > ./${filename}.xz
}

cleanup() {
  rm -f ./${filename}.xz.sig
  rm -f ./${filename}.xz
  rm -f ./${filename}
}

cleanup
download_files
if gpgv --keyring ./.gpg/fedora.gpg ./${filename}.xz.sig ./${filename}.xz
then
  xz -d ${filename}.xz
  mkdir -p /var/lib/vz/images/999
  mv ${filename} /var/lib/vz/images/999/${filename}
else
  echo "Verification failed"
fi

cleanup
