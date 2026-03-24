"""
IT Ticket Classification — Evaluation Script
==============================================
Runs the test-set.jsonl against the classify_ticket function
and reports accuracy metrics for category, subcategory, and priority.

Usage:
    python eval.py                    # Run against live Azure OpenAI
    python eval.py --dry-run          # Validate test set only (no API calls)
"""

import argparse
import json
import os
import sys
from pathlib import Path

# Add functions path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "functions"))
os.environ.setdefault("AZURE_OPENAI_ENDPOINT", os.environ.get("AZURE_OPENAI_ENDPOINT", ""))
os.environ.setdefault("AZURE_OPENAI_DEPLOYMENT", "gpt-4o")


def load_test_set(path: str = "test-set.jsonl") -> list[dict]:
    """Load JSONL test set."""
    cases = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                cases.append(json.loads(line))
    return cases


def run_evaluation(test_cases: list[dict], dry_run: bool = False) -> dict:
    """Run classification against each test case and compute accuracy."""
    if not dry_run:
        from classify_ticket import classify_ticket

    results = []
    correct = {"category": 0, "subcategory": 0, "priority": 0}
    total = len(test_cases)

    for case in test_cases:
        ticket_id = case["id"]
        ticket_text = case["ticket_text"]

        if dry_run:
            print(f"  [DRY-RUN] {ticket_id}: {ticket_text[:60]}...")
            continue

        try:
            result = classify_ticket(ticket_text, f"eval-{ticket_id}")
            match_cat = result["category"] == case["expected_category"]
            match_sub = result["subcategory"] == case["expected_subcategory"]
            match_pri = result["priority"] == case["expected_priority"]

            correct["category"] += int(match_cat)
            correct["subcategory"] += int(match_sub)
            correct["priority"] += int(match_pri)

            results.append({
                "id": ticket_id,
                "predicted_category": result["category"],
                "expected_category": case["expected_category"],
                "category_match": match_cat,
                "predicted_priority": result["priority"],
                "expected_priority": case["expected_priority"],
                "priority_match": match_pri,
                "confidence": result["confidence"],
            })

            status = "PASS" if (match_cat and match_pri) else "FAIL"
            print(f"  [{status}] {ticket_id}: {result['category']}/{result['priority']} "
                  f"(expected {case['expected_category']}/{case['expected_priority']})")

        except Exception as exc:
            print(f"  [ERROR] {ticket_id}: {exc}")
            results.append({"id": ticket_id, "error": str(exc)})

    if dry_run:
        print(f"\n  Validated {total} test cases (no API calls).")
        return {"total": total, "dry_run": True}

    accuracy = {k: v / total if total else 0 for k, v in correct.items()}
    report = {
        "total": total,
        "correct": correct,
        "accuracy": accuracy,
        "details": results,
    }

    print(f"\n  === Evaluation Results ===")
    print(f"  Total test cases:      {total}")
    print(f"  Category accuracy:     {accuracy['category']:.1%}")
    print(f"  Subcategory accuracy:  {accuracy['subcategory']:.1%}")
    print(f"  Priority accuracy:     {accuracy['priority']:.1%}")

    return report


def main():
    parser = argparse.ArgumentParser(description="Evaluate ticket classification")
    parser.add_argument("--dry-run", action="store_true", help="Validate test set only")
    parser.add_argument("--test-set", default="test-set.jsonl", help="Path to test set JSONL")
    args = parser.parse_args()

    test_cases = load_test_set(args.test_set)
    print(f"Loaded {len(test_cases)} test cases from {args.test_set}\n")

    report = run_evaluation(test_cases, dry_run=args.dry_run)

    # Save report
    out_path = "eval-report.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print(f"\n  Report saved to {out_path}")


if __name__ == "__main__":
    main()
