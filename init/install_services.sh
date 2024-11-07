#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

# Exit immediately if a command exits with a non-zero status
#set -e

source .env

# Install Istio with the default profile and debug logging level
istioctl operator init
kubectl apply -f istio/istio-operator.yaml

#istioctl install --set profile=demo -y
kubectl apply -f ${ISTIO_HOME}/samples/addons/prometheus.yaml
kubectl apply -f ${ISTIO_HOME}/samples/addons/grafana.yaml
kubectl apply -f ${ISTIO_HOME}/samples/addons/kiali.yaml

# Label the default namespace for Istio sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Install lmos-operator chart
helm upgrade --install lmos-operator oci://ghcr.io/lmos-ai/lmos-operator-chart \
 --version 0.2.0

# Create Kubernetes openai secret for lmos-runtime
kubectl delete secret lmos-runtime 2> /dev/null
kubectl create secret generic lmos-runtime --from-literal=OPENAI_API_KEY="$OPENAI_APIKEY"

# Install lmos-runtime chart
helm upgrade --install lmos-runtime oci://ghcr.io/lmos-ai/lmos-runtime-chart \
 --version 0.0.11-SNAPSHOT \
 --set openaiApiUrl="$OPENAI_URL" \
 --set openaiApiModel="$OPENAI_MODELNAME" \
 --set agentRegistryUrl=http://lmos-operator.default.svc.cluster.local:8080

# Wait for CRD to be created before installing agents
echo "Waiting for LMOS agent CRD to be created..."
while ! kubectl get crd agents.lmos.ai >/dev/null 2>/dev/null; do sleep 1; done
echo "LMOS agent CRD created."

# Install agents
kubectl delete secret openai-secrets 2>/dev/null
kubectl create secret generic openai-secrets \
    --from-literal=ARC_AI_CLIENTS_0_APIKEY="$OPENAI_APIKEY" \
    --from-literal=ARC_AI_CLIENTS_0_MODELNAME="$OPENAI_MODELNAME" \
    --from-literal=ARC_AI_CLIENTS_0_URL="$OPENAI_URL" \
    --from-literal=ARC_AI_CLIENTS_0_ID="OPENAI" \
    --from-literal=ARC_AI_CLIENTS_0_CLIENT="$OPENAI_CLIENTNAME"

helm upgrade --install weather-agent oci://ghcr.io/lmos-ai/weather-agent-chart --version 1.0.7-SNAPSHOT
helm upgrade --install news-agent oci://ghcr.io/lmos-ai/news-agent-chart --version 1.0.7-SNAPSHOT

# Install arc-view chart
helm upgrade --install arc-view-runtime-web oci://ghcr.io/lmos-ai/arc-view-runtime-web-chart --version 0.1.0

# Wait for pods to be running
echo "Waiting for pods to be running..."
while ! kubectl get pods -n istio-system | grep kiali | grep -q Running; do sleep 1; done
while ! kubectl get pods -n istio-system | grep grafana | grep -q Running; do sleep 1; done
while ! kubectl get pods -n istio-system | grep prometheus | grep -q Running; do sleep 1; done
while ! kubectl get pods | grep lmos-runtime | grep -q Running; do sleep 1; done
while ! kubectl get pods | grep arc-view-runtime-web | grep -q Running; do sleep 1; done

# Set up port forwarding
echo "Setting up port forwarding..."
nohup kubectl -n istio-system port-forward svc/kiali 20001:20001 >/dev/null 2>&1 &
nohup kubectl -n istio-system port-forward svc/grafana 3000:3000 >/dev/null 2>&1 &
nohup kubectl -n istio-system port-forward svc/prometheus 9090:9090 >/dev/null 2>&1 &
nohup kubectl port-forward svc/lmos-runtime 8081:8081 >/dev/null 2>&1 &
nohup kubectl port-forward svc/arc-view-runtime-web-service 8080:80 >/dev/null 2>&1 &

echo "Setting up channel..."
# Stable Channel – Includes only the weather agent
kubectl apply -f init/acme-web-stable-channel.yml

# Route 100% of traffic to stable channels
kubectl apply -f istio/vsvc-stable.yaml