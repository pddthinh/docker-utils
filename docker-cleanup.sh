#!/bin/bash

xargsOPT=""

OS=`uname -s`
case "OS" in
    Linux*)
        xargsOPT="-r"
    ;;
esac

# remove exited containers:
docker ps --filter status=dead --filter status=exited -aq | xargs $xargsOPT docker rm -v
    
# remove unused images:
docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs $xargsOPT docker rmi

# remove unused volumes:
find '/var/lib/docker/volumes/' -mindepth 1 -maxdepth 1 -type d | grep -vFf <(
  docker ps -aq | xargs docker inspect | jq -r '.[] | .Mounts | .[] | .Name | select(.)'
) | xargs $xargsOPT rm -fr
