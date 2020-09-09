#!/bin/sh

sed -i '$d' /$HOME/.docker/config.json
sed -i '$d' /$HOME/.docker/config.json
echo -e "\n        },\n        \"experimental\": \"enabled\"\n}" >> /$HOME/.docker/config.json
