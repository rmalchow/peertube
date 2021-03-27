#!/bin/bash
set -e
set +x

docker login -u ${CI_EMAIL} -p ${CI_PASSWORD} harbor.rand0m.me

export TAG=harbor.rand0m.me/public/${CI_PROJECT_NAME}:latest
docker build -t ${TAG} .
docker push ${TAG}
