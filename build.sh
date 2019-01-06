#!/usr/bin/env bash

[[ -f ./dist/index.sh ]] && rm ./dist/index.sh
for filename in ./src/*.sh; do
    cat $filename >> ./dist/index.sh
done
sed -i '/^source .*/d' ./dist/index.sh
sed -i '/\#\!\/usr\/bin\/env bash/d' ./dist/index.sh
sed -i '1i\#\!\/usr\/bin\/env bash' ./dist/index.sh
