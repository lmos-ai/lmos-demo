#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

# Install Istio with the default profile and debug logging level
istioctl operator init
kubectl apply -f istio/istio-operator.yaml

#istioctl install --set profile=demo -y
kubectl apply -f ${ISTIO_HOME}/samples/addons/prometheus.yaml
kubectl apply -f ${ISTIO_HOME}/samples/addons/grafana.yaml
kubectl apply -f ${ISTIO_HOME}/samples/addons/jaeger.yaml
kubectl apply -f ${ISTIO_HOME}/samples/addons/kiali.yaml

# Label the default namespace for Istio sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite