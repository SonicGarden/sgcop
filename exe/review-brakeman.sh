#!/bin/bash
reviewdog_version=0.9.12
if [ -z "${REVIEWDOG_GITHUB_API_TOKEN}" ]; then
  export REVIEWDOG_GITHUB_API_TOKEN="${GITHUB_ACCESS_TOKEN}"
fi

if [ ! -x /usr/local/bin/reviewdog ]; then
  curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s ${reviewdog_version}
fi

# Reporting
brakeman -A -qz -f json \
 | brakeman_translate_checkstyle_format translate \
 | reviewdog -f=checkstyle -name="brakeman" -reporter=github-pr-check

# For display
brakeman -A -qz
