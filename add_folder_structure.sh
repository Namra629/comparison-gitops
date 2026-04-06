#!/bin/bash

set -e

echo "🚀 Creating ACE and MQ folder structure..."

# -----------------------------
# ACE-ROSA
# -----------------------------
mkdir -p ACE-ROSA/argocd
touch ACE-ROSA/argocd/.gitkeep

echo "✅ ACE-ROSA structure created"

# -----------------------------
# MQ-ROSA
# -----------------------------

MQ_APPS=("order-qmgr" "order-owr-qmgr")

for app in "${MQ_APPS[@]}"; do

  echo "📁 Creating structure for $app"

  for env in dev dr prd pp qa; do

    BASE="MQ-ROSA/$app/$env"

    mkdir -p "$BASE"

    # Always add .gitkeep
    touch "$BASE/.gitkeep"

    # Define common files for environments
    if [[ "$env" == "qa" || "$env" == "prd" || "$env" == "dr" ]]; then
      touch "$BASE/configmap.yaml"
      touch "$BASE/kustomization.yaml"
      touch "$BASE/gm-template.yaml"
      touch "$BASE/route.yaml"
    fi

  done

done

echo "✅ MQ-ROSA structure created"

echo "🎯 Folder structure ready. Now commit and push:"
echo "   git add ."
echo "   git commit -m \"Add ACE and MQ folder structure\""
echo "   git push origin main"
