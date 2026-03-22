# Adobe Summit L320 — Modern Commerce Without Risk: Hands-On with Adobe Commerce Cloud Service

This lab walks you through building Adobe Commerce as a Cloud Service extensions using AI-assisted development tools. The use case covers an App Builder extension (backend) and a storefront integration (frontend) using Cursor as the AI-assisted development tool.

## Prerequisites

All lab machines are pre-configured with the required tools and dependencies. The following are pre-installed:

- **Node.js 22**, **npm 9+**, and **Git**
- **Adobe I/O CLI** with Commerce, Runtime, and App Builder plugins
- **Cursor** — Pre-configured with credentials and MCP tools for AI-assisted development.

## Provided resources

Each participant is assigned a **seat number** (01–99). Use it to identify your resources:

| Resource | Naming convention | Example (seat 07) |
|----------|-------------------|--------------------|
| Dev Console project | `L320 XX` | `L320 07` |
| ACCS instance | `L320 XX` | `L320 07` |
| Adobe I/O email | `L320-XX@adobeeventlab.com` | `L320-07@adobeeventlab.com` |

The password will be provided during the lab.

## Getting started

### 1. Log in to Adobe I/O

```bash
aio auth login --force
```

Follow the browser prompts: enter your assigned email and lab password, skip optional mobile/email recovery prompts, and select the **Adobe Commerce Labs** profile. Then open the [Adobe Developer Console](https://developer.adobe.com/console/1899289/home) to verify login and accept terms and conditions if prompted.

### 2. Follow the workbook

Open the workbook and follow the steps from **Step 2** onward (the login step above covers Step 1).

| Use case | Workbook |
|----------|----------|
| Product Reviews & Q&A | [Product Reviews](WORKBOOK.md) |

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| `aio auth login` does not open a browser | Ensure you have a default browser configured. Copy the URL from the terminal output and open it manually. |
| Developer Console shows no projects | Verify you selected the **Adobe Commerce Labs** profile during login. Run `aio auth login --force` to re-authenticate. |
| `app-setup` fails with authentication errors | Run `aio auth login --force` before retrying. |
