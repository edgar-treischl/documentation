```r
# Use an image with necessary tools
image: "rocker/r-ver:latest"

stages:
  - backup

backup:
  stage: backup
  script:
    # Install necessary tools
    - apt-get update -qq && apt-get install -y git

    # Set up SSH key and known hosts for GitLab
    - mkdir -p ~/.ssh
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
    - ssh-keyscan gitlab.lrz.de >> ~/.ssh/known_hosts

    # Clone the repository using SSH
    - git clone --mirror git@gitlab.lrz.de:edgar.treischl/trigger.git

    # Create the backup tarball
    - tar -czf backup-trigger.tar.gz trigger.git

    # Upload the backup to DigitalOcean Space
    - aws --endpoint-url https://edgarbucket.fra1.digitaloceanspaces.com s3 cp backup-trigger.tar.gz s3://edgarbucket/backup-trigger.tar.gz

    # Test if the file was uploaded successfully by listing the contents of the Space
    - aws --endpoint-url https://edgarbucket.fra1.digitaloceanspaces.com s3 ls s3://edgarbucket/backup-trigger.tar.gz

  rules:
    # Trigger the backup job on push to the default branch
    - if: '$CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH'

    # Ensure the backup job can also be triggered by a schedule
    - if: '$CI_PIPELINE_SOURCE == "schedule"'


```
