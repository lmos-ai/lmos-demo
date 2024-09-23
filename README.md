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

### Step 2: Export your OpenAI Key which should be used
Once inside the development container, set up the necessary environment variables for OpenAI API access:

```
export OPENAI_API_KEY="<your key here>"
```

### Step 3: Check that Minikube and Istio started correctly
Ensure that Minikube and Istio have started correctly by checking the status of their pods:

```
kubectl get pods -n istio-system
```

You have to wait until the pods are started. The `istio-ingressgateway` is not important.
The status has to be `Running`.

### Step 4: Install LMOS
Now you can install the lmos-operatpr and lmos-runtime via Helm. This will deploy the necessary components for LMOS on this Kubernetes cluster.

```
./install_lmos.sh
```

You have to wait until the `lmos-operator` and `lmos-runtime` are started. To verify the installation, run:

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

### Step 5: Install Agents
Modify the `arc_config.env` file according to your specific requirements (e.g., API keys, URL). Once configured, install the LMOS agents using:

```
./install_agents.sh
```

This script installs two agents: a weather agent and a news agent. To verify the installation, run:

```
kubectl get agents
```

Output:

```
NAME                AGE
arc-news-agent      2m34s
arc-weather-agent   2m35s
```

### Step 6: Apply Channel Configuration
Apply two different channel configurations: one for stable usage and one for canary testing.
The stable version is only including a capability of the weather-agent. The Canary version is including capabilities of both agents.

Stable Channel – Includes only the weather agent:

``` 
kubectl apply -f samples/de-oneapp-stable-channel.yml
```

Canary Channel – Includes both the weather and news agents:

```
kubectl apply -f samples/de-oneapp-canary-channel.yml
```


You can list all channels with the following command:

```
kubectl get channels
```

Output:

```
NAME               RESOLVE_STATUS
de-oneapp-canary   RESOLVED
de-oneapp-stable   RESOLVED
```

The `RESOLVE_STATUS` of both channels has be `RESOLVED`, that means the required capabilities have been resolved.
If the status is `UNRESOLVED`, you can check the reason with: 

```
kubectl get channel de-oneapp-stable -o yaml
```

The can list the resolved channelroutings with:

```
kubectl get channelroutings
```

And look at a specific channel routing with:

```
kubectl get channelrouting de-oneapp-stable -o yaml
```

### Step 7: Access Kiali and Grafana
To visualize your setup, you'll need to forward some ports. Run the port-forwarding.sh script to forward ports for LMOS, Kiali, and Grafana:

```
./port-forwarding.sh
```

This script will forward the following ports:

- LMOS Runtime: http://localhost:8081
- Kiali: http://localhost:20001
- Grafana: http://localhost:3000

You can now access Kiali and Grafana in your web browser using the URLs provided above.

### Step 8: Execute a POST request

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
If you modify the request content to something the weather agent cannot handle, like: `"content": "Summarize the page https://containers.dev/"`

```
./test_runtime_2.sh
```

Output:

```
{"content":"I cannot help with that issue."}
```

The response will indicate that no agent can handle the request.

### Step 9: Apply the canary configuration 
To route all traffic to the canary configuration (which includes the news agent), apply the following Istio virtual service configuration:

```
kubectl apply -f istio/de-oneapp-vsvc-canary.yaml
```

### Step 10: Execute a second POST request
Execute another test request using Postman or the test_runtime.sh script

```
./test_runtime_2.sh
```

Output:

```
{"content":"The page https://containers.dev/ is about \"Development Containers\" - which is an open specification for enriching containers with development-specific content and settings. It allows developers to use a container as a full-featured development environment, run applications, separate tools, libraries, or runtimes needed for working with a codebase, and aid in continuous integration and testing. It provides more information about the Development Container Specification, a reference implementation, supporting tools, and services."}
```

Now, requests like the one to summarize a web page will be handled by the news agent, as the request is forwarded to the canary configuration.


## Code of Conduct

This project has adopted the [Contributor Covenant](https://www.contributor-covenant.org/) in version 2.1 as our code of conduct. Please see the details in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). All contributors must abide by the code of conduct.

By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Licensing
Copyright (c) 2024 Deutsche Telekom AG.

Sourcecode licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0) (the "License"); you may not use this project except in compliance with the License.

This project follows the [REUSE standard for software licensing](https://reuse.software/).    
Each file contains copyright and license information, and license texts can be found in the [./LICENSES](./LICENSES) folder. For more information visit https://reuse.software/.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the LICENSE for the specific language governing permissions and limitations under the License.