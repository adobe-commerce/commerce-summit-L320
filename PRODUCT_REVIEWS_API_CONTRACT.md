# Product Ratings, Reviews & Q&A — API Contract

**Base URL:** `https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev`

**Interactive OpenAPI Docs:** `https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/`

---

## Table of Contents

- [Authentication](#authentication)
- [Common Response Shapes](#common-response-shapes)
- [Reviews API](#reviews-api)
  - [List Reviews](#list-reviews)
  - [Create Review](#create-review)
  - [Delete Review](#delete-review)
- [Ratings API](#ratings-api)
  - [Get Ratings Summary](#get-ratings-summary)
  - [Create Rating](#create-rating)
  - [Delete Rating](#delete-rating)
- [Questions & Answers API](#questions--answers-api)
  - [List Questions](#list-questions)
  - [Create Question](#create-question)
  - [Delete Question](#delete-question)
  - [Create Answer](#create-answer)
  - [Delete Answer](#delete-answer)
- [Product UGC Summary](#product-ugc-summary)
- [Error Reference](#error-reference)
- [Edge Cases](#edge-cases)

---

## Authentication

**All endpoints** require a static API key passed as a Bearer token. This is a service-to-service (S2S) API — the calling service is responsible for handling unauthenticated storefront flows on its side.

```
Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9
```

Store this key as an environment secret in your integration layer (e.g., Adobe App Builder `.env` or action parameter). Do not expose it in client-side code.

### Auth Error Responses

**Missing header → 401:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Content-Type: application/json" \
  -d '{"rating": 5, "review": "Great!", "user": "test@example.com"}'
```

```json
{
  "success": false,
  "error": "Missing Authorization header"
}
```

**Invalid key → 403:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer wrong-token" \
  -d '{"rating": 5, "review": "Great!", "user": "test@example.com"}'
```

```json
{
  "success": false,
  "error": "Invalid API key"
}
```

---

## Common Response Shapes

### Success

```json
{
  "success": true,
  "result": { ... }
}
```

### Error

```json
{
  "success": false,
  "error": "Human-readable error message"
}
```

### Validation Error

Returned when request body fails Zod schema validation (HTTP 400):

```json
{
  "success": false,
  "result": {},
  "errors": [
    {
      "code": "too_big",
      "maximum": 5,
      "type": "number",
      "inclusive": true,
      "exact": false,
      "message": "Number must be less than or equal to 5",
      "path": ["body", "rating"]
    }
  ]
}
```

---

## Reviews API

A review includes both a numeric rating (1–5) and review text.

### Review Object

| Field       | Type   | Description                          |
| ----------- | ------ | ------------------------------------ |
| `id`        | string | UUID, auto-generated                 |
| `sku`       | string | Product SKU                          |
| `rating`    | number | Integer 1–5                          |
| `review`    | string | Review text                          |
| `user`      | string | User email                           |
| `createdAt` | string | ISO 8601 timestamp, auto-generated   |

---

### List Reviews

```
GET /api/reviews/:sku
```

**Auth required:** Yes

**curl:**

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200) — with data:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "reviews": [
      {
        "id": "b15a7691-7f69-4f84-9af5-873972bc9898",
        "sku": "ADB153",
        "rating": 5,
        "review": "Great product, highly recommend!",
        "user": "shopper@example.com",
        "createdAt": "2026-03-16T23:46:22.258Z"
      },
      {
        "id": "cad1aae3-e3d6-4737-94d1-ff4576fdd654",
        "sku": "ADB153",
        "rating": 4,
        "review": "Good value for money.",
        "user": "buyer@example.com",
        "createdAt": "2026-03-16T23:46:22.733Z"
      }
    ],
    "count": 2
  }
}
```

**Response (200) — empty state (no reviews yet):**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "reviews": [],
    "count": 0
  }
}
```

---

### Create Review

```
POST /api/reviews/:sku
```

**Auth required:** Yes

**Request body:**

| Field    | Type   | Required | Constraints        |
| -------- | ------ | -------- | ------------------ |
| `rating` | number | Yes      | Integer, 1–5       |
| `review` | string | Yes      | Non-empty string   |
| `user`   | string | Yes      | Non-empty string   |

**curl:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{
    "rating": 5,
    "review": "Great product, highly recommend!",
    "user": "shopper@example.com"
  }'
```

**Response (201):**

```json
{
  "success": true,
  "result": {
    "review": {
      "id": "b15a7691-7f69-4f84-9af5-873972bc9898",
      "sku": "ADB153",
      "rating": 5,
      "review": "Great product, highly recommend!",
      "user": "shopper@example.com",
      "createdAt": "2026-03-16T23:46:22.258Z"
    }
  }
}
```

---

### Delete Review

```
DELETE /api/reviews/:sku/:reviewId
```

**Auth required:** Yes

**curl:**

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153/b15a7691-7f69-4f84-9af5-873972bc9898 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200):**

```json
{
  "success": true,
  "result": {
    "review": {
      "id": "b15a7691-7f69-4f84-9af5-873972bc9898",
      "sku": "ADB153",
      "rating": 5,
      "review": "Great product, highly recommend!",
      "user": "shopper@example.com",
      "createdAt": "2026-03-16T23:46:22.258Z"
    }
  }
}
```

**Response (404) — review not found:**

```json
{
  "success": false,
  "error": "Review not found"
}
```

---

## Ratings API

A standalone numeric rating (1–5) without review text. Useful when users want to rate without writing a full review.

### Rating Object

| Field       | Type   | Description                          |
| ----------- | ------ | ------------------------------------ |
| `id`        | string | UUID, auto-generated                 |
| `sku`       | string | Product SKU                          |
| `rating`    | number | Integer 1–5                          |
| `user`      | string | User email                           |
| `createdAt` | string | ISO 8601 timestamp, auto-generated   |

---

### Get Ratings Summary

```
GET /api/ratings/:sku
```

**Auth required:** Yes

Returns an aggregate summary (average, count, per-star distribution) plus the list of individual ratings.

**curl:**

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/ratings/ADB153 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200) — with data:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "summary": {
      "averageRating": 4,
      "count": 2,
      "distribution": {
        "1": 0,
        "2": 0,
        "3": 1,
        "4": 0,
        "5": 1
      },
      "ratings": [
        {
          "id": "3c203d00-1990-4bd3-9748-a385ea9c9dd5",
          "sku": "ADB153",
          "rating": 5,
          "user": "fan@example.com",
          "createdAt": "2026-03-16T23:46:23.244Z"
        },
        {
          "id": "bfdc6a88-8b6b-490d-a360-a860e4e0145b",
          "sku": "ADB153",
          "rating": 3,
          "user": "meh@example.com",
          "createdAt": "2026-03-16T23:46:23.757Z"
        }
      ]
    }
  }
}
```

**Response (200) — empty state:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "summary": {
      "averageRating": 0,
      "count": 0,
      "distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 },
      "ratings": []
    }
  }
}
```

---

### Create Rating

```
POST /api/ratings/:sku
```

**Auth required:** Yes

**Request body:**

| Field    | Type   | Required | Constraints        |
| -------- | ------ | -------- | ------------------ |
| `rating` | number | Yes      | Integer, 1–5       |
| `user`   | string | Yes      | Non-empty string   |

**curl:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/ratings/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{
    "rating": 5,
    "user": "fan@example.com"
  }'
```

**Response (201):**

```json
{
  "success": true,
  "result": {
    "rating": {
      "id": "3c203d00-1990-4bd3-9748-a385ea9c9dd5",
      "sku": "ADB153",
      "rating": 5,
      "user": "fan@example.com",
      "createdAt": "2026-03-16T23:46:23.244Z"
    }
  }
}
```

---

### Delete Rating

```
DELETE /api/ratings/:sku/:ratingId
```

**Auth required:** Yes

**curl:**

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/ratings/ADB153/3c203d00-1990-4bd3-9748-a385ea9c9dd5 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200):**

```json
{
  "success": true,
  "result": {
    "rating": {
      "id": "3c203d00-1990-4bd3-9748-a385ea9c9dd5",
      "sku": "ADB153",
      "rating": 5,
      "user": "fan@example.com",
      "createdAt": "2026-03-16T23:46:23.244Z"
    }
  }
}
```

**Response (404) — rating not found:**

```json
{
  "success": false,
  "error": "Rating not found"
}
```

---

## Questions & Answers API

Questions can be asked about a product. Each question can have multiple nested answers.

### Question Object

| Field       | Type     | Description                                    |
| ----------- | -------- | ---------------------------------------------- |
| `id`        | string   | UUID, auto-generated                           |
| `sku`       | string   | Product SKU                                    |
| `content`   | string   | Question text                                  |
| `user`      | string   | User email                                     |
| `createdAt` | string   | ISO 8601 timestamp, auto-generated             |
| `answers`   | Answer[] | Array of answers (empty initially)             |

### Answer Object

| Field       | Type   | Description                          |
| ----------- | ------ | ------------------------------------ |
| `id`        | string | UUID, auto-generated                 |
| `content`   | string | Answer text                          |
| `user`      | string | User email                           |
| `createdAt` | string | ISO 8601 timestamp, auto-generated   |

---

### List Questions

```
GET /api/questions/:sku
```

**Auth required:** Yes

**curl:**

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200) — with data:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "questions": [
      {
        "id": "fc6add6e-e9a1-4ed4-8c18-009123b69bd5",
        "sku": "ADB153",
        "content": "Does this come in other colors?",
        "user": "curious@example.com",
        "createdAt": "2026-03-16T23:46:24.313Z",
        "answers": [
          {
            "id": "26eec95a-d9a3-47e1-bd57-e4b11f7642b0",
            "content": "Yes, it comes in blue and red as well.",
            "user": "seller@example.com",
            "createdAt": "2026-03-16T23:46:32.351Z"
          }
        ]
      }
    ],
    "count": 1
  }
}
```

**Response (200) — empty state:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "questions": [],
    "count": 0
  }
}
```

---

### Create Question

```
POST /api/questions/:sku
```

**Auth required:** Yes

**Request body:**

| Field     | Type   | Required | Constraints        |
| --------- | ------ | -------- | ------------------ |
| `content` | string | Yes      | Non-empty string   |
| `user`    | string | Yes      | Non-empty string   |

**curl:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{
    "content": "Does this come in other colors?",
    "user": "curious@example.com"
  }'
```

**Response (201):**

```json
{
  "success": true,
  "result": {
    "question": {
      "id": "fc6add6e-e9a1-4ed4-8c18-009123b69bd5",
      "sku": "ADB153",
      "content": "Does this come in other colors?",
      "user": "curious@example.com",
      "createdAt": "2026-03-16T23:46:24.313Z",
      "answers": []
    }
  }
}
```

---

### Delete Question

```
DELETE /api/questions/:sku/:questionId
```

**Auth required:** Yes

Deleting a question also removes all its answers.

**curl:**

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153/fc6add6e-e9a1-4ed4-8c18-009123b69bd5 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200):**

```json
{
  "success": true,
  "result": {
    "question": {
      "id": "fc6add6e-e9a1-4ed4-8c18-009123b69bd5",
      "sku": "ADB153",
      "content": "Does this come in other colors?",
      "user": "curious@example.com",
      "createdAt": "2026-03-16T23:46:24.313Z",
      "answers": []
    }
  }
}
```

**Response (404) — question not found:**

```json
{
  "success": false,
  "error": "Question not found"
}
```

---

### Create Answer

```
POST /api/questions/:sku/:questionId/answers
```

**Auth required:** Yes

**Request body:**

| Field     | Type   | Required | Constraints        |
| --------- | ------ | -------- | ------------------ |
| `content` | string | Yes      | Non-empty string   |
| `user`    | string | Yes      | Non-empty string   |

**curl:**

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153/fc6add6e-e9a1-4ed4-8c18-009123b69bd5/answers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{
    "content": "Yes, it comes in blue and red as well.",
    "user": "seller@example.com"
  }'
```

**Response (201):**

```json
{
  "success": true,
  "result": {
    "answer": {
      "id": "26eec95a-d9a3-47e1-bd57-e4b11f7642b0",
      "content": "Yes, it comes in blue and red as well.",
      "user": "seller@example.com",
      "createdAt": "2026-03-16T23:46:32.351Z"
    }
  }
}
```

**Response (404) — parent question not found:**

```json
{
  "success": false,
  "error": "Question not found"
}
```

---

### Delete Answer

```
DELETE /api/questions/:sku/:questionId/answers/:answerId
```

**Auth required:** Yes

**curl:**

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153/fc6add6e-e9a1-4ed4-8c18-009123b69bd5/answers/26eec95a-d9a3-47e1-bd57-e4b11f7642b0 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200):**

```json
{
  "success": true,
  "result": {
    "answer": {
      "id": "26eec95a-d9a3-47e1-bd57-e4b11f7642b0",
      "content": "Yes, it comes in blue and red as well.",
      "user": "seller@example.com",
      "createdAt": "2026-03-16T23:46:32.351Z"
    }
  }
}
```

**Response (404) — question not found:**

```json
{
  "success": false,
  "error": "Question not found"
}
```

**Response (404) — answer not found:**

```json
{
  "success": false,
  "error": "Answer not found"
}
```

---

## Product UGC Summary

A single endpoint that returns all reviews, ratings (with summary), and questions for a SKU. Useful for rendering the full product detail page.

```
GET /api/product-ugc/:sku
```

**Auth required:** Yes

**curl:**

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/product-ugc/ADB153 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

**Response (200) — with data:**

```json
{
  "success": true,
  "result": {
    "sku": "ADB153",
    "reviews": {
      "items": [
        {
          "id": "b15a7691-7f69-4f84-9af5-873972bc9898",
          "sku": "ADB153",
          "rating": 5,
          "review": "Great product, highly recommend!",
          "user": "shopper@example.com",
          "createdAt": "2026-03-16T23:46:22.258Z"
        }
      ],
      "count": 1
    },
    "ratings": {
      "averageRating": 4,
      "count": 2,
      "distribution": {
        "1": 0,
        "2": 0,
        "3": 1,
        "4": 0,
        "5": 1
      },
      "items": [
        {
          "id": "3c203d00-1990-4bd3-9748-a385ea9c9dd5",
          "sku": "ADB153",
          "rating": 5,
          "user": "fan@example.com",
          "createdAt": "2026-03-16T23:46:23.244Z"
        },
        {
          "id": "bfdc6a88-8b6b-490d-a360-a860e4e0145b",
          "sku": "ADB153",
          "rating": 3,
          "user": "meh@example.com",
          "createdAt": "2026-03-16T23:46:23.757Z"
        }
      ]
    },
    "questions": {
      "items": [
        {
          "id": "fc6add6e-e9a1-4ed4-8c18-009123b69bd5",
          "sku": "ADB153",
          "content": "Does this come in other colors?",
          "user": "curious@example.com",
          "createdAt": "2026-03-16T23:46:24.313Z",
          "answers": [
            {
              "id": "26eec95a-d9a3-47e1-bd57-e4b11f7642b0",
              "content": "Yes, it comes in blue and red as well.",
              "user": "seller@example.com",
              "createdAt": "2026-03-16T23:46:32.351Z"
            }
          ]
        }
      ],
      "count": 1
    }
  }
}
```

**Response (200) — empty state (brand new SKU):**

```json
{
  "success": true,
  "result": {
    "sku": "NEWSKU001",
    "reviews": {
      "items": [],
      "count": 0
    },
    "ratings": {
      "averageRating": 0,
      "count": 0,
      "distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 },
      "items": []
    },
    "questions": {
      "items": [],
      "count": 0
    }
  }
}
```

---

## Error Reference

| HTTP Status | Condition                                        | Response Body                                                                 |
| ----------- | ------------------------------------------------ | ----------------------------------------------------------------------------- |
| 200         | Success (GET, DELETE)                             | `{ "success": true, "result": { ... } }`                                      |
| 201         | Created (POST)                                   | `{ "success": true, "result": { ... } }`                                      |
| 400         | Validation error (bad/missing fields)            | `{ "success": false, "result": {}, "errors": [ ... ] }`                       |
| 401         | Missing `Authorization` header on write endpoint | `{ "success": false, "error": "Missing Authorization header" }`               |
| 403         | Invalid API key                                  | `{ "success": false, "error": "Invalid API key" }`                            |
| 404         | Resource not found (delete/answer to missing ID) | `{ "success": false, "error": "<Resource> not found" }`                       |

---

## Edge Cases

### Unknown SKU returns empty collections (not 404)

Any SKU can be queried. If no data has been written for it, the response contains empty arrays — it does not return a 404.

```bash
curl https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/NONEXISTENT-SKU-999 \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

```json
{
  "success": true,
  "result": {
    "sku": "NONEXISTENT-SKU-999",
    "reviews": [],
    "count": 0
  }
}
```

### Rating out of range (1–5 enforced)

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{"rating": 10, "review": "Too high", "user": "test@example.com"}'
```

```json
{
  "success": false,
  "result": {},
  "errors": [
    {
      "code": "too_big",
      "maximum": 5,
      "type": "number",
      "inclusive": true,
      "exact": false,
      "message": "Number must be less than or equal to 5",
      "path": ["body", "rating"]
    }
  ]
}
```

### Rating below minimum

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/ratings/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{"rating": 0, "user": "test@example.com"}'
```

```json
{
  "success": false,
  "result": {},
  "errors": [
    {
      "code": "too_small",
      "minimum": 1,
      "type": "number",
      "inclusive": true,
      "exact": false,
      "message": "Number must be greater than or equal to 1",
      "path": ["body", "rating"]
    }
  ]
}
```

### Missing required fields

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{"rating": 5}'
```

```json
{
  "success": false,
  "result": {},
  "errors": [
    {
      "code": "invalid_type",
      "expected": "string",
      "received": "undefined",
      "path": ["body", "review"],
      "message": "Required"
    },
    {
      "code": "invalid_type",
      "expected": "string",
      "received": "undefined",
      "path": ["body", "user"],
      "message": "Required"
    }
  ]
}
```

### Deleting a non-existent resource

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/reviews/ADB153/does-not-exist \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

```json
{
  "success": false,
  "error": "Review not found"
}
```

### Answering a non-existent question

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153/does-not-exist/answers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{"content": "Some answer", "user": "user@example.com"}'
```

```json
{
  "success": false,
  "error": "Question not found"
}
```

### Deleting an answer from a non-existent question

```bash
curl -X DELETE https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/questions/ADB153/bad-qid/answers/bad-aid \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9"
```

```json
{
  "success": false,
  "error": "Question not found"
}
```

### Non-integer rating

```bash
curl -X POST https://pd-bcn-2026-dummy-apis.apimesh-adobe-test.workers.dev/api/ratings/ADB153 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer pdw-bcn-2026-rr-a8f3e1b9" \
  -d '{"rating": 3.5, "user": "test@example.com"}'
```

```json
{
  "success": false,
  "result": {},
  "errors": [
    {
      "code": "invalid_type",
      "expected": "integer",
      "received": "float",
      "message": "Expected integer, received float",
      "path": ["body", "rating"]
    }
  ]
}
```

### SKU is a free-form path parameter

The SKU can contain any URL-safe characters. Examples: `ADB153`, `SHOE-RED-42`, `electronics/laptop-001`. There is no SKU validation — data is simply keyed by whatever value is passed.
