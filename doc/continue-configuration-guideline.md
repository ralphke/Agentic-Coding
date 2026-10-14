# Configuration Guide: Continue, Foundry, and Ollama for Agentic SDL

## Introduction

This guide outlines the configuration steps needed to set up a local environment using **Visual Studio Code (VSCode)**, **VScode Continue Extension**, **Foundry CLI**, and **Ollama CLI** to support a sophisticated **Agentic Software Development Life-Cycle (SDLC)**. This setup enables the development of complex AI-driven applications with local execution, without relying on cloud-based services.

---

## Prerequisites

- A **powerful PC** with +32GB RAM, GPU, NPU and Intel Core Ultra 7+ CPU.
- **Linux** or **macOS** (Windows is not officially supported, but can be used with WSL or Docker).
- **Python 3.10+** installed.
- **Docker** installed and running.
- **Ollama** installed and running.
- **Foundry** installed and running.
- **Continue Extension** installed and running.

---

## Step 1: Install Ollama

Ollama is a local LLM (Large Language Model) runtime that allows you to run models locally.

### Installation

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Start Ollama

```bash
ollama serve
```

### Pull and Run a Model

```bash
ollama pull qwen3-coder
ollama pull clef-flash
```

"💡 Tip: You can verify model availability using:"

```bash
ollama list
```

---

## Step 2: Install Foundry

Foundry is a suite of tools for building and deploying AI applications locally.

# Configuration Guide: Continue, Foundry, and Ollama for Agentic SDL
## Introduction

This guide outlines the configuration steps needed to set up a local environment using **Visual Studio Code (VSCode)**, **VScode Continue Extension**, **Foundry CLI**, and **Ollama CLI** to support a sophisticated **Agentic Software Development Life-Cycle (SDLC)**. This setup enables the development of complex AI-driven applications with local execution, without relying on cloud-based services.

---

## Prerequisites

- A **powerful PC** with +32GB RAM, GPU, NPU and Intel Core Ultra 7+ CPU.
- **Linux** or **macOS** (Windows is not officially supported, but can be used with WSL or Docker).
- **Python 3.10+** installed.
- **Docker** installed and running.
- **Ollama** installed and running.
- **Foundry** installed and running.
- **Continue Extension** installed and running.

---

## Step 1: Install Ollama

Ollama is a local LLM (Large Language Model) runtime that allows you to run models locally.

### Installation

```bash
curl -L https://foundry.ai/install.sh | sh
```

### Start Foundry

```bash
foundry server start
```

"⚠️ Note: Make sure that Foundry runs on port 58303 by default. You may adjust this in ~/.foundry/config.yaml if needed."

---

## Step 3: Install Continue

Continue is a framework for building and managing AI agents locally.

### Installation

```bash
pip install continue
```

### Start Continue

```bash
continue serve
```

"⚠️ Default port used by Continue is 8000. Adjust if needed via config file or CLI options."

---

## Step 4: Configure the Environment

### 1. Configure Ollama

Set the `OLLAMA_HOST` environment variable to point to the Ollama service:

```bash
export OLLAMA_HOST=http://localhost:11434
```

### 2. Configure Foundry

Set the `FOUNDRY_HOST` environment variable to point to the Foundry service:

```bash
export FOUNDRY_HOST=http://localhost:58303
```

### 3. Configure Continue

Set the `CONTINUE_HOST` environment variable to point to the Continue service:

```bash
export CONTINUE_HOST=http://localhost:8000
```

---

## Step 5: Launch the Agentic SDL

With all services running, you can now use Continue to create and manage AI agents that interact with Foundry and Ollama.

### Example: Create an AI Agent

```python
from continue import Agent

agent = Agent(
    name="my_agentic_agent",
    model="Qwen3-Coder",
    tools=[
        {"type": "foundry", "url": "http://localhost:58303"},
        {"type": "ollama", "url": "http://localhost:11434"}
    ]
)

response = agent.run("What is the best way to optimize a machine learning pipeline?")
print(response)
```

---

## Step 6: Monitor and Manage the Workflow

- Use the **Foundry** UI to monitor AI agent interactions and model performance.
- Use the **Continue** UI to manage agent workflows and configurations.
- Use **Ollama** CLI or Web UI to monitor and manage model performance and resource usage.

---

## Step 7: Monitor and Manage the Workflow

- Use the Foundry UI to monitor AI agent interactions and model performance.
- Use the Continue UI to manage agent workflows and configurations.
- Use Ollama to monitor and manage model performance and resource usage.

---

## Optional: Automate Setup with a Bash Script

Create a script called setup-agentic.sh:

```bash
#!/bin/bash

echo "Starting setup for Agentic SDL..."

# Start Ollama service
ollama serve &

# Pull required models
ollama pull qwen3-coder
ollama pull clef-flash

# Start Foundry
foundry server start &

# Start Continue
continue serve &

echo "All services started!"
```

Make executable and run:

```bash
chmod +x setup-agentic.sh
./setup-agentic.sh
```


## Conclusion

By combining **Continue**, **Foundry**, and **Ollama**, you can create a powerful local environment for an agentic SDL. This setup enables you to build, test, and deploy sophisticated AI applications without relying on cloud-based services.

Let me know if you need further assistance or a script to automate this setup!