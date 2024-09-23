#!/bin/bash

# SPDX-FileCopyrightText: 2024 Deutsche Telekom AG
#
# SPDX-License-Identifier: Apache-2.0

curl --location 'http://localhost:8081/lmos/runtime/apis/v1/de/chat/12345/message' \
--header 'x-turn-id: 1234' \
--header 'x-correlation-id: 1234' \
--header 'x-subset: stable' \
--header 'Content-Type: application/json' \
--data '{
    "inputContext": {
        "messages": [
        {
            "role": "user",
            "format": "text",
            "content": "Summarize the page https://containers.dev/"
        }
        ]
    },
    "systemContext": {
        "channelId": "oneapp"
    },
    "userContext": {
        "userId": "user456"
    }
}'