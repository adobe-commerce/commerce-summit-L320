# Product Reviews Extension — Adobe Summit L320 Lab Workbook

This workbook guides you through building an extension that allows customers to submit and view product review and question and answer (Q&A) content for storefronts with an Adobe Commerce as a Cloud Service backend using Adobe App Builder and AI-assisted development tools. The extension integrates with an external Product Ratings, Reviews & Q&A API and exposes REST endpoints that the storefront calls to display review and Q&A content on the product detail page (PDP).

You build two parts:

- **App Builder extension** — A middleware layer that connects to the external Product Ratings, Reviews & Q&A API and exposes public REST endpoints for the storefront.
- **Storefront integration** — A product review block on the PDP that displays reviews and Q&A, with forms for shoppers to submit reviews, questions, and answers.

> **Note:** AI agents are non-deterministic. The prompts, questions, and outputs in this workbook are examples. Your agent may produce different questions, requirements, or architecture proposals. Use the examples to steer the agent toward a similar outcome.

## Interactive Workbook

This workbook is also available as an [interactive workbook](https://adobe-summit-l320-workbook.pages.dev/). The interactive version contains the same content in a step-by-step format that is easy to follow along with the presenters. We recommend using the interactive workbook during the lab.

---

## Provided artifacts

Each participant is assigned a **seat number** (01–99). Use your seat number to identify the Dev Console project and ACCS instance that belong to you:

| Resource | Naming convention | Example (seat 07) |
|----------|-------------------|--------------------|
| Dev Console project | `L320 XX` | `L320 07` |
| ACCS instance | `L320 XX` | `L320 07` |
| Adobe I/O email | `L320-XX@adobeeventlab.com` | `L320-07@adobeeventlab.com` |

The following artifacts are provided to you for this lab. You do not need to create them yourself.

| Artifact | Description |
|----------|-------------|
| **Adobe Developer Console project** | A pre-configured App Builder project (`L320 XX`) with the required APIs and Runtime enabled. |
| **Adobe Commerce as a Cloud Service instance** | A sandbox instance (`L320 XX`) with product data and shopper accounts. |
| **Storefront content space** | A pre-configured da.live content space connected to your Commerce instance. |
| **`PRODUCT_REVIEWS_API_CONTRACT.md`** | The API contract for the external Product Ratings, Reviews & Q&A service, including endpoint definitions, request/response shapes, authentication, and error reference. |
| **Cursor** | A pre-configured Cursor IDE with all required tools, extensions, and credentials for AI-assisted development. |

---

## Setup

All lab machines are pre-configured with the required tools and dependencies. No manual setup is necessary.

### Step 1: Log in to Adobe I/O

Log in to Adobe I/O using the CLI:

```bash
aio auth login --force
```

This opens a browser window for authentication. Complete the following steps:

1. Enter your assigned email (`L320-XX@adobeeventlab.com`) and the password provided during the lab.
2. If prompted to add a mobile number or a backup email for password recovery, click **Not now** to skip.
3. You are presented with two profiles — select **Adobe Commerce Labs** to proceed.

Once the CLI confirms a successful login, open the [Adobe Developer Console](https://developer.adobe.com/console/1899289/home/terms) in your browser. If you have not yet accepted the terms and conditions, a modal appears — review and accept to continue. If you have already accepted, the console loads the home page directly. If the console does not recognize your session, run `aio auth login --force` again.

### Step 2: Set up the Integration Starter Kit

The `aio commerce extensibility app-setup` command handles the entire project setup in one step. It prompts you to select a starter kit, project directory name, and coding agent, lets you select your organization, project, and workspace, then clones the starter kit, connects the local workspace to the Dev Console workspace, configures `.env` with the necessary fields, subscribes to required services, installs AI coding tools, and runs `npm install`.

```bash
aio commerce extensibility app-setup
```

When prompted:

1. **Select the starter kit** — Choose **Integration Starter Kit**.
2. **Enter a folder name** — Use `extension`.
3. **Select your coding agent** — Choose **Cursor**.
4. **Select your organization, project, and workspace** — Choose the Dev Console project that matches your seat number. For example, if your seat number is **07**, select the project named **L320 07**.

After the command completes, open the `extension` project in Cursor.

### Step 3: Copy the API contract into your project

Copy the provided `PRODUCT_REVIEWS_API_CONTRACT.md` file into your extension project so the agent can reference it:

```bash
cp PRODUCT_REVIEWS_API_CONTRACT.md extension/docs/PRODUCT_REVIEWS_API_CONTRACT.md
```

### Step 4: Verify the API is reachable

Refer to `PRODUCT_REVIEWS_API_CONTRACT.md` for the full API contract, authentication details, and example requests. Run a quick test to confirm connectivity:

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

You should receive a JSON response with `"success": true` and a list of reviews for SKU `ADB153`. If you get a 401 or 403, check that the `Authorization` header matches the key in `PRODUCT_REVIEWS_API_CONTRACT.md`.

---

## Extension development

This section guides you through developing an extension to submit and view product review and Q&A content for storefronts with an Adobe Commerce as a Cloud Service backend using AI-assisted development tools. The extension integrates with the external API defined in `PRODUCT_REVIEWS_API_CONTRACT.md` and exposes public REST endpoints that the storefront can call.

### Step 1: Provide the initial prompt

Verify that the MCP tools are available in Cursor. Check that the `commerce-extensibility` server is listed and shows a `connected` status.

Give the agent the API contract for context and prompt it to begin. Telling the agent to stop and ask questions helps you steer the implementation early.

Before entering the prompt, switch Cursor to **plan mode**. In plan mode, the agent creates an implementation plan and waits for your approval before making any changes, giving you more control over the process.

Enter the following prompt in Cursor:

```text
I want to build an Adobe Commerce as a Cloud Service extension that acts as a
middleware for product reviews, ratings, and questions/answers.

Analyze @docs/PRODUCT_REVIEWS_API_CONTRACT.md for the complete API contract of
the external service. Build an App Builder extension that:

1. Proxies requests from an Edge Delivery Services storefront to this external API
2. Handles authentication to the external API using the Bearer token stored in the
   .env file so the storefront does not need to authenticate directly
3. Exposes public (unauthenticated) web actions that the storefront can call directly

The storefront should never need to know about or handle the external API authentication.

STOP and ask me any clarifying questions you have about the requirements before
you do any work.
```

> **Tip:** Referencing the API contract file (`@docs/PRODUCT_REVIEWS_API_CONTRACT.md`) in the prompt gives the agent concrete context about the external API — endpoints, auth, required fields, response shapes, and error codes. Telling the agent to STOP and ask questions before proceeding helps you steer the implementation early in the process.

### Step 2: Answer the agent's questions

The agent returns with a series of questions it needs to answer before it can start forming a solution. The following example shows typical questions and answers. Your agent may ask different questions, but the topics are generally the same.

**Example agent questions:**

1. **REST API — host and consumers** — Should the REST API be part of this App Builder app (web actions on Adobe I/O Runtime) that storefronts call? Who calls it (EDS Storefront, custom/headless storefront, or both)? Do you need CORS or public (unauthenticated) access?
1. **Endpoint coverage** — Should the extension expose all endpoints from the contract (reviews, ratings, Q&A, product-ugc summary), or only a subset?
1. **Authentication storage** — Should the API key for the external service be stored in the `.env` file as an action parameter?
1. **Endpoint mapping** — Should the extension expose the same URL paths as the external API, or use different paths?

**Example answers:**

```text
1. The REST API should be part of this App Builder app. It will be called by the
   EDS Storefront. No authentication — public access for both GET and POST.
2. Expose all endpoints from the contract: reviews (GET/POST), ratings (GET/POST),
   questions (GET/POST), answers (POST), and the product-ugc summary.
3. Yes, store the API key in the .env file as an action parameter. The extension
   handles auth so the storefront doesn't need to.
4. Use the same path structure as the external API for consistency.
```

> **Note:** Your agent may ask different questions. Use these answers as guidance for steering the agent toward the same functional outcome: a public REST API that proxies to the external service with server-side authentication.

### Step 3: Review requirements and architecture

The agent generates requirements and architecture documents for you to review. Verify that the requirements match the answers you provided and that the architecture covers:

- Web actions that proxy to the external API endpoints defined in `PRODUCT_REVIEWS_API_CONTRACT.md`
- Server-side authentication using the Bearer token from the API contract
- Public (unauthenticated) endpoints for the storefront to call
- Proper error handling and response forwarding

> **Note:** AI agents are non-deterministic and their behaviors differ depending on the model and coding agent. You may get a different set of questions that produce a different set of requirements and architecture. If so, try to steer the agent in the direction such that the implementation closely matches what is presented in this workbook before proceeding.

### Step 4: Select an implementation plan

The agent gives you the option to create a detailed implementation plan or to complete a direct implementation.

- If you want a reviewable plan that you can execute in phases with more control, select the first option.
- If you want the agent to do the full implementation with minimal intervention, select the second option.

### Step 5: Deploy the extension

After the agent completes the implementation, deploy the extension:

```bash
aio app deploy
```

If the agent added `require-adobe-auth: true` to the actions, ask it to remove authentication so that the endpoints can be called directly from the storefront:

```text
Remove the requirement to provide a valid Adobe IMS access token from all
product-reviews actions.
```

Then redeploy:

```bash
aio app deploy
```

### Step 6: Test the extension

Use curl to test your deployed extension endpoints. Replace `<your-runtime-url>` with your actual App Builder runtime URL (for example, `https://1172492-prodreviewqa135-stage.adobeioruntime.net`).

The external API already has sample review and Q&A content for SKU `ADB153`. Refer to `PRODUCT_REVIEWS_API_CONTRACT.md` for the complete endpoint specification.

**Fetch reviews:**

```bash
API_URL="https://<your-runtime-url>/api/v1/web/product-reviews"

curl -s "$API_URL/reviews-get?sku=ADB153"
```

**Submit a review:**

```bash
curl -s -X POST "$API_URL/reviews-post" \
  -H "Content-Type: application/json" \
  -d '{"sku":"ADB153","rating":5,"review":"Great product, highly recommend!","user":"shopper@example.com"}'
```

**Submit a question:**

```bash
curl -s -X POST "$API_URL/qa-post" \
  -H "Content-Type: application/json" \
  -d '{"sku":"ADB153","type":"question","content":"Is this dishwasher safe?","user":"test@example.com"}'
```

**Submit an answer** (use the `id` from the question response as `questionId`):

```bash
curl -s -X POST "$API_URL/qa-post" \
  -H "Content-Type: application/json" \
  -d '{"sku":"ADB153","type":"answer","questionId":"<QUESTION-UUID>","content":"Yes, it is.","user":"support@example.com"}'
```

**Verify data with GET requests:**

```bash
curl -s "$API_URL/reviews-get?sku=ADB153"
curl -s "$API_URL/qa-get?sku=ADB153"
```

> **Tip:** Use SKU `ADB153` for a product that has both review and Q&A content, and `ADB152` for a product with no reviews. This data configuration enables testing both populated and empty states in the storefront.

### Step 7: Create the storefront API contract

Create an API contract that describes the public endpoints exposed by your App Builder extension. The storefront will use this contract to integrate with the extension.

Ask the agent to generate this contract:

```text
Generate an API contract document for the public web actions exposed by this
extension. This contract will be used by the Edge Delivery Services storefront
to integrate with the extension.

The contract should document:
- Base URL pattern (the App Builder runtime URL)
- All public endpoints (paths, methods, request/response shapes)
- No authentication requirements (the endpoints are public)
- Example curl commands for each endpoint
- Error response shapes

Save the contract as docs/STOREFRONT_API_CONTRACT.md
```

Review the generated contract to verify it accurately reflects the deployed extension endpoints you tested in Step 6. The contract should describe endpoints like `/reviews-get`, `/reviews-post`, `/qa-get`, `/qa-post`, and any others your extension exposes — not the external API endpoints.

> **Tip:** This separation of contracts mirrors a real-world architecture: the extension's internal integration with the external API is an implementation detail. The storefront only needs to know about the public interface the extension provides.

---

## Connect to the storefront

This section guides you through implementing the storefront portion of the product reviews and Q&A extension using Edge Delivery Services and AI-assisted development tools. You add a product review block to the PDP that displays both review and Q&A content, and allows shoppers to submit new content.

> **Note:** The prompts provided are starting points. Although you can use them without modification, consider having a natural conversation with the agent. When working with AI-assisted development tools, there are always natural variations in the code and responses generated by the agent. If you encounter any issues with your code, ask the agent to help you debug it.

### Storefront setup

Set up the storefront project using `app-setup`:

```bash
aio commerce extensibility app-setup
```

When prompted:

1. **Select the starter kit** — Choose **Storefront (AEM Boilerplate Commerce)**.
2. **Enter a folder name** — Use `storefront`.
3. **Select your coding agent** — Choose **Cursor**.
4. **Select your organization, project, and workspace** — Use the same seat-number project as the extension.

After the command completes, copy the storefront API contract from the extension project into your storefront project:

```bash
cp extension/docs/STOREFRONT_API_CONTRACT.md storefront/docs/STOREFRONT_API_CONTRACT.md
```

Open the `storefront` project in Cursor.

### Step 1: Validate the environment

Open your `config.json` file and verify that the values for `commerce-core-endpoint` and `commerce-endpoint` point to your Adobe Commerce as a Cloud Service GraphQL endpoint (provided to you for this lab).

```json
{
  "commerce-core-endpoint": "https://na1-sandbox.api.commerce.adobe.com/<your-instance-id>/graphql",
  "commerce-endpoint": "https://na1-sandbox.api.commerce.adobe.com/<your-instance-id>/graphql"
}
```

### Step 2: Provide the initial prompt

With the storefront API contract already in your project, prompt the agent to implement the product review feature. Before entering the prompt, switch Cursor to **plan mode**. The prompt also includes instructions to use the project manager skill, which triggers a phased planning workflow before implementation.

```text
Analyze @docs/STOREFRONT_API_CONTRACT.md and update the product details block
using the API specified in the contract to render a new section with data from that API. The new data should render both reviews and Q&A
content at the bottom of the product detail page, with forms for shoppers to submit reviews,
questions, and answers. Use the project manager skill to plan this implementation. DO NOT create a new content block for this feature, this implementation should be an update to the existing product details block.
```

> **Tip:** Specifically requesting to use the project manager skill triggers the phased workflow that helps you steer the implementation. This ensures key assumptions and missing requirements are identified early in the process.

### Step 3: Answer clarifying questions

The agent returns with a series of questions it needs to answer before it can start forming a solution. The following example shows typical questions and answers. Your agent may ask different questions, but the topics are generally the same.

**Example agent questions:**

1. **API base URL** — How should the storefront get the product-reviews API base URL? Options may include a config block (for example, a table with `apiBaseUrl`), global placeholders, or another approach.
1. **SKU source** — Should the block read the SKU from the PDP context (current product) or from block configuration?
1. **Form behavior** — After a successful submission, should the form hide, show a success message, or remain visible but disabled?

**Example answers:**

```text
1. Block table config with apiBaseUrl (required). Each block instance can point
   to its own deployment.
2. From block table if set; otherwise use getProductSku() so it works on PDP
   without authoring a SKU.
3. Show a success message above the form; keep the form visible but disabled.
```

> **Note:** Replace the placeholder in the block config with your actual App Builder runtime URL (for example, `https://1172492-prodreviewqa135-stage.adobeioruntime.net`).
>
> Your agent may ask different questions. Use these answers as guidance:
>
> - The API base URL should come from the block table so it can be changed without code modifications.
> - SKU from block table if set; otherwise from the current product on the PDP.
> - After a successful submission, show a success message and disable the form.

### Step 4: Review requirements and architecture

The agent updates the requirements document for you to review. Verify that:

- The block renders reviews (with rating, user, date, text) and Q&A (questions with nested answers).
- Forms exist for submitting reviews, questions, and answers.
- Pagination is supported for both review and Q&A content.
- The API integration uses the base URL from the block table.
- Success and error states are handled according to the contract in `STOREFRONT_API_CONTRACT.md`.

> **Note:** AI agents are non-deterministic and their behaviors differ depending on the model and coding agent. You may get a different set of questions that produce a different set of requirements and architecture. If so, try to steer the agent in the direction such that the implementation closely matches what is presented in this workbook before proceeding.

### Step 5: Select an implementation plan

The agent gives you the option to create a detailed implementation plan, or to complete a direct implementation.

- If you want a reviewable plan that you can execute in phases with more control, select the first option.
- If you want the agent to do the full implementation with minimal intervention, select the second option.

During implementation, the agent creates and modifies block files. Watch the code being generated and ask questions or redirect the agent as needed. If the block does not render, ask the agent to analyze the section decoration and block discovery pattern — the block element must be a direct child of the section so the framework can find it.

### Step 6: Add the block to the product page in Document Authoring

Add the product review block to the product page template so it appears on all PDPs. Use the Document Authoring service (da.live) to add and configure the block.

1. Open your document authoring service, for example [da.live](https://da.live/).

1. Click on your project space, open the **products** folder and select **default** (`products/default`).

1. Add a new block section.

   In the block table, add a row with the block name **product-review** (or the block name your agent created).

1. Configure the block with the required settings:
   - **apiBaseUrl** — Your App Builder runtime URL (for example, `https://<namespace>-<app-name>-stage.adobeioruntime.net`).
   - **sku** — Leave empty to use the current product's SKU on the PDP, or enter a specific SKU to display reviews for that product only.

1. Click **Publish** to publish your changes.

### Step 7: Start the server and test

After you add the block to the product page in Document Authoring, start the development server and test the block.

1. Start the local development server:

   ```bash
   npm run start
   ```

1. In a browser, navigate to a product page that has pre-populated review and Q&A content. For example:

   ```
   http://localhost:3000/products/<product-slug>/ADB153
   ```

1. Verify that the product review block displays reviews and Q&A content, and that the submission forms work.

You can do manual testing or ask the agent to use its browser capabilities to test for you:

```text
Run complete browser testing. Use the following product page
'http://localhost:3000/products/<product-slug>/ADB153'
```

### Step 8: Clean up

After you skip or complete testing, the agent prompts you to proceed to the final **Cleanup** phase. Upon confirmation, the agent archives all documentation artifacts created during implementation.

---

## Troubleshooting

Use the following tips if you encounter issues during the lab.

### Backend (App Builder)

| Symptom | Cause | Fix |
|---------|-------|-----|
| GET or POST returns 401 from the external API | The `Authorization` header is missing from requests your extension sends to the external API. | Verify that the Bearer token from `PRODUCT_REVIEWS_API_CONTRACT.md` is stored in your `.env` file and passed as an action parameter. Check that your action code includes the `Authorization` header when calling the external API. |
| GET or POST returns 403 from the external API | The API key is incorrect. | Verify the API key in your `.env` file matches the value in `PRODUCT_REVIEWS_API_CONTRACT.md`. |
| GET or POST returns 400 from the external API | Invalid request parameters or missing required fields. | Refer to `PRODUCT_REVIEWS_API_CONTRACT.md` for the correct request format and required fields for each endpoint. |
| GET or POST returns 500 "Cannot find module" | The product-reviews actions use `require("../../utils")` or similar paths that escape the package bundle. Those files are not included when the package is deployed. | Make the product-reviews package self-contained. Add shared code inside the package directory (for example, `actions/product-reviews/lib/`) and update all actions to require from `../lib/...` instead of `../../`. |
| Deploy fails with missing `.env` | The `.env` file was not created or is missing required variables. | Re-run `aio commerce extensibility app-setup` if the file is missing. Add the external API key manually after setup if needed. |

### Storefront (Edge Delivery Services)

| Symptom | Cause | Fix |
|---------|-------|-----|
| Block does not render on test page | The block element is nested inside an extra `div`, so after `decorateSections` the block selector (`div.section > div > div`) does not match. | Make the block a direct child of the section. Structure: `section > div.product-review` (or equivalent block class). Avoid `section > div > div.product-review`. |
| Invalid CSS tokens | The block uses design tokens that do not exist in `styles/styles.css` (for example, `--color-error-100`, `--type-detail-font-size`). | Ask the agent to validate tokens against the project's `styles/styles.css` and replace invalid tokens with existing ones (for example, `--color-alert-*`, `--type-details-caption-*`). |

---

## Recap

Here is a summary of the topics covered in this lab:

- **Extension development:** Describing functionality to submit and view product review and Q&A content on a storefront with an Adobe Commerce as a Cloud Service backend to an AI agent and generating a working App Builder extension that integrates with an external API.
- **API integration:** Using an external API contract (`PRODUCT_REVIEWS_API_CONTRACT.md`) to guide AI-assisted implementation with server-side authentication.
- **Testing:** Verifying extension endpoints with curl commands and validating data flow between the storefront, extension, and external API.
- **Service contracts:** Using API contracts to bridge backend extensions and storefront implementations.
- **Phased storefront integration:** Working through requirements, architecture, and implementation using AI-assisted skills.
- **PDP block:** Adding a product review block to the PDP that displays reviews and Q&A with submission forms and pagination.

---

## Next steps

Use the following suggestions to extend your product reviews service:

- **Add moderation:** Implement a moderation workflow for review and Q&A content before it is published.
- **Add authentication:** Require shoppers to be logged in to submit reviews or Q&A content, and associate submissions with customer accounts.
- **Add a subscription management page:** Create a storefront page where shoppers can view and edit their reviews.
- **Support multi-tenant deployments:** Extend the integration to support multiple Commerce tenants in a single App Builder app.
- **Add rate limiting:** Implement rate limits on the API to prevent abuse.
