#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

# Exit immediately if a command exits with a non-zero status
#set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/.env"

helm upgrade --install productsearch-agent oci://ghcr.io/lmos-ai/productsearch-agent-chart --version 0.1.0-snapshot
helm upgrade --install techspec-agent oci://ghcr.io/lmos-ai/techspec-agent-chart --version 0.1.0-snapshot

kubectl apply -f "$SCRIPT_DIR/product-recommender-channel.yml"
