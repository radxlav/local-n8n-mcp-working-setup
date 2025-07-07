# n8n Local Development Environment with AI (MCP)

This project sets up a local n8n instance using Docker and connects it to an AI assistant (like Windsurf/Claude) via the n8n-MCP server. This allows the AI to intelligently build, manage, and validate n8n workflows.

## Prerequisites

1.  **Docker**: You must have Docker installed and running on your system. [Install Docker](https://www.docker.com/products/docker-desktop).
2.  **AI Assistant Environment**: An environment capable of connecting to MCP servers (e.g., Windsurf).

---

## 1. Initial Setup

Follow these steps to launch the n8n instance and configure the AI assistant.

### Step 1: Launch n8n

Open your terminal in this project directory and run:

```bash
docker-compose up -d
```

This command will build the n8n Docker image (if it doesn't exist) and start the n8n service in the background. Your n8n instance will be available at [http://localhost:5679](http://localhost:5679).

### Step 2: Set Up n8n and Get API Key

1.  Open your browser and navigate to [http://localhost:5679](http://localhost:5679).
2.  If it's your first time, you will be prompted to create an owner account. Complete the setup.
3.  Once logged in, go to **Credentials** -> **API**.
4.  Click **Add API**, give it a descriptive name (e.g., `windsurf-mcp-key`), and copy the generated API key.

### Step 3: Configure Your AI Assistant (Windsurf)

Your AI assistant connects to n8n through an MCP server. Instead of running another Docker container, we'll use a simpler method: running the MCP server directly on your local machine.

**1. Install the n8n MCP Server:**

If you haven't already, install the `n8n-mcp-server` globally using npm:

```bash
npm install -g @leonardsellem/n8n-mcp-server
```

**2. Configure Windsurf:**

Open your Windsurf `mcp_config.json` file. You can usually find it at `~/.codeium/windsurf/mcp_config.json`. Add the following server configuration.

*__Important:__ This is a complete, working example. You will need to replace the placeholder values for `command` and `N8N_API_KEY` with your specific details.*

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@executeautomation/playwright-mcp-server"
      ],
      "env": {}
    },
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ]
    },
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@dev",
        "--access-token",
        "sbp_v0_d4c3b3b96773f940b5c155c466b12d47d1b248dd"
      ]
    },
    "cloudflare-observability": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://observability.mcp.cloudflare.com/sse"
      ]
    },
    "n8n-local": {
      "command": "/Users/radoslawkmita/.npm-global/bin/n8n-mcp-server",
      "args": [],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "http://localhost:5679/api/v1",
        "N8N_API_KEY": "your-api-key-from-step-2"
      },
      "disabled": false
    },
    "n8n-windsurf": {
      "command": "npx",
      "args": [
        "n8n-mcp"
      ],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "http://localhost:5679/api/v1",
        "N8N_API_KEY": "your-api-key-from-step-2"
      },
      "disabled": true
    }
  }
}
```

**Key Configuration Points:**
-   **`command`**: This is the absolute path to the MCP server executable.
-   **`N8N_API_URL`**: This must point to your n8n instance's API endpoint. The default is `http://localhost:5679/api/v1`. The `/api/v1` path is crucial and often missed.
-   **`N8N_API_KEY`**: The secret key for authentication.

*Note: This configuration replaces the previous Docker-based setup. It's simpler to manage and debug.*

### Step 4: Restart and Verify

Restart your AI assistant (Windsurf) to apply the new configuration. You can test the connection by asking the AI to "list n8n workflows" or "create a new workflow".

---

## 2. Backup and Restore

Your entire n8n setup (workflows, credentials, etc.) is stored persistently. Here’s how to manage it.

### How it Works

The `docker-compose.yml` file uses a named Docker volume called `n8n_data` to store all of n8n's data outside the container. This data persists even if the container is stopped or deleted.

### Creating a Backup

To create a full backup, you need to copy two items:

1.  **The configuration files**: `docker-compose.yml`, `Dockerfile`, and your `.env` file.
2.  **The n8n data volume**: The contents of the `n8n_data` directory in this project.

Simply copy these files to a safe location.

### Restoring from a Backup

1.  Place your backed-up `docker-compose.yml`, `Dockerfile`, and `.env` files into a new, empty directory.
2.  Copy your backed-up `n8n_data` directory into the same location.
3.  Open a terminal in that directory and run `docker-compose up -d`.

Your n8n instance will start up with all your workflows and settings restored exactly as they were.

---

## 3. File Manifest

Here are the essential files for this project:

-   `README.md`: This setup guide.
-   `docker-compose.yml`: Defines the n8n service, its port, and the data volume. **Essential.**
-   `Dockerfile`: Defines the custom n8n image build process. **Essential.**
-   `.env`: Stores your secret API key. **Essential, do not commit to public git repositories.**
-   `n8n-data/`: The directory where your n8n data is stored. **This is your data, back it up!**
-   `.gitignore`: Prevents sensitive files like `.env` and large directories like `n8n-data` from being committed to Git. Recommended.
