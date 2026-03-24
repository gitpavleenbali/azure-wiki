"""
IT Ticket Classification & Routing Pipeline — Azure Function (HTTP Trigger)
============================================================================
End-to-end pipeline: receives raw ticket text, classifies via Azure OpenAI,
then routes based on confidence threshold from config/routing.json.

This is the primary endpoint called by the Logic App workflow.

Uses Managed Identity (DefaultAzureCredential) — no API keys.
Logs all operations to Application Insights with correlation IDs.
"""

import json
import logging
import uuid
from datetime import datetime, timezone

import azure.functions as func

from ..classify_ticket import classify_ticket
from ..classify_ticket.routing import route_ticket, get_routing_summary

# ─── Logging ────────────────────────────────────────────────────────
logger = logging.getLogger("classify_and_route")
logger.setLevel(logging.INFO)


def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger: classify + route in a single call.

    Input:
    {
        "ticket_text": "My VPN keeps disconnecting...",
        "ticket_id": "TKT-12345",         // optional
        "requester_email": "user@co.com",  // optional
        "include_summary": true            // optional
    }

    Output:
    {
        "ticket_id": "TKT-12345",
        "classification": { ... },
        "routing": { ... },
        "pipeline": {
            "correlation_id": "...",
            "classify_ms": 1234,
            "route_ms": 5,
            "total_ms": 1239,
            "timestamp": "2026-03-23T..."
        }
    }
    """
    correlation_id = req.headers.get("x-correlation-id", str(uuid.uuid4()))
    pipeline_start = datetime.now(timezone.utc)

    logger.info("Pipeline started | correlation_id=%s", correlation_id)

    # ── Parse request body ──────────────────────────────────────────
    try:
        body = req.get_json()
    except ValueError:
        return _error_response("Request body must be valid JSON.", 400, correlation_id)

    ticket_text = body.get("ticket_text", "").strip()
    if not ticket_text:
        return _error_response("Field 'ticket_text' is required.", 400, correlation_id)

    ticket_id = body.get("ticket_id", f"AUTO-{correlation_id[:8]}")
    include_summary = body.get("include_summary", False)

    # ── Step 1: Classify ────────────────────────────────────────────
    classify_start = datetime.now(timezone.utc)
    try:
        classification = classify_ticket(ticket_text, correlation_id)
    except ValueError as exc:
        return _error_response(str(exc), 400, correlation_id)
    except RuntimeError as exc:
        return _error_response(str(exc), 503, correlation_id)
    except Exception:
        logger.exception("Classification failed | correlation_id=%s", correlation_id)
        return _error_response("Classification service error.", 500, correlation_id)

    classify_ms = _elapsed_ms(classify_start)

    # ── Step 2: Route ───────────────────────────────────────────────
    route_start = datetime.now(timezone.utc)
    try:
        routing_result = route_ticket(classification, correlation_id)
    except FileNotFoundError:
        logger.error("Routing config missing | correlation_id=%s", correlation_id)
        return _error_response("Routing service misconfigured.", 500, correlation_id)
    except Exception:
        logger.exception("Routing failed | correlation_id=%s", correlation_id)
        return _error_response("Routing service error.", 500, correlation_id)

    route_ms = _elapsed_ms(route_start)
    total_ms = _elapsed_ms(pipeline_start)

    # ── Build response ──────────────────────────────────────────────
    response = {
        "ticket_id": ticket_id,
        "classification": {
            "category": classification.get("category"),
            "subcategory": classification.get("subcategory"),
            "priority": classification.get("priority"),
            "confidence": classification.get("confidence"),
            "routing_team": classification.get("routing_team"),
            "suggested_actions": classification.get("suggested_actions", []),
            "summary": classification.get("summary"),
        },
        "routing": routing_result["routing"],
        "pipeline": {
            "correlation_id": correlation_id,
            "classify_ms": classify_ms,
            "route_ms": route_ms,
            "total_ms": total_ms,
            "timestamp": pipeline_start.isoformat(),
        },
    }

    if include_summary:
        response["summary_text"] = get_routing_summary(routing_result)

    logger.info(
        "Pipeline complete | correlation_id=%s | ticket_id=%s | category=%s | "
        "confidence=%.2f | team=%s | escalated=%s | total_ms=%d",
        correlation_id,
        ticket_id,
        classification.get("category"),
        classification.get("confidence", 0.0),
        routing_result["routing"]["routed_to"]["team"],
        routing_result["routing"]["escalated"],
        total_ms,
    )

    return func.HttpResponse(
        json.dumps(response, indent=2),
        status_code=200,
        mimetype="application/json",
    )


def _error_response(
    message: str, status_code: int, correlation_id: str
) -> func.HttpResponse:
    """Build a standardised error response — never expose internal details."""
    return func.HttpResponse(
        json.dumps({
            "error": message,
            "correlation_id": correlation_id,
        }),
        status_code=status_code,
        mimetype="application/json",
    )


def _elapsed_ms(start: datetime) -> int:
    """Calculate elapsed milliseconds since start."""
    delta = datetime.now(timezone.utc) - start
    return int(delta.total_seconds() * 1000)
