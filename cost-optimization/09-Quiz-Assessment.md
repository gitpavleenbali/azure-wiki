# Quiz & Assessment: Azure Cost Optimization

> **Duration:** 20 minutes | **Format:** Discussion-based knowledge check  
> **Tip:** Use these questions throughout your delivery or as a closing assessment

---

## Section 1: Cost Optimization Fundamentals (Module 1)

### Q1. What are the 5 WAF Cost Optimization Design Principles?

<details>
<summary>Answer</summary>

1. **Develop cost-management discipline** - Build FinOps culture, accountability
2. **Design with a cost-efficiency mindset** - Every decision has financial impact
3. **Design for usage optimization** - Maximize investment, avoid underutilization
4. **Design for rate optimization** - Leverage discounts and commitments
5. **Monitor and optimize over time** - Continuous improvement through data

</details>

---

### Q2. What are the three fundamental cloud cost drivers?

<details>
<summary>Answer</summary>

1. **Compute** - VMs, containers, functions, app services
2. **Storage** - Blob, disk, files, databases
3. **Data Transfer (Egress)** - Outbound data, cross-region traffic

</details>

---

### Q3. True or False: A cost-optimized workload is always the cheapest workload.

<details>
<summary>Answer</summary>

**False.** A cost-optimized workload maximizes value per dollar spent while meeting performance, reliability, and security requirements. Choosing the cheapest option without considering these factors can damage business outcomes.

</details>

---

### Q4. Name at least 4 Azure native tools for cost management.

<details>
<summary>Answer</summary>

1. Azure Cost Management (cost analysis, budgets, exports)
2. Azure Advisor (personalized recommendations)
3. Azure Pricing Calculator
4. TCO Calculator
5. Azure Hybrid Benefit Calculator
6. FinOps Toolkit
7. Cost Optimization Workbook (Advisor Workbooks)

</details>

---

## Section 2: Cost Transparency (Module 2)

### Q5. What are the 5 recommended cost tags every resource should have?

<details>
<summary>Answer</summary>

1. **CostCenter** - Financial allocation code
2. **BusinessUnit** - Organizational unit
3. **WorkloadName** - Application/workload name
4. **Environment** - Production, Staging, Dev, Test
5. **BudgetApproved** - Budget approval status

Optional but recommended: Owner, Project, EndDate

</details>

---

### Q6. What are the three levels of tag governance using Azure Policy? What effect does each use?

<details>
<summary>Answer</summary>

| Level | Policy Effect | Purpose |
|-------|--------------|---------|
| 1. **Audit** | `audit` | Report non-compliant resources (visibility only) |
| 2. **Append** | `append` / `modify` | Auto-add tags with default values |
| 3. **Deny** | `deny` | Block resource creation without required tags |

Best practice: Start with Audit, escalate to Deny over time.

</details>

---

### Q7. What is the difference between Showback and Chargeback?

<details>
<summary>Answer</summary>

- **Showback:** Display costs to teams for awareness without billing them. Best for early-stage FinOps.
- **Chargeback:** Actually bill costs back to business units/cost centers. Requires mature tagging and allocation model.
- Most enterprises use a **hybrid approach** - chargeback for dedicated, showback for shared.

</details>

---

## Section 3: Financial Controls (Module 3)

### Q8. At what 5 threshold percentages should you set budget alerts?

<details>
<summary>Answer</summary>

| Threshold | Type | Action |
|-----------|------|--------|
| **50%** | Actual | Awareness notification |
| **75%** | Actual | Review spending |
| **90%** | Actual | Investigate root causes |
| **100%** | Actual | Urgent action required |
| **110%** | Forecasted | Escalation to management |

</details>

---

### Q9. What are the three scopes at which you can deploy budgets?

<details>
<summary>Answer</summary>

1. **Management Group** - Enterprise-wide governance
2. **Subscription** - Per-subscription control
3. **Resource Group** - Per-workload/application control

</details>

---

## Section 4: Rate Optimization (Module 4)

### Q10. Compare Azure Reservations vs Azure Savings Plans.

<details>
<summary>Answer</summary>

| Feature | Reservations | Savings Plans |
|---------|-------------|---------------|
| Savings | Up to **72%** | Up to **65%** |
| Flexibility | Fixed SKU + Region | **Any** SKU, **any** region |
| Scope | Per resource type | Compute only |
| Term | 1 or 3 years | 1 or 3 years |
| Best For | Stable workloads, same SKU/region | Variable compute needs |

</details>

---

### Q11. What is Azure Hybrid Benefit and what is the maximum savings?

<details>
<summary>Answer</summary>

Azure Hybrid Benefit allows customers to **use their on-premises Windows Server and SQL Server licenses (with Software Assurance) on Azure** at no additional license cost.

- Windows VMs: up to **40% savings**
- SQL VMs: up to **55% savings**
- Combined (Windows + SQL): up to **82% savings**

Can be enforced via Azure Policy with `deny` effect.

</details>

---

### Q12. When should you use Spot VMs vs Reserved Instances?

<details>
<summary>Answer</summary>

| Scenario | Use Spot VMs | Use Reserved Instances |
|----------|-------------|----------------------|
| Workload type | Interruptible, stateless | Stable, predictable |
| Eviction tolerance | Can handle 30s eviction notice | Requires guaranteed availability |
| Examples | Batch, CI/CD, dev/test | Production databases, web servers |
| Savings | Up to **90%** | Up to **72%** |
| Commitment | No commitment | 1 or 3 year term |

</details>

---

## Section 5: Usage Optimization (Module 5)

### Q13. Name 5 types of idle Azure resources that commonly waste money.

<details>
<summary>Answer</summary>

1. **Stopped (not deallocated) VMs** - Still paying for compute
2. **Unattached Managed Disks** - Orphaned after VM deletion
3. **Idle Load Balancers** - No backend pool targets
4. **Orphaned Public IPs** - Standard SKU charged even when unattached
5. **Idle Application Gateways** - No backend targets, high base cost
6. Old disk snapshots (30+ days)
7. Stopped but deployed Web Apps
8. Unused VNet Gateways

</details>

---

### Q14. What are the 4 Azure Blob Storage access tiers and when should you use each?

<details>
<summary>Answer</summary>

| Tier | Access Pattern | Minimum Retention |
|------|---------------|-------------------|
| **Hot** | Frequent access | None |
| **Cool** | Infrequent (30+ days) | 30 days |
| **Cold** | Rare (90+ days) | 90 days |
| **Archive** | Almost never (180+ days) | 180 days |

Use **Lifecycle Management Policies** to automate transitions.

</details>

---

### Q15. What is the difference between a Stopped and a Deallocated VM?

<details>
<summary>Answer</summary>

| State | Billing | Hardware |
|-------|---------|----------|
| **Stopped** | Still billed for compute | Hardware allocated to you |
| **Stopped (Deallocated)** | No compute charges | Hardware released |

**Key insight:** You MUST deallocate (not just stop) VMs to stop compute billing. Disks and networking continue to incur charges in both states.

</details>

---

## Section 6: Workload-Specific (Module 6)

### Q16. Name 5 AKS-specific cost optimization strategies.

<details>
<summary>Answer</summary>

1. **Cluster Autoscaler** - Scale nodes based on pod demand
2. **Spot Node Pools** - Up to 90% savings for non-critical workloads
3. **Cluster Start/Stop** - Shutdown dev/test clusters off-hours
4. **KEDA** - Event-driven scaling, scale to zero
5. **Node Autoprovision (NAP)** - Auto-select optimal VM SKU
6. Arm64 nodes for cost-efficient processing
7. AKS Cost Analysis add-on for visibility
8. Migrate Container Insights to Managed Prometheus

</details>

---

### Q17. How can you reduce Log Analytics costs?

<details>
<summary>Answer</summary>

1. **Commitment Tiers** - Pre-commit to daily ingestion volume (15-30% savings)
2. **Basic Logs Plan** - Lower cost for infrequently queried tables (60-80% savings)
3. **Data Collection Rules** - Filter data before ingestion
4. **Table-level Retention** - Different retention per table
5. **Dedicated Cluster** - Volume discounts for 100+ GB/day
6. **Transformations** - Modify/filter logs before storage

</details>

---

### Q18. How would you reduce Azure Storage costs for a workload with lots of old blobs?

<details>
<summary>Answer</summary>

1. **Upgrade to GPv2** (if still on v1) - enables tiering
2. **Enable Lifecycle Management Policy** - auto-move blobs: Hot > Cool (30 days) > Cold (90 days) > Archive (180 days)
3. **Delete old snapshots** - clean up 30+ day snapshots
4. **Move snapshots to Standard tier** - 60% savings vs Premium
5. **Reserved Capacity** - pre-pay for stable storage (up to 38% savings)
6. **Review redundancy** - LRS vs GRS for non-critical data

</details>

---

## Bonus Discussion Questions

### Q19. If you had to implement cost optimization in 3 phases, what would each phase contain?

<details>
<summary>Suggested Answer</summary>

**Phase 1: Quick Wins (Week 1-2)**
- Delete idle resources (VMs, disks, IPs, LBs)
- Enable Azure Hybrid Benefit on all eligible resources
- Set up budgets and alerts at all scopes
- Tag all resources with cost tags

**Phase 2: Structured Optimization (Month 1-3)**
- Purchase Reservations/Savings Plans based on usage analysis
- Implement autoscaling (VMs, AKS, App Service)
- Deploy Azure Policy for tag enforcement and SKU restrictions
- Enable storage lifecycle management

**Phase 3: FinOps Practice (Month 3-12)**
- Establish regular cost review cadence
- Implement chargeback model
- Automate waste detection and cleanup
- Evaluate containerization/serverless migration opportunities
- Continuous right-sizing and optimization

</details>

---

### Q20. Your customer's Azure bill jumped 40% last month. Walk through your investigation steps.

<details>
<summary>Suggested Answer</summary>

1. **Open Cost Analysis** - Compare current vs previous month, group by service
2. **Check Anomaly Alerts** - Were any triggered?
3. **Identify top 5 cost drivers** - Which services increased?
4. **Check for sprawl** - Were new resources created? By whom?
5. **Review autoscale events** - Did any scale-out occur?
6. **Check data transfer** - Unexpected egress?
7. **Review Log Analytics ingestion** - Data explosion?
8. **Check reservations** - Did any expire?
9. **Review Azure Advisor** - New recommendations?
10. **Implement guardrails** - Add policies to prevent recurrence

</details>

---

## Scoring Guide

| Score | Level | Recommendation |
|-------|-------|---------------|
| 18-20 correct | Expert | Ready to lead cost optimization initiatives |
| 14-17 correct | Advanced | Strong foundation, deepen workload-specific knowledge |
| 10-13 correct | Intermediate | Good awareness, practice with hands-on demos |
| Below 10 | Beginner | Review modules 1-3, focus on fundamentals |

---

*These questions can be used as interactive discussion prompts during the delivery or as a post-session assessment.*

---

> **Previous Module:** [Module 8 — Demo Guide](./08-Demo-Guide.md)  
> **Back to Overview:** [README — Cost Optimization](./README.md)
