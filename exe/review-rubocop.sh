#!/bin/bash
reviewdog_version=0.9.8
if [ -z "${REVIEWDOG_GITHUB_API_TOKEN}" ]; then
  export REVIEWDOG_GITHUB_API_TOKEN="${GITHUB_ACCESS_TOKEN}"
fi

if [ ! -x /usr/local/bin/reviewdog ]; then
  sudo curl -fSL https://github.com/haya14busa/reviewdog/releases/download/${reviewdog_version}/reviewdog_linux_amd64 \
    -o /usr/local/bin/reviewdog \
    && sudo chmod +x /usr/local/bin/reviewdog
fi

# Reporting
rubocop \
 | reviewdog -f=rubocop -ci="circle-ci"
haml-lint --reporter checkstyle \
 | reviewdog -f=checkstyle -name="haml-lint" -ci="circle-ci"

exit 0
