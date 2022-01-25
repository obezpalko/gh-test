# gh-test
## how is everything working
1. (this) github repo: https://github.com/obezpalko/gh-test
1. [Jenkins](Jenkinsfile) pipeline creates new docker container and upload it to the registry
1. [terraforming](./terraform) instance:

   configure Your credentials with `~/.aws/credentials` and `~/.aws/config`

   f.e
   ```
   # ~/.aws/credentials
   [gh-test]
   aws_access_key_id = AKXXXX
   aws_secret_access_key = KYYYY

   # ~/.aws/config
   [profile gh-test]
   region = eu-central-1
   cli_pager=
   ```

   then apply terraform: `cd terraform && terraform apply -auto-approve`

   it will create `t2.micro` instace and deploy app to it

   there is python script inside terraform to detect my home provider ip addresses. SSH is only allowed from Partner networks

1. Helm charts are under [gh-test-chart](./gh-test-chart) and applied automatically on the instance creation.

   I didn't realize automatic app updates (because the cluster may still not be created at this time), but I suppose to use 1 of the following methods:
   1. create jenkins-agent with helm and set env `TOKEN` and `CLUSTER_URL` to authenticate in the cluster
   1. use generic agent with ssh (env `SSH_PRIVATE_KEY` and `INSTANCE_IP`) to the created node (helm already istalled) and apply charts locally

   I see both plus and minuses for both ways, but really have no time to do this right now.
