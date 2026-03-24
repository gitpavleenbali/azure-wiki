"""
Ticket Routing — Unit Tests
============================
Validates routing logic, confidence thresholds, and team assignment.
Uses config/routing.json values — never hardcoded thresholds.
"""

import os
import sys
import unittest

# Add functions directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

# Set required env vars before importing
os.environ.setdefault("AZURE_OPENAI_ENDPOINT", "https://test.openai.azure.com/")
os.environ.setdefault("AZURE_OPENAI_DEPLOYMENT", "gpt-4o")

from classify_ticket.routing import route_ticket, get_routing_summary, _get_config


class TestRoutingConfig(unittest.TestCase):
    """Validate routing configuration is well-formed."""

    def test_config_loads_successfully(self):
        config = _get_config()
        self.assertIn("confidence_threshold", config)
        self.assertIn("escalation_threshold", config)
        self.assertIn("routing_teams", config)
        self.assertIn("escalation_team", config)

    def test_confidence_threshold_is_valid(self):
        config = _get_config()
        self.assertGreater(config["confidence_threshold"], 0.0)
        self.assertLessEqual(config["confidence_threshold"], 1.0)

    def test_escalation_threshold_below_confidence(self):
        config = _get_config()
        self.assertLess(
            config["escalation_threshold"],
            config["confidence_threshold"],
        )

    def test_all_categories_have_routing_teams(self):
        config = _get_config()
        expected_categories = [
            "Network", "Hardware", "Software", "Access & Identity",
            "Email & Collaboration", "Security", "Cloud & Infrastructure", "Other",
        ]
        for cat in expected_categories:
            self.assertIn(cat, config["routing_teams"], f"Missing routing for {cat}")

    def test_each_team_has_required_fields(self):
        config = _get_config()
        for cat, team in config["routing_teams"].items():
            self.assertIn("team", team, f"{cat} missing 'team'")
            self.assertIn("email", team, f"{cat} missing 'email'")
            self.assertIn("teams_channel", team, f"{cat} missing 'teams_channel'")
            self.assertIn("sla_hours", team, f"{cat} missing 'sla_hours'")


class TestHighConfidenceRouting(unittest.TestCase):
    """Test direct routing for high-confidence classifications."""

    CLASSIFICATION = {
        "category": "Network",
        "subcategory": "VPN",
        "priority": "P2-High",
        "confidence": 0.92,
        "routing_team": "Network Operations",
        "suggested_actions": ["Check VPN gateway", "Reset connection"],
        "summary": "VPN disconnects frequently during peak hours",
    }

    def test_direct_route_to_network_team(self):
        result = route_ticket(self.CLASSIFICATION, "test-high-001")
        self.assertEqual(result["routing"]["routed_to"]["team"], "Network Operations")
        self.assertFalse(result["routing"]["escalated"])
        self.assertFalse(result["routing"]["requires_review"])

    def test_sla_matches_priority(self):
        result = route_ticket(self.CLASSIFICATION, "test-high-002")
        # P2-High for Network = 4 hours (from config)
        self.assertEqual(result["routing"]["sla_hours"], 4)

    def test_correlation_id_propagated(self):
        result = route_ticket(self.CLASSIFICATION, "test-high-003")
        self.assertEqual(result["correlation_id"], "test-high-003")


class TestMediumConfidenceRouting(unittest.TestCase):
    """Test review-flagged routing for medium-confidence classifications."""

    CLASSIFICATION = {
        "category": "Software",
        "subcategory": "Crash/Error",
        "priority": "P3-Medium",
        "confidence": 0.60,
        "routing_team": "Application Support",
        "suggested_actions": ["Check event logs"],
        "summary": "Application crashes on startup",
    }

    def test_routes_to_category_team_with_review(self):
        result = route_ticket(self.CLASSIFICATION, "test-med-001")
        self.assertEqual(result["routing"]["routed_to"]["team"], "Application Support")
        self.assertTrue(result["routing"]["requires_review"])
        self.assertFalse(result["routing"]["escalated"])


class TestLowConfidenceRouting(unittest.TestCase):
    """Test escalation for low-confidence classifications."""

    CLASSIFICATION = {
        "category": "Other",
        "subcategory": "General Inquiry",
        "priority": "P4-Low",
        "confidence": 0.30,
        "routing_team": "IT Service Desk",
        "suggested_actions": ["Review ticket manually"],
        "summary": "Unclear issue description",
    }

    def test_escalates_to_triage_team(self):
        result = route_ticket(self.CLASSIFICATION, "test-low-001")
        self.assertEqual(
            result["routing"]["routed_to"]["team"],
            "IT Service Desk - Triage",
        )
        self.assertTrue(result["routing"]["escalated"])
        self.assertTrue(result["routing"]["requires_review"])

    def test_escalation_reason_mentions_low_confidence(self):
        result = route_ticket(self.CLASSIFICATION, "test-low-002")
        self.assertIn("Low confidence", result["routing"]["routing_reason"])


class TestEdgeCases(unittest.TestCase):
    """Test edge cases and boundary conditions."""

    def test_unknown_category_falls_back_to_other(self):
        classification = {
            "category": "NonExistentCategory",
            "subcategory": "Unknown",
            "priority": "P3-Medium",
            "confidence": 0.85,
            "routing_team": "Unknown",
            "suggested_actions": [],
            "summary": "Test edge case",
        }
        result = route_ticket(classification, "test-edge-001")
        # Should fall back to "Other" team routing
        self.assertEqual(result["routing"]["routed_to"]["team"], "IT Service Desk")

    def test_zero_confidence_escalates(self):
        classification = {
            "category": "Network",
            "subcategory": "VPN",
            "priority": "P2-High",
            "confidence": 0.0,
            "routing_team": "Network Operations",
            "suggested_actions": [],
            "summary": "Zero confidence test",
        }
        result = route_ticket(classification, "test-edge-002")
        self.assertTrue(result["routing"]["escalated"])

    def test_exact_threshold_routes_directly(self):
        config = _get_config()
        classification = {
            "category": "Hardware",
            "subcategory": "Laptop/Desktop",
            "priority": "P3-Medium",
            "confidence": config["confidence_threshold"],  # Exact threshold
            "routing_team": "Desktop Engineering",
            "suggested_actions": [],
            "summary": "Boundary test",
        }
        result = route_ticket(classification, "test-edge-003")
        self.assertFalse(result["routing"]["escalated"])
        self.assertFalse(result["routing"]["requires_review"])


class TestRoutingSummary(unittest.TestCase):
    """Test human-readable summary generation."""

    def test_summary_contains_key_info(self):
        classification = {
            "category": "Security",
            "subcategory": "Phishing/Spam",
            "priority": "P2-High",
            "confidence": 0.95,
            "routing_team": "SOC",
            "suggested_actions": ["Quarantine email", "Block sender"],
            "summary": "Phishing email reported by user",
        }
        result = route_ticket(classification, "test-summary-001")
        summary = get_routing_summary(result)

        self.assertIn("Security", summary)
        self.assertIn("P2-High", summary)
        self.assertIn("Security Operations Center", summary)
        self.assertIn("Quarantine email", summary)


class TestAllCategoryRouting(unittest.TestCase):
    """Verify every category routes to its designated team."""

    CATEGORY_TEAM_MAP = {
        "Network": "Network Operations",
        "Hardware": "Desktop Engineering",
        "Software": "Application Support",
        "Access & Identity": "Identity & Access Management",
        "Email & Collaboration": "Messaging & Collaboration",
        "Security": "Security Operations Center",
        "Cloud & Infrastructure": "Cloud Engineering",
        "Other": "IT Service Desk",
    }

    def test_each_category_routes_correctly(self):
        for category, expected_team in self.CATEGORY_TEAM_MAP.items():
            classification = {
                "category": category,
                "subcategory": "Test",
                "priority": "P3-Medium",
                "confidence": 0.90,
                "routing_team": expected_team,
                "suggested_actions": [],
                "summary": f"Test {category} routing",
            }
            result = route_ticket(classification, f"test-cat-{category}")
            self.assertEqual(
                result["routing"]["routed_to"]["team"],
                expected_team,
                f"Category '{category}' should route to '{expected_team}'",
            )


if __name__ == "__main__":
    unittest.main()
