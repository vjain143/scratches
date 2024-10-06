Let’s walk through how to integrate the Flask-based HTTP trigger with git-sync in a Kubernetes environment. We’ll run the Flask HTTP server in a sidecar container, and the git-sync container will be signaled to perform a sync when triggered.

Kubernetes Pod Setup with git-sync and HTTP Trigger

We will use the git-sync container to clone and sync a Git repository, and a second container to host the Flask HTTP server that triggers manual syncs.

1. Kubernetes Pod Manifest

Here is a Kubernetes manifest for a Pod running git-sync and the Flask HTTP server side by side:

apiVersion: v1
kind: Pod
metadata:
  name: git-sync-http-trigger-pod
spec:
  containers:
  # Main app container (optional)
  - name: app-container
    image: <your-application-image>
    volumeMounts:
    - name: git-sync-volume
      mountPath: /app/config

  # git-sync container
  - name: git-sync
    image: k8s.gcr.io/git-sync/git-sync:v4.2.2
    env:
    - name: GIT_SYNC_REPO
      value: "https://github.com/your/repo.git"  # Git repository URL
    - name: GIT_SYNC_BRANCH
      value: "main"  # Branch to sync
    - name: GIT_SYNC_ROOT
      value: "/git"  # Directory to sync the repo to
    - name: GIT_SYNC_WAIT
      value: "9999999"  # Long wait time to prevent polling
    - name: GIT_SYNC_PIDFILE
      value: "/tmp/git-sync.pid"  # Write git-sync's process ID to this file
    volumeMounts:
    - name: git-sync-volume
      mountPath: /git  # This volume is shared with the app

  # HTTP server container for triggering git-sync refresh
  - name: http-trigger
    image: git-sync-http-trigger:latest  # The Flask-based Docker image you built
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: git-sync-volume
      mountPath: /git  # Mount the same volume for access to files
    - name: shared-tmp
      mountPath: /tmp  # Shared tmp directory for accessing git-sync's PID file

  volumes:
  # Shared volume for the repo
  - name: git-sync-volume
    emptyDir: {}
  
  # Shared tmp volume for the git-sync PID file
  - name: shared-tmp
    emptyDir: {}

In this setup:

	•	app-container: Your main application container (optional) that uses the Git-synced files.
	•	git-sync container: Syncs the Git repository to the shared volume. The GIT_SYNC_WAIT is set to a very high number to prevent automatic polling, as we want the sync to happen manually.
	•	http-trigger container: Runs the Flask HTTP server from the image git-sync-http-trigger:latest (which you built earlier). This container sends a SIGHUP signal to the git-sync container when triggered via an HTTP POST request.
	•	Shared Volumes: Both containers share the Git repository directory (/git) and the tmp directory where git-sync writes its PID file (/tmp/git-sync.pid).

2. Deploy the Pod to Kubernetes

Save the manifest as git-sync-http-trigger-pod.yaml, then apply it to your Kubernetes cluster:

kubectl apply -f git-sync-http-trigger-pod.yaml

This will create the Pod with the git-sync and HTTP trigger containers.

3. Triggering a Manual Git Sync

To manually trigger a sync, send an HTTP POST request to the Flask server running in the http-trigger container. You can do this using a kubectl port-forward command to access the container’s port from your local machine.

First, forward the port:

kubectl port-forward pod/git-sync-http-trigger-pod 8080:8080

Then, trigger the sync:

curl -X POST http://localhost:8080/trigger-refresh

This will trigger a refresh by sending a SIGHUP signal to the git-sync process.

Additional Notes

	•	Scaling: If you’re running this setup with multiple replicas or deployments, you may want to adapt the Pod design to a deployment and use services to route HTTP traffic more effectively.
	•	Security: If needed, secure the Flask server endpoint with authentication or restrict access based on your use case.



Let’s walk through how to integrate the Flask-based HTTP trigger with git-sync in a Kubernetes environment. We’ll run the Flask HTTP server in a sidecar container, and the git-sync container will be signaled to perform a sync when triggered.

Kubernetes Pod Setup with git-sync and HTTP Trigger

We will use the git-sync container to clone and sync a Git repository, and a second container to host the Flask HTTP server that triggers manual syncs.

1. Kubernetes Pod Manifest

Here is a Kubernetes manifest for a Pod running git-sync and the Flask HTTP server side by side:

apiVersion: v1
kind: Pod
metadata:
  name: git-sync-http-trigger-pod
spec:
  containers:
  # Main app container (optional)
  - name: app-container
    image: <your-application-image>
    volumeMounts:
    - name: git-sync-volume
      mountPath: /app/config

  # git-sync container
  - name: git-sync
    image: k8s.gcr.io/git-sync/git-sync:v4.2.2
    env:
    - name: GIT_SYNC_REPO
      value: "https://github.com/your/repo.git"  # Git repository URL
    - name: GIT_SYNC_BRANCH
      value: "main"  # Branch to sync
    - name: GIT_SYNC_ROOT
      value: "/git"  # Directory to sync the repo to
    - name: GIT_SYNC_WAIT
      value: "9999999"  # Long wait time to prevent polling
    - name: GIT_SYNC_PIDFILE
      value: "/tmp/git-sync.pid"  # Write git-sync's process ID to this file
    volumeMounts:
    - name: git-sync-volume
      mountPath: /git  # This volume is shared with the app

  # HTTP server container for triggering git-sync refresh
  - name: http-trigger
    image: git-sync-http-trigger:latest  # The Flask-based Docker image you built
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: git-sync-volume
      mountPath: /git  # Mount the same volume for access to files
    - name: shared-tmp
      mountPath: /tmp  # Shared tmp directory for accessing git-sync's PID file

  volumes:
  # Shared volume for the repo
  - name: git-sync-volume
    emptyDir: {}
  
  # Shared tmp volume for the git-sync PID file
  - name: shared-tmp
    emptyDir: {}

In this setup:

	•	app-container: Your main application container (optional) that uses the Git-synced files.
	•	git-sync container: Syncs the Git repository to the shared volume. The GIT_SYNC_WAIT is set to a very high number to prevent automatic polling, as we want the sync to happen manually.
	•	http-trigger container: Runs the Flask HTTP server from the image git-sync-http-trigger:latest (which you built earlier). This container sends a SIGHUP signal to the git-sync container when triggered via an HTTP POST request.
	•	Shared Volumes: Both containers share the Git repository directory (/git) and the tmp directory where git-sync writes its PID file (/tmp/git-sync.pid).

2. Deploy the Pod to Kubernetes

Save the manifest as git-sync-http-trigger-pod.yaml, then apply it to your Kubernetes cluster:

kubectl apply -f git-sync-http-trigger-pod.yaml

This will create the Pod with the git-sync and HTTP trigger containers.

3. Triggering a Manual Git Sync

To manually trigger a sync, send an HTTP POST request to the Flask server running in the http-trigger container. You can do this using a kubectl port-forward command to access the container’s port from your local machine.

First, forward the port:

kubectl port-forward pod/git-sync-http-trigger-pod 8080:8080

Then, trigger the sync:

curl -X POST http://localhost:8080/trigger-refresh

This will trigger a refresh by sending a SIGHUP signal to the git-sync process.

Additional Notes

	•	Scaling: If you’re running this setup with multiple replicas or deployments, you may want to adapt the Pod design to a deployment and use services to route HTTP traffic more effectively.
	•	Security: If needed, secure the Flask server endpoint with authentication or restrict access based on your use case.

Would you like further assistance with extending this to a multi-pod deployment or securing the HTTP trigger?

Would you like further assistance with extending this to a multi-pod deployment or securing the HTTP trigger?