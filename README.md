# LMOS demo

A LMOS demo using GitHub Codespaces / Development Containers.

## Prerequisites

Before you begin, ensure the following tools are installed and running on your local machine:

- [Docker](https://docs.docker.com/get-docker/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Using the Development Container

### Step 1: Open the Repository in a Dev Container

1. Clone the repository:
    ```shell
    git clone https://github.com/lmos-ai/lmos-demo.git
    cd lmos-demo

2. Open the repository in Visual Studio Code:

3. Open the Command Palette (F1 or Ctrl+Shift+P) and select `Remote-Containers: Reopen in Container`. This will build and open the repository in a Docker-based development container.

### Step 2: Set OpenAI Connection Details
Once inside the development container, set up the necessary environment variables for OpenAI API access in the `.env` file.
This OpenAPI access is used by the `lmos-runtime` and the agents.

```
OPENAI_APIKEY="<your-openai-api-key>"
OPENAI_CLIENTNAME="azure"
OPENAI_MODELNAME="gpt-4o-mini"
OPENAI_URL="https://api.openai.com"
```

### Step 3: Check the Setup

To verify the installation of LMOS, run:

```
kubectl get pods
```

Output:

```
NAME                               READY   STATUS    RESTARTS   AGE
lmos-operator-c45887647-bcwf8      2/2     Running   0          4m16s
lmos-runtime-85654bc6bc-chvrj      2/2     Running   0          4m15s
```

The status has to be `2/2 Running`.

Two agents have been installed, you can list them with 

```
kubectl get agents
```

Output:

```
NAME                AGE
arc-news-agent      2m34s
arc-weather-agent   2m35s
```

One channel has been defined, using the capability of the weather-agent.

You can list available channels with the following command:

```
kubectl get channels
```

Output:

```
NAME               RESOLVE_STATUS
acme-web-stable    RESOLVED
```

The `RESOLVE_STATUS` of the channel has to be `RESOLVED`, which means the required capabilities have been resolved.
If the status is `UNRESOLVED`, you can check the reason with: 

```
kubectl get channel acme-web-stable -o yaml
```

You can list the resolved channelroutings with:

```
kubectl get channelroutings
```

And look at a specific channel routing with:

```
kubectl get channelrouting acme-web-stable -o yaml
```

### Step 4: Access Kiali and Grafana

To visualize your setup, various ports have been forwarded for LMOS, Kiali, Prometheus, Jaeger, Grafana and ArgoCD. You can access these tools at

- Kiali: http://localhost:20001
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:9411
- ArgoCD: http://localhost:3100
- LMOS Runtime: http://localhost:8081
- Arc View: http://localhost:8080

### Step 5: Execute a POST request

You can use Postman or the `test_runtime.sh` script to send a test request to the LMOS runtime. 
The `lmos-runtime` is uses the `lmos-router` to route the request to the appropriate agent.

To test the weather agent, run:

```
./test_runtime.sh
```

Output:

```
{"content":"The weather in London is 21 degrees."}
```

You will see that the weather-agent has responded. 

## Using ArgoCD for deployment

You can add the `argocd-apps` folder as new ArgoCD Application to your existing cluster ArgoCD managed cluster. You only need to adapt the secrets.yaml. 

## Code of Conduct

This project has adopted the [Contributor Covenant](https://www.contributor-covenant.org/) in version 2.1 as our code of conduct. Please see the details in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). All contributors must abide by the code of conduct.

By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Licensing
Copyright (c) 2024 Deutsche Telekom AG.

Sourcecode licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0) (the "License"); you may not use this project except in compliance with the License.

This project follows the [REUSE standard for software licensing](https://reuse.software/).    
Each file contains copyright and license information, and license texts can be found in the [./LICENSES](./LICENSES) folder. For more information visit https://reuse.software/.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the LICENSE for the specific language governing permissions and limitations under the License.