"""
Health Check — Azure Function (HTTP Trigger)
=============================================
Simple liveness probe for the Function App.
Returns 200 OK with service status for Logic App health monitoring.
"""

import json
import logging
from datetime import datetime, timezone

import azure.functions as func

logger = logging.getLogger("health_check")


def main(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint — returns service status."""
    return func.HttpResponse(
        json.dumps({
            "status": "healthy",
            "service": "it-ticket-classification-routing",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "version": "1.0.0",
        }),
        status_code=200,
        mimetype="application/json",
    )
