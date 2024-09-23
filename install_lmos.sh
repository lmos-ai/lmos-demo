#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

# Exit immediately if a command exits with a non-zero status
#set -e

export OPENAI_API_KEY="<insert key here>"

# Install lmos-operator chart
helm upgrade --install lmos-operator oci://ghcr.io/lmos-ai/lmos-operator-chart \
 --version 0.0.4-SNAPSHOT

# Install virtual service for lmos-operator
kubectl apply -f istio/de-oneapp-vsvc-stable.yaml

# Create Kubernetes openai secret for lmos-runtime
kubectl delete secret lmos-runtime
kubectl create secret generic lmos-runtime --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY"
kubectl apply -f istio/openai-external-service-entry.yaml

# Install lmos-runtime chart
helm upgrade --install lmos-runtime oci://ghcr.io/lmos-ai/lmos-runtime-chart \
 --version 0.0.8-SNAPSHOT \
 --set openaiApiUrl=https://gpt4-uk.openai.azure.com/ \
 --set openaiApiModel=GPT35T-1106 \
 --set agentRegistryUrl=http://lmos-operator.default.svc.cluster.local:8080
