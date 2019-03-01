#!/usr/bin/env bash

source ./src/helpers.sh
source ./src/npm.sh

PACKAGE_NAME=$(getNpmPackageName)
PACKAGE_VERSION=$(getNpmPackageVersion)

# Remove existing dist script
[[ -f ./dist/index.sh ]] && rm ./dist/index.sh

# Append all the scripts together on a temporary file
for filename in ./src/*.sh; do
    cat $filename >> ./dist/tmp.sh
done
# Remove imports and shebang lines
sedi '/^source .*/d' ./dist/tmp.sh
sedi '/\#\!\/usr\/bin\/env bash/d' ./dist/tmp.sh

# Include shebang line and all the scripts
echo "#!/usr/bin/env bash" >> ./dist/index.sh
echo -e "# ${PACKAGE_NAME} - ${PACKAGE_VERSION}\n" >> ./dist/index.sh
# Compile rest of the code
cat ./dist/tmp.sh >> ./dist/index.sh

# Remove temporary file
[[ -f ./dist/tmp.sh ]] && rm ./dist/tmp.sh
