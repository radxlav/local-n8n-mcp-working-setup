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

Your AI assistant needs to be told how to connect to the n8n-MCP server. Add the following configuration to your assistant's MCP server settings. You will also need to create a `.env` file in this directory.

**1. Create a `.env` file:**

Create a file named `.env` in this directory and add your API key to it:

```
N8N_API_KEY=your-api-key-from-step-2
```

**2. Configure Windsurf:**

Add the following JSON block to your Windsurf MCP configuration file:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "MCP_MODE=stdio",
        "-e", "LOG_LEVEL=error",
        "-e", "DISABLE_CONSOLE_OUTPUT=true",
        "-e", "N8N_API_URL=http://host.docker.internal:5679",
        "-e", "N8N_API_KEY=${N8N_API_KEY}",
        "ghcr.io/czlonkowski/n8n-mcp:latest"
      ]
    }
  }
}
```

*Note: `http://host.docker.internal:5679` is a special DNS name that allows the MCP Docker container to communicate with the n8n container running on your host machine.*

### Step 4: Restart and Verify

Restart your AI assistant (Windsurf) to apply the new configuration. You can test the connection by asking the AI to "list n8n workflows".

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
