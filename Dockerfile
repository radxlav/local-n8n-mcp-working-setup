FROM n8nio/n8n:latest

# Create a directory for custom nodes and set permissions
USER root
RUN mkdir -p /home/node/.n8n/nodes && chown -R node:node /home/node/.n8n

# Switch back to the node user
USER node

# Install the custom node package into the designated folder
WORKDIR /home/node/.n8n/nodes
RUN npm install n8n-nodes-mcp
