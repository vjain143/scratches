Architecture & Flow:
	•	Bitbucket repository stores network policy YAML files (network-policy.yaml).
	•	A Kubernetes CronJob regularly pulls files from Bitbucket.
	•	CronJob applies changes to Kubernetes network policy automatically.
	•	Authentication via Bitbucket access tokens or SSH keys stored in Kubernetes Secrets.

Tech Stack:
	•	Git CLI
	•	Kubectl CLI
	•	Kubernetes CronJob (or Job/Deployment)
	•	Bitbucket repository (private or public)
	•	Kubernetes Secret (for secure token storage)

⸻

✅ Step-by-Step Setup:

🟢 Step 1: Prepare Your Bitbucket Repository

Structure your Bitbucket repo clearly:
my-repo
 ├── network-policies
 │    └── network-policy.yaml
 └── scripts
      └── apply-policies.sh
	•	network-policy.yaml: Contains your Kubernetes network policy (e.g., CiliumNetworkPolicy).
	•	apply-policies.sh: Simple bash script to apply YAML files to Kubernetes.

⸻

🟢 Step 2: Create the apply-policies.sh Script

File: scripts/apply-policies.sh
#!/bin/bash
set -e

POLICY_DIR="/repo/network-policies"

echo "Applying network policies from Bitbucket repo..."

kubectl apply -f "$POLICY_DIR/network-policy.yaml"
Make sure to commit this file to your repository.

⸻

🟢 Step 3: Create a Bitbucket Token or SSH Key

In Bitbucket:
	•	Create an App password (recommended) or SSH key for accessing your repo.
	•	Assign read-only permissions (Repository → Read access).

⸻

🟢 Step 4: Store Your Bitbucket Credentials in a Kubernetes Secret

Create a secret containing Bitbucket credentials:
kubectl create secret generic bitbucket-creds \
  --from-literal=username="your-bitbucket-username" \
  --from-literal=password="your-bitbucket-app-password"
If you prefer SSH, use SSH keys instead.

⸻

🟢 Step 5: Define the Kubernetes CronJob (or Job/Pod)

Create a CronJob YAML that regularly updates the network policies:

bitbucket-policy-updater.yaml

apiVersion: batch/v1
kind: CronJob
metadata:
  name: bitbucket-policy-updater
  namespace: default
spec:
  schedule: "*/5 * * * *"  # every 5 minutes (adjust as needed)
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: updater
            image: bitnami/git:latest  # Contains git and basic shell
            command:
            - /bin/sh
            - -c
            - |
              git clone https://$(BITBUCKET_USERNAME):$(BITBUCKET_PASSWORD)@bitbucket.org/your-org/my-repo.git /repo
              apk add --no-cache curl bash kubectl
              chmod +x /repo/scripts/apply-policies.sh
              /repo/scripts/apply-policies.sh
            env:
            - name: BITBUCKET_USERNAME
              valueFrom:
                secretKeyRef:
                  name: bitbucket-creds
                  key: username
            - name: BITBUCKET_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: bitbucket-creds
                  key: password
          restartPolicy: OnFailure
          serviceAccountName: network-policy-updater
Explanation:
		•	CronJob runs every 5 minutes (customize as needed).
	•	Git is used to clone the repository.
	•	Credentials loaded securely from Kubernetes secrets.
	•	Kubectl applies the network policy automatically.

⸻

🟢 Step 6: Configure RBAC Permissions

Your CronJob needs RBAC permissions to apply network policies.

service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: network-policy-updater
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: network-policy-updater-role
rules:
- apiGroups: ["networking.k8s.io", "cilium.io"]
  resources: ["networkpolicies", "ciliumnetworkpolicies"]
  verbs: ["get", "list", "create", "update", "patch", "apply"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: network-policy-updater-binding
subjects:
- kind: ServiceAccount
  name: network-policy-updater
  namespace: default
roleRef:
  kind: ClusterRole
  name: network-policy-updater-role
  apiGroup: rbac.authorization.k8s.io

🟢 Step 7: Deploy and Verify

Deploy your CronJob:
kubectl apply -f bitbucket-policy-updater.yaml

Check the status:
kubectl get cronjobs
kubectl get jobs
kubectl logs <job-pod-name>

You should see logs indicating the network policy YAML is applied successfully.

⸻

🧹 Maintenance Tips:
	•	Ensure the repository access token is rotated periodically.
	•	Adjust cron schedule based on your desired frequency.
	•	Integrate monitoring and alerting to notify you if policy updates fail.

⸻

📌 Advantages of this approach:
	•	Centralized version control of policies in Bitbucket.
	•	Automatic synchronization between Bitbucket and Kubernetes cluster.
	•	Secure secret handling via Kubernetes Secrets.
	•	Fully open-source and free stack.
kubectl apply -f service-account.yaml
