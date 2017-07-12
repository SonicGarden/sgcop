#!/bin/bash
set -v
export OCTOKIT_AUTO_PAGINATE=true

report() {
  gem install --no-document specific_install
  gem specific_install https://github.com/SonicGarden/sgcop.git # now we can not specify fixed version
  # gem install --no-document rubocop -v '0.49.1'
  # gem install --no-document haml_lint -v '0.26.0'
  gem install --no-document rubocop-select rubocop-checkstyle_formatter \
              checkstyle_filter-git saddler saddler-reporter-github

  # For display
  git diff -z --diff-filter=d --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master

  git diff --diff-filter=d --name-only origin/master \
   | grep -e '\.haml$' \
   | xargs haml-lint --reporter checkstyle \
   | checkstyle_filter-git diff origin/master

  # Reporting
  git diff -z --diff-filter=d --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter Saddler::Reporter::Github::PullRequestReviewComment

  git diff --diff-filter=d --name-only origin/master \
   | grep -e '\.haml$' \
   | xargs haml-lint --reporter checkstyle \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter Saddler::Reporter::Github::PullRequestReviewComment
}

if [ -n "${CIRCLECI}" ]; then
  # CircleCI
  if [ "${CIRCLE_BRANCH}" != "master" ]; then
    report
  fi
elif [ -n "${WERCKER_ROOT}" ]; then
  # Wercker
  if [ "${WERCKER_GIT_BRANCH}" != "master" ]; then
    # Set current branch for ruby-saddler-reporter-support-git
    export CURRENT_BRANCH=${WERCKER_GIT_BRANCH}
    report
  fi
fi

exit 0
