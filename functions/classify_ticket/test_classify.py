"""
Ticket Classification — Unit Tests
===================================
Validates classify_ticket logic, input validation, and response schema.
"""

import json
import os
import sys
import unittest
from unittest.mock import MagicMock, patch

# Add functions directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

# Set required env vars before importing
os.environ.setdefault("AZURE_OPENAI_ENDPOINT", "https://test.openai.azure.com/")
os.environ.setdefault("AZURE_OPENAI_DEPLOYMENT", "gpt-4o")

from classify_ticket import classify_ticket, CATEGORIES, SYSTEM_PROMPT


class TestInputValidation(unittest.TestCase):
    """Test input validation in classify_ticket."""

    def test_empty_ticket_raises_value_error(self):
        with self.assertRaises(ValueError):
            classify_ticket("", "test-001")

    def test_whitespace_only_raises_value_error(self):
        with self.assertRaises(ValueError):
            classify_ticket("   \n\t  ", "test-002")

    def test_oversized_ticket_raises_value_error(self):
        with self.assertRaises(ValueError):
            classify_ticket("x" * 5001, "test-003")


class TestCategories(unittest.TestCase):
    """Test category definitions are well-formed."""

    def test_all_categories_have_subcategories(self):
        for cat, subs in CATEGORIES.items():
            self.assertIsInstance(subs, list, f"{cat} subcategories must be a list")
            self.assertGreater(len(subs), 0, f"{cat} must have at least one subcategory")

    def test_other_category_exists(self):
        self.assertIn("Other", CATEGORIES)


class TestSystemPrompt(unittest.TestCase):
    """Test system prompt is well-structured."""

    def test_prompt_contains_categories(self):
        for cat in CATEGORIES:
            self.assertIn(cat, SYSTEM_PROMPT)

    def test_prompt_contains_priority_levels(self):
        for priority in ["P1-Critical", "P2-High", "P3-Medium", "P4-Low"]:
            self.assertIn(priority, SYSTEM_PROMPT)

    def test_prompt_contains_pii_rule(self):
        self.assertIn("PII", SYSTEM_PROMPT)


class TestClassifyTicketWithMock(unittest.TestCase):
    """Test classify_ticket with mocked Azure OpenAI."""

    MOCK_RESPONSE = {
        "category": "Software",
        "subcategory": "Crash/Error",
        "priority": "P3-Medium",
        "confidence": 0.92,
        "routing_team": "Desktop Support",
        "suggested_actions": ["Check event logs", "Update application"],
        "summary": "Application crashes on startup after update",
    }

    @patch("classify_ticket._build_client")
    def test_successful_classification(self, mock_build):
        mock_client = MagicMock()
        mock_build.return_value = mock_client

        mock_choice = MagicMock()
        mock_choice.message.content = json.dumps(self.MOCK_RESPONSE)

        mock_usage = MagicMock()
        mock_usage.prompt_tokens = 500
        mock_usage.completion_tokens = 100

        mock_response = MagicMock()
        mock_response.choices = [mock_choice]
        mock_response.usage = mock_usage

        mock_client.chat.completions.create.return_value = mock_response

        result = classify_ticket("App keeps crashing after update", "test-100")

        self.assertEqual(result["category"], "Software")
        self.assertEqual(result["priority"], "P3-Medium")
        self.assertAlmostEqual(result["confidence"], 0.92, places=2)
        self.assertIn("correlation_id", result)

    @patch("classify_ticket._build_client")
    def test_invalid_json_raises_runtime_error(self, mock_build):
        mock_client = MagicMock()
        mock_build.return_value = mock_client

        mock_choice = MagicMock()
        mock_choice.message.content = "not valid json"

        mock_response = MagicMock()
        mock_response.choices = [mock_choice]

        mock_client.chat.completions.create.return_value = mock_response

        with self.assertRaises(RuntimeError):
            classify_ticket("Some ticket", "test-101")

    @patch("classify_ticket._build_client")
    def test_unknown_category_defaults_to_other(self, mock_build):
        mock_client = MagicMock()
        mock_build.return_value = mock_client

        bad_response = self.MOCK_RESPONSE.copy()
        bad_response["category"] = "Nonexistent"

        mock_choice = MagicMock()
        mock_choice.message.content = json.dumps(bad_response)

        mock_response = MagicMock()
        mock_response.choices = [mock_choice]
        mock_response.usage = MagicMock(prompt_tokens=100, completion_tokens=50)

        mock_client.chat.completions.create.return_value = mock_response

        result = classify_ticket("Something weird", "test-102")
        self.assertEqual(result["category"], "Other")
        self.assertEqual(result["subcategory"], "General Inquiry")

    @patch("classify_ticket._build_client")
    def test_missing_fields_get_defaults(self, mock_build):
        mock_client = MagicMock()
        mock_build.return_value = mock_client

        partial_response = {"category": "Network", "subcategory": "VPN"}
        mock_choice = MagicMock()
        mock_choice.message.content = json.dumps(partial_response)

        mock_response = MagicMock()
        mock_response.choices = [mock_choice]
        mock_response.usage = MagicMock(prompt_tokens=100, completion_tokens=50)

        mock_client.chat.completions.create.return_value = mock_response

        result = classify_ticket("VPN not connecting", "test-103")
        self.assertEqual(result["priority"], "Unknown")
        self.assertEqual(result["confidence"], 0.0)


if __name__ == "__main__":
    unittest.main()
