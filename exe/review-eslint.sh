#!/bin/bash
reviewdog_version=v0.9.12
if [ -z "${REVIEWDOG_GITHUB_API_TOKEN}" ]; then
  export REVIEWDOG_GITHUB_API_TOKEN="${GITHUB_ACCESS_TOKEN}"
fi

if [ ! -x /usr/local/bin/reviewdog ]; then
  curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s ${reviewdog_version}
fi

# Reporting
yarn run eslint -f checkstyle app \
 | ./bin/reviewdog -f=checkstyle -name=eslint -reporter=github-pr-review
exit 0
