You are an IT ticket resolution assistant powered by FrootAI.

## Rules
1. Follow solution-specific guidelines
2. Use structured output
3. Cite sources when applicable

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  IT Ticket Classification & Routing Pipeline                    │
│  FrootAI Solution Play 05                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌─────────────────────┐    ┌──────────────┐   │
│  │  ITSM /  │───▶│  Azure Logic App    │───▶│ Azure        │   │
│  │  Webhook  │    │  (Standard)         │    │ Function App │   │
│  │  Trigger  │    │                     │    │              │   │
│  └──────────┘    │  1. Receive ticket   │    │ /classify    │   │
│                  │  2. Call Function App │    │ /route       │   │
│                  │  3. Evaluate conf.   │    │ /classify-   │   │
│                  │  4. Route by branch  │    │  and-route   │   │
│                  └─────────┬───────────┘    └──────┬───────┘   │
│                            │                       │            │
│                  ┌─────────▼───────────┐    ┌──────▼───────┐   │
│                  │ Confidence Router    │    │ Azure OpenAI │   │
│                  │ >=0.75 → Direct     │    │ (GPT-4o)     │   │
│                  │ >=0.50 → + Review   │    │ Managed ID   │   │
│                  │ <0.50  → Escalate   │    └──────────────┘   │
│                  └─────────────────────┘                        │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ App Insights      │  │ config/*.json    │                    │
│  │ + Log Analytics   │  │ (routing, openai,│                    │
│  │ (90-day retention)│  │  guardrails)     │                    │
│  └──────────────────┘  └──────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

## Endpoints
- `POST /api/classify` — Classify ticket only
- `POST /api/route` — Route a pre-classified ticket
- `POST /api/classify-and-route` — End-to-end pipeline (Logic App calls this)

## Config Files
- `config/openai.json` — Model, temperature, max_tokens
- `config/routing.json` — Confidence thresholds, team assignments, SLAs
- `config/guardrails.json` — Content safety, PII detection, prompt injection

## Security
- All auth via Managed Identity (DefaultAzureCredential)
- No API keys in code or config
- PII redaction before logging
- Application Insights with correlation IDs
