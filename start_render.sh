#!/bin/bash
set -e

# Start all Multi-Agent services in background
echo "Starting Registry service on port 10000..."
python -m registry &
REGISTRY_PID=$!
sleep 2

echo "Starting Tax Agent on port 10102..."
python -m tax_agent &

echo "Starting Compliance Agent on port 10103..."
python -m compliance_agent &

sleep 3

echo "Starting Law Agent on port 10101..."
python -m law_agent &
sleep 3

echo "Starting Customer Agent on port 10100..."
python -m customer_agent &

sleep 3

echo "All internal agents started. Starting Public Web Proxy..."
# Start the proxy server that serves Frontend + exposes /messages API
# It will listen on $PORT and keep the container alive
python serve_render.py
