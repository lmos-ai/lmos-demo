#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

# Exit immediately if a command exits with a non-zero status
#set -e
kubectl delete secret openai-secrets
kubectl create secret generic openai-secrets --from-env-file=arc_config.env

helm upgrade --install weather-agent oci://ghcr.io/lmos-ai/arc-weather-agent-chart --version 1.0.6
helm upgrade --install news-agent oci://ghcr.io/lmos-ai/arc-news-agent-chart --version 1.0.6