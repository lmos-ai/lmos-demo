#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

echo "Setting up port forwarding..."
# Get the service's port
istioctl dashboard kiali &
#istioctl dashboard jaeger &
istioctl dashboard grafana &
kubectl port-forward svc/lmos-runtime 8081:8081 &
kubectl argo rollouts dashboard &

