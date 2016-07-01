#!/bin/bash
set -v
if [ "${WERCKER_GIT_BRANCH}" != "master" ]; then
  # Wercker

  # Set current branch for ruby-saddler-reporter-support-git
  export CURRENT_BRANCH=${WERCKER_GIT_BRANCH}

  git diff -z --name-only origin/master \
   | xargs -0 bundle exec rubocop-select

  git diff -z --name-only origin/master \
   | xargs -0 bundle exec rubocop-select \
   | xargs bundle exec rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter

  git diff -z --name-only origin/master \
   | xargs -0 bundle exec rubocop-select \
   | xargs bundle exec rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | bundle exec checkstyle_filter-git diff origin/master

  git diff -z --name-only origin/master \
   | xargs -0 bundle exec rubocop-select \
   | xargs bundle exec rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | bundle exec checkstyle_filter-git diff origin/master \
   | bundle exec saddler report \
      --require saddler/reporter/github \
      --reporter Saddler::Reporter::Github::PullRequestReviewComment
fi
exit 0
