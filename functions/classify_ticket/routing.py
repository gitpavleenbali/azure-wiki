"""
IT Ticket Routing Engine
========================
Confidence-based routing for classified IT tickets.
Routes to appropriate teams based on classification category and confidence score.

Uses config/routing.json for all routing parameters — never hardcoded.
Implements Application Insights logging with correlation IDs.
Authentication: Managed Identity (DefaultAzureCredential).
"""

import json
import logging
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# ─── Logging ────────────────────────────────────────────────────────
logger = logging.getLogger("ticket_router")
logger.setLevel(logging.INFO)


def _load_routing_config() -> dict:
    """
    Load routing configuration from config/routing.json.

    Searches relative to this file's parent directories to locate the config
    folder, supporting both local dev and deployed environments.

    Returns:
        dict: Parsed routing configuration.

    Raises:
        FileNotFoundError: If routing.json cannot be located.
    """
    # Walk up from this file to find config/routing.json
    search_dir = Path(__file__).resolve().parent
    for _ in range(5):
        config_path = search_dir / "config" / "routing.json"
        if config_path.exists():
            with open(config_path, "r", encoding="utf-8") as f:
                return json.load(f)
        search_dir = search_dir.parent

    # Fallback: environment variable for deployed path
    env_path = os.environ.get("ROUTING_CONFIG_PATH")
    if env_path and Path(env_path).exists():
        with open(env_path, "r", encoding="utf-8") as f:
            return json.load(f)

    raise FileNotFoundError(
        "Cannot locate config/routing.json. "
        "Set ROUTING_CONFIG_PATH environment variable for deployed environments."
    )


# ─── Module-level config (loaded once via function attribute) ───


def _get_config() -> dict[str, Any]:
    """Get cached routing config (lazy singleton via function attribute)."""
    cached: dict[str, Any] | None = getattr(_get_config, "cached_data", None)
    if cached is None:
        cached = _load_routing_config()
        _get_config.cached_data = cached  # type: ignore[attr-defined]
    return cached


def route_ticket(classification: dict, correlation_id: str) -> dict:
    """
    Route a classified ticket to the appropriate team based on confidence.

    Routing logic:
    1. If confidence >= confidence_threshold → route to category team
    2. If confidence >= escalation_threshold but < confidence_threshold → route to
       category team with escalation flag
    3. If confidence < escalation_threshold → route to triage/escalation team

    Args:
        classification: Classification result from classify_ticket().
            Required keys: category, subcategory, priority, confidence,
            routing_team, suggested_actions, summary.
        correlation_id: Unique ID for distributed tracing.

    Returns:
        dict with routing decision including:
            - routed_to: Team assignment details
            - routing_reason: Why this routing was chosen
            - sla_hours: SLA based on priority
            - requires_review: Whether manual review is needed
            - escalated: Whether ticket was escalated due to low confidence
            - timestamp: ISO 8601 routing timestamp
            - correlation_id: Tracing ID
    """
    config = _get_config()
    confidence_threshold = config["confidence_threshold"]
    escalation_threshold = config["escalation_threshold"]
    routing_teams = config["routing_teams"]
    escalation_team = config["escalation_team"]

    category = classification.get("category", "Other")
    confidence = classification.get("confidence", 0.0)
    priority = classification.get("priority", "P4-Low")

    # ── Determine routing target ────────────────────────────────────
    if confidence >= confidence_threshold:
        # High confidence — route directly to category team
        team_config = routing_teams.get(category, routing_teams["Other"])
        routing_reason = (
            f"High confidence ({confidence:.2f} >= {confidence_threshold}) "
            f"— routed directly to {team_config['team']}"
        )
        requires_review = False
        escalated = False

    elif confidence >= escalation_threshold:
        # Medium confidence — route to category team but flag for review
        team_config = routing_teams.get(category, routing_teams["Other"])
        routing_reason = (
            f"Medium confidence ({confidence:.2f}) between "
            f"{escalation_threshold} and {confidence_threshold} "
            f"— routed to {team_config['team']} with review flag"
        )
        requires_review = True
        escalated = False

    else:
        # Low confidence — escalate to triage team
        team_config = {
            "team": escalation_team["team"],
            "email": escalation_team["email"],
            "teams_channel": escalation_team["teams_channel"],
            "sla_hours": routing_teams["Other"]["sla_hours"],
        }
        routing_reason = (
            f"Low confidence ({confidence:.2f} < {escalation_threshold}) "
            f"— escalated to {escalation_team['team']} for manual triage. "
            f"{escalation_team['reason']}"
        )
        requires_review = True
        escalated = True

    # ── Calculate SLA ───────────────────────────────────────────────
    sla_map = team_config.get("sla_hours", {})
    sla_hours = sla_map.get(priority, 72)  # Default 72h if priority unknown

    # ── Build routing result ────────────────────────────────────────
    routing_result = {
        "correlation_id": correlation_id,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "classification": {
            "category": category,
            "subcategory": classification.get("subcategory", "Unknown"),
            "priority": priority,
            "confidence": confidence,
            "summary": classification.get("summary", ""),
        },
        "routing": {
            "routed_to": {
                "team": team_config["team"],
                "email": team_config["email"],
                "teams_channel": team_config["teams_channel"],
            },
            "routing_reason": routing_reason,
            "sla_hours": sla_hours,
            "requires_review": requires_review,
            "escalated": escalated,
        },
        "suggested_actions": classification.get("suggested_actions", []),
    }

    # ── Log routing decision (Application Insights) ─────────────────
    log_level = logging.WARNING if escalated else logging.INFO
    logger.log(
        log_level,
        "Ticket routed | correlation_id=%s | category=%s | confidence=%.2f | "
        "team=%s | priority=%s | sla_hours=%s | escalated=%s | requires_review=%s",
        correlation_id,
        category,
        confidence,
        team_config["team"],
        priority,
        sla_hours,
        escalated,
        requires_review,
    )

    return routing_result


def get_routing_summary(routing_result: dict) -> str:
    """
    Generate a human-readable summary of the routing decision.

    Args:
        routing_result: Output from route_ticket().

    Returns:
        Formatted string summary for notifications.
    """
    r = routing_result["routing"]
    c = routing_result["classification"]

    lines = [
        "Ticket Routing Summary",
        "─" * 40,
        f"Category:    {c['category']} > {c['subcategory']}",
        f"Priority:    {c['priority']}",
        f"Confidence:  {c['confidence']:.0%}",
        f"Assigned To: {r['routed_to']['team']}",
        f"SLA:         {r['sla_hours']}h",
        f"Review:      {'Yes' if r['requires_review'] else 'No'}",
        f"Escalated:   {'Yes' if r['escalated'] else 'No'}",
        "",
        f"Summary: {c['summary']}",
        f"Reason:  {r['routing_reason']}",
    ]

    if routing_result.get("suggested_actions"):
        lines.append("")
        lines.append("Suggested Actions:")
        for i, action in enumerate(routing_result["suggested_actions"], 1):
            lines.append(f"  {i}. {action}")

    return "\n".join(lines)
