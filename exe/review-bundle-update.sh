#!/bin/bash

# gem prepare
gem install --no-document git_httpsable-push pull_request-create

# git prepare
# TODO: Allow to customize user
git config user.name sg-bot
git config user.email sg-bot@sonicgarden.jp
HEAD_DATE=$(date +%Y%m%d_%H-%M-%S)
HEAD="bundle/update-${HEAD_DATE}"

# checkout
git checkout -b "${HEAD}" origin/master

# bundle install
bundle --no-deployment --without nothing --jobs=4 --retry=3 --path vendor/bundle

# bundle update
bundle update

git add Gemfile.lock
git commit -m "Bundle update ${HEAD_DATE}"

# git push
git httpsable-push origin "${HEAD}"

# pull request
pull-request-create create --title="Bundle update by sgcop ${HEAD_DATE}"

exit 0
