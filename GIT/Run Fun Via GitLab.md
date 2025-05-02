.gitlab-ci.yml

```r
stages:
  - generate

generate_global_index:
  stage: generate
  image: rocker/tidyverse:latest
  before_script:
    - apt-get update && apt-get install -y libgit2-dev libcurl4-openssl-dev libssl-dev libxml2-dev
    - Rscript -e "install.packages(c('yaml', 'fs', 'here', 'dplyr', 'purrr', 'lubridate'))"
  script:
    # Git setup
    - git config --global user.email "ci-bot@example.com"
    - git config --global user.name "CI Bot"
    - git reset --hard
    - git clean -fdx
    - git checkout $CI_COMMIT_BRANCH
    - git pull --rebase origin $CI_COMMIT_BRANCH
    - Rscript tables.R

    # Add, commit, and push changes
    - git add global_index.yml
    - git commit -m "gl bot adds global_index.yml [ci skip]" || echo "No changes"
    - git push https://${CI_PROJECT_PATH_SLUG}:${CI_PROJECT_TOKEN}@gitlab.lrz.de/${CI_PROJECT_PATH}.git HEAD:$CI_COMMIT_BRANCH
  only:
    - branches

```

