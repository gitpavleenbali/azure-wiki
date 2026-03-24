"""
IT Ticket Routing — Azure Function (HTTP Trigger)
===================================================
Receives a classified ticket and routes it to the appropriate team
based on confidence thresholds from config/routing.json.

Uses Managed Identity (DefaultAzureCredential) — no API keys.
Logs all routing decisions to Application Insights with correlation IDs.
"""

import json
import logging
import uuid

import azure.functions as func

# Import routing engine (sibling module)
from ..classify_ticket.routing import route_ticket, get_routing_summary

# ─── Logging ────────────────────────────────────────────────────────
logger = logging.getLogger("route_ticket_function")
logger.setLevel(logging.INFO)


def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP trigger for ticket routing.

    Expects POST with JSON body containing a classification result:
    {
        "classification": {
            "category": "Network",
            "subcategory": "VPN",
            "priority": "P2-High",
            "confidence": 0.87,
            "routing_team": "Network Operations",
            "suggested_actions": ["Check VPN gateway", "Reset connection"],
            "summary": "VPN disconnects frequently during peak hours"
        }
    }

    Returns routing decision with team assignment, SLA, and escalation status.
    """
    correlation_id = req.headers.get("x-correlation-id", str(uuid.uuid4()))

    # ── Parse request body ──────────────────────────────────────────
    try:
        body = req.get_json()
    except ValueError:
        logger.warning("Invalid JSON in request | correlation_id=%s", correlation_id)
        return func.HttpResponse(
            json.dumps({
                "error": "Request body must be valid JSON.",
                "correlation_id": correlation_id,
            }),
            status_code=400,
            mimetype="application/json",
        )

    classification = body.get("classification")
    if not classification:
        return func.HttpResponse(
            json.dumps({
                "error": "Field 'classification' is required.",
                "correlation_id": correlation_id,
            }),
            status_code=400,
            mimetype="application/json",
        )

    # ── Validate classification has required fields ─────────────────
    required = ["category", "confidence", "priority"]
    missing = [f for f in required if f not in classification]
    if missing:
        return func.HttpResponse(
            json.dumps({
                "error": f"Classification missing required fields: {missing}",
                "correlation_id": correlation_id,
            }),
            status_code=400,
            mimetype="application/json",
        )

    # ── Route the ticket ────────────────────────────────────────────
    try:
        routing_result = route_ticket(classification, correlation_id)

        # Include human-readable summary if requested
        if body.get("include_summary", False):
            routing_result["summary_text"] = get_routing_summary(routing_result)

        return func.HttpResponse(
            json.dumps(routing_result, indent=2),
            status_code=200,
            mimetype="application/json",
        )

    except FileNotFoundError as exc:
        logger.error(
            "Routing config not found | correlation_id=%s | error=%s",
            correlation_id,
            str(exc),
        )
        return func.HttpResponse(
            json.dumps({
                "error": "Routing service misconfigured.",
                "correlation_id": correlation_id,
            }),
            status_code=500,
            mimetype="application/json",
        )

    except Exception:
        logger.exception("Unexpected routing error | correlation_id=%s", correlation_id)
        return func.HttpResponse(
            json.dumps({
                "error": "Internal server error.",
                "correlation_id": correlation_id,
            }),
            status_code=500,
            mimetype="application/json",
        )
