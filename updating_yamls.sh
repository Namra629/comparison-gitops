#!/bin/bash

set -e

echo "🚀 Adding content to PRD and DR YAML files..."

MQ_APPS=("order-qmgr" "order-owr-qmgr")

for app in "${MQ_APPS[@]}"; do
  for env in prd dr; do

    BASE="MQ-ROSA/$app/$env"

    echo "📁 Updating YAMLs in $BASE"

    # -----------------------------
    # configmap.yaml
    # -----------------------------
    cat <<EOF > "$BASE/configmap.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${app}-${env}-config
data:
  ENV: "${env}"
  APP_NAME: "${app}"
  LOG_LEVEL: "INFO"
  REGION: "us-east"
EOF

    # -----------------------------
    # kustomization.yaml
    # -----------------------------
    cat <<EOF > "$BASE/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - configmap.yaml
  - gm-template.yaml
  - route.yaml
EOF

    # -----------------------------
    # gm-template.yaml
    # -----------------------------
    cat <<EOF > "$BASE/gm-template.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: ${app}-${env}-pod
spec:
  containers:
    - name: ${app}
      image: nginx:stable
      env:
        - name: ENV
          value: "${env}"
        - name: APP
          value: "${app}"
EOF

    # -----------------------------
    # route.yaml
    # -----------------------------
    cat <<EOF > "$BASE/route.yaml"
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${app}-${env}-route
spec:
  to:
    kind: Service
    name: ${app}-${env}-svc
  port:
    targetPort: http
  tls:
    termination: edge
EOF

  done
done

echo "✅ PRD and DR YAML files updated successfully"
