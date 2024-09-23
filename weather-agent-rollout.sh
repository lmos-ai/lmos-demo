# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

kubectl argo rollouts set image weather-agent weather-agent=ghcr.io/lmos-ai/arc-weather-agent:2.0.0

kubectl argo rollouts get rollout weather-agent --watch  