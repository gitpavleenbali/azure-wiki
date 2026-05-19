# Azure Policy A–Z

Field-tested patterns for Azure Policy at enterprise scale — short, opinionated, customer-ready.

## Guides

| # | Document | Problem it solves |
|---|---|---|
| 1 | [Durable, Fine-Grained Policy Exemptions for IaC Workflows](./durable-fine-grained-exemptions.md) | Resource/RG-scoped exemptions disappear when IaC recreates the target; subscription-scoped exemptions are too broad. Builds a policy-logic + policy-as-code pattern that is both durable *and* narrow. |

## Anchor principles

1. **Governance is owned top-down.** Assignments and definitions live at MG/Subscription scope, owned by the platform team. Workloads *consume* policy; they do not *define* it.
2. **Prefer policy logic over exemptions.** If an exception can be encoded in the policy rule (tag, property, location), it survives any resource lifecycle automatically.
3. **Exemptions are exceptions, not escape hatches.** Every exemption carries an `expiresOn`, an owner, and an approval reference — enforced by a `deny` guardrail policy.
4. **Source of truth is git, reconciled by a pipeline.** Portal edits are drift.
