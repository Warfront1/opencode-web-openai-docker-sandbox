# opencode-web-openai-docker-sandbox

A secure way to run OpenCode Web with any OpenAI-compatible provider in a container until official Docker Sandbox support is added.

> [!TIP]
> This sandbox is specifically pre-configured for **OpenAI-compatible providers** (like Groq, Mistral, or self-hosted LLMs) using the `@ai-sdk/openai-compatible` standard.

### Architecture

```mermaid
graph TD
    subgraph Internet
        API[OpenAI-Compatible API]
    end

    subgraph "Docker Sandbox"
        direction TB
        subgraph "Internal Isolated Network"
            OC[opencode-app<br/>Port 4096]
        end

        subgraph "Gateway Bridge"
            NG[nginx-api-gateway<br/>Port 4096]
        end

        OC -- "API Requests<br/>(Internal Routing)" --> NG
        NG -- "Web UI Proxy" --> OC
    end

    NG -- "Secure Proxy (TLS/MTLS)<br/>(Custom API Key/Base)" --> API
    User((User)) -- "Web: http://127.0.0.1:4096" --> NG
    User((User)) -- "TUI: docker exec" --> OC
```

### Key Features
- **OpenAI-Compatible Focused:** Pre-configured to work seamlessly with any OpenAI-compatible API provider using the `@ai-sdk/openai-compatible` standard.
- **Network Isolation:** `opencode-app` has no direct internet access.
- **Secure Proxy:** `nginx-api-gateway` handles external communication, prevents header leaks, and enforces a 1M request limit.
- **Environment Safety:** API keys are managed by `nginx-api-gateway` and isolated from `opencode-app`.
- **Custom Provider Support:** Easily use any OpenAI-compatible endpoint.
- **Volume Mounting:** Expose your project via `PROJECT_DIR`.

### Quick Start
1. **Set your API Configuration:**
   ```bash
   # Required: Your API Key
   export CUSTOM_API_KEY=your_key_here

   # Required: The full base URL of your provider (including the API version path and trailing slash)
   # Example for OpenAI: https://api.openai.com/v1/
   # Example for a custom gateway: https://my-gateway.com/custom-path/v1/
   export CUSTOM_API_BASE=https://api.yourprovider.com/v1/

   # Optional: Comma-separated list of models to make available
   # Example: export CUSTOM_MODELS=llama3-70b,mixtral-8x7b
   export CUSTOM_MODELS=your-model-name
   ```
2. **Launch the Sandbox:**
   ```bash
   # PROJECT_DIR: The directory of YOUR project that you want OpenCode to work on
   export PROJECT_DIR=/path/to/your/project
   docker-compose down
   docker-compose up -d
   ```
3. **Access opencode-app:**
   - **Web:** http://127.0.0.1:4096/
   - **TUI:**
     ```bash
      docker exec -it opencode-app opencode --model 'my-openai-compatible-provider/your-model-name'
     ```

> [!NOTE]
> **Understanding `CUSTOM_API_BASE`:**
> The sandbox expects you to provide the *entire* base URL for your provider, including the versioned path (e.g., `/v1/`).
> The gateway will automatically handle request routing.
> - If your provider's full chat endpoint is `https://api.provider.com/v1/chat/completions`, set `CUSTOM_API_BASE` to `https://api.provider.com/v1/`.
> - If you encounter 404 errors, check the `X-Upstream-Url` header in the gateway logs to see the exact URL being requested.

---

## Optional: Toggling the Air Gap

**The air gap is enabled by default** - the sandbox is secure out of the box with no additional configuration needed.  
This section is only for advanced users who would want to toggle the air gap off, and then back on again.

> [!WARNING]
> Removing the air gap grants the AI assistant direct internet access.
> Only do this if you trust the AI model and understand the security implications.
>
> LLM API requests will still be routed securely through the NGINX gateway.

**Remove Air Gap (Grant Internet Access):**
```bash
docker network connect opencode-web-openai-docker-sandbox_internet_access opencode-app
```

**Restore Air Gap (Revoke Internet Access):**
```bash
docker network disconnect opencode-web-openai-docker-sandbox_internet_access opencode-app
```

**Verify Network Status:**
```bash
docker inspect opencode-app --format='{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}'
```
