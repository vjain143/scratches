Creating a Kestra workflow involves defining a series of tasks and steps that automate the process you described. Here's how you can create a Kestra workflow to:

1. Take an input from the user for the host name.
2. Update the Trino egress network policy file.
3. Push the updated file back to Bitbucket.
4. Kick off the Jenkins pipeline to deploy the change to a Kubernetes (k8s) cluster.

Here's a detailed Kestra workflow definition:

```yaml
id: trino-egress-network-update
namespace: devops
description: |
  A workflow to update the Trino egress network policy file, push it to Bitbucket,
  and kick off a Jenkins pipeline to deploy the change to a Kubernetes cluster.

inputs:
  - name: hostname
    type: STRING
    required: true

tasks:
  - id: update-network-policy
    type: io.kestra.plugin.scripts.shell.Bash
    description: Update the Trino egress network policy file with the new hostname
    commands:
      - |
        # Clone the Bitbucket repository
        git clone https://bitbucket.org/your-repo/trino-network-policies.git
        cd trino-network-policies

        # Update the network policy file with the new hostname
        sed -i 's/old-hostname/${{ inputs.hostname }}/g' trino-egress-policy.yaml

        # Commit and push the changes
        git config user.name "kestra-bot"
        git config user.email "kestra-bot@yourdomain.com"
        git add trino-egress-policy.yaml
        git commit -m "Update egress network policy with new hostname: ${{ inputs.hostname }}"
        git push origin main

  - id: trigger-jenkins-pipeline
    type: io.kestra.plugin.http.Request
    description: Trigger the Jenkins pipeline to deploy the changes
    uri: https://jenkins.yourdomain.com/job/your-pipeline/buildWithParameters
    method: POST
    headers:
      - key: Authorization
        value: Basic your_jenkins_token
    body: |
      {
        "parameter": [
          {
            "name": "HOSTNAME",
            "value": "${{ inputs.hostname }}"
          }
        ]
      }

  - id: wait-for-jenkins
    type: io.kestra.plugin.jenkins.JobStatus
    description: Wait for the Jenkins pipeline to complete
    jenkins:
      url: https://jenkins.yourdomain.com
      username: your_jenkins_username
      apiToken: your_jenkins_token
      job: your-pipeline
    pollingInterval: PT30S
    timeout: PT30M

  - id: notify-success
    type: io.kestra.plugin.slack.SendMessage
    description: Send a Slack notification on successful deployment
    token: your_slack_token
    channel: your-slack-channel
    text: "The Trino egress network policy has been successfully updated and deployed for hostname: ${{ inputs.hostname }}"

  - id: notify-failure
    type: io.kestra.plugin.slack.SendMessage
    description: Send a Slack notification on deployment failure
    token: your_slack_token
    channel: your-slack-channel
    text: "Failed to update and deploy the Trino egress network policy for hostname: ${{ inputs.hostname }}"

    when:
      condition: "{{ task('wait-for-jenkins').status == 'FAILED' }}"

  - id: clean-up
    type: io.kestra.plugin.scripts.shell.Bash
    description: Clean up the local repository
    commands:
      - |
        rm -rf trino-network-policies

    when:
      condition: "{{ task('wait-for-jenkins').status == 'COMPLETED' }} || {{ task('wait-for-jenkins').status == 'FAILED' }}"
```

### Explanation

1. **User Input**: The `inputs` section collects the hostname from the user.
2. **Update Network Policy**: The `update-network-policy` task clones the Bitbucket repository, updates the network policy file with the new hostname, and pushes the changes back to the repository.
3. **Trigger Jenkins Pipeline**: The `trigger-jenkins-pipeline` task sends a request to Jenkins to start the pipeline with the new hostname.
4. **Wait for Jenkins Completion**: The `wait-for-jenkins` task polls Jenkins to check the status of the pipeline.
5. **Notification**: The `notify-success` and `notify-failure` tasks send Slack notifications based on the result of the Jenkins pipeline.
6. **Clean Up**: The `clean-up` task removes the cloned repository to clean up the local environment.

Ensure you replace placeholders like `your-repo`, `yourdomain.com`, `your-pipeline`, `your_jenkins_token`, `your_jenkins_username`, and `your_slack_token` with your actual values.

This workflow automates the entire process from user input to deployment, providing notifications and cleaning up afterward.
