#! /bin/bash

set -e

download_files() {
  curl -L ${remote_url}.xz > ./${filename}.xz
}

cleanup() {
  rm -f ./${filename}.xz
  rm -f ./${filename}
}

cleanup
download_files

xz -d ${filename}.xz
mkdir -p /var/lib/vz/images/999
mv ${filename} /var/lib/vz/images/999/${filename}

cleanup
