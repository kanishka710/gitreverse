# Deployment Guide

This document outlines the deployment process for GitReverse.

## Prerequisites

- Docker and Docker Compose
- Node.js (if running locally without Docker)
- Required environment variables (see `.env.example`)

## Environment Variables

Make sure to configure all necessary environment variables in `.env.local` before deploying. Key variables include:

- `VIEWS_IP_SALT`: Required for production. Generate using `openssl rand -hex 32`.
- `SUPABASE_URL` & `SUPABASE_PUBLISHABLE_KEY`: Required for caching game reverse prompts.
- `FIRECRAWL_API_KEY` or `CONTEXT_DEV_API_KEY`: Required for website reversal.

## Deploying with Docker

The easiest way to deploy GitReverse is using Docker Compose.

1.  Build and start the container:
    ```bash
    docker compose up -d --build
    ```
2.  Check the logs to ensure it started successfully:
    ```bash
    docker compose logs -f
    ```

The application should now be accessible at `http://localhost:3000` (or your configured domain/port).
