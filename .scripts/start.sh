#!/bin/bash
DOMAIN=fava.example.com
ARTIFACTS=/src/fava/.artifacts/
TAG=`wget --no-check-certificate -qO- -t1 -T2 "https://api.github.com/repos/beancount/fava/tags" | jq '.[0].name' | tr -d '"'`

pushd /src/fava
  wget https://ghproxy.com/https://github.com/beancount/fava/archive/refs/tags/${TAG}.tar.gz
  tar Cxzvvf . ${TAG}.tar.gz && rm ${TAG}.tar.gz
  pushd fava-${TAG:1}/contrib/docker
    nerdctl build -t fava .
  popd
  rm -rf fava-${TAG:1}
  echo "[INFO] Starting services ..."
  nerdctl compose down
  nerdctl compose up -d --remove-orphans

  ## nginx configuration
  echo "[INFO] Reloading Nginx configurations ..."
  sudo ln -sf $ARTIFACTS/nginx/$DOMAIN.crt /etc/ssl/certs/$DOMAIN.crt
  sudo ln -sf $ARTIFACTS/nginx/$DOMAIN.key /etc/ssl/private/$DOMAIN.key
  sudo ln -sf $ARTIFACTS/nginx/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
  nginx -s reload
popd
