# 🗄️ SQL Data Analysis Portfolio

A structured collection of 48 SQL queries across 8 skill levels — from basic data exploration to advanced business analytics — built on a custom retail orders dataset using PostgreSQL.

---

## 📌 Short Description

This portfolio demonstrates end-to-end SQL proficiency using a realistic retail dataset comprising customers, orders, products, and geographic regions across the United States. The queries progress from foundational SELECT statements through to advanced window functions, CTEs, cohort analysis, and RFM customer segmentation — making it a comprehensive showcase of analytical SQL skills for data analyst roles.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| 🐘 **PostgreSQL** | Core database engine |
| 🦫 **DBeaver** | SQL editor and query execution environment |
| 🧠 **SQL (Advanced)** | Window functions, CTEs, subqueries, aggregations |
| 🗃️ **Custom Dataset** | Synthetic retail data — orders, customers, regions |
| 📁 **File Format** | `.sql` — fully annotated and section-organised |

---

## 🗂️ Database Schema

Three core tables, joined across all analysis sections:

| Table | Key Columns | Description |
|-------|-------------|-------------|
| `orders` | ordernum, order_date, customer_id, product, unit_price, quantity, total, discount, year | All transactional order data |
| `customers` | customer_id, name, address, city, state, zip, mail_list | Customer demographics and mailing list status |
| `regions` | state, state_name, region | US state-to-region mapping |

---

## ✨ Features & Highlights

### 🔴 Business Problem

Raw transactional data alone doesn't answer the questions that drive business decisions:

- Who are the highest-value customers — and are they on the mailing list?
- Which products are growing, and which are declining year-over-year?
- What does the true revenue contribution look like across regions?
- Are discounts actually helping or hurting average order value?
- Which customers are at risk of churning based on purchase recency?

This portfolio works through all of these questions systematically using SQL — the way a real data analyst would.

### 🖥️ Query Sections Walkthrough

The file is organized into **8 clearly labelled sections**, each building on the last:

**Section 1 — Basic Queries** *(Q1–Q10)*
Data exploration and filtering — SELECT, WHERE, BETWEEN, IN, ILIKE, DISTINCT. Covers viewing records, filtering by date, state, product, and mailing list status.

**Section 2 — Aggregate Functions** *(Q11–Q18)*
Summary statistics and KPIs — SUM, AVG, MIN, MAX, COUNT, GROUP BY, HAVING. Covers total revenue, product performance, yearly order trends, regional revenue, and mailing list subscription rate.

**Section 3 — Joins** *(Q19–Q23)*
Combining tables — INNER JOIN, LEFT JOIN across all three tables. Covers orders with full customer and region detail, customers who never ordered, states with no customers, customer total spend, and top products per region using RANK().

**Section 4 — Subqueries** *(Q24–Q27)*
Nested logic — inline subqueries, correlated subqueries, HAVING with subqueries. Covers above-average spenders, above-average products, most recent order per customer, and customers active across all three years.

**Section 5 — CASE WHEN** *(Q28–Q30)*
Conditional logic and segmentation. Covers customer spending tier classification (High/Mid/Low/Occasional), discount size categorisation per order line, and a year-over-year revenue pivot table by product.

**Section 6 — Window Functions** *(Q31–Q36)*
Ranking and running totals — RANK(), DENSE_RANK(), ROW_NUMBER(), SUM() OVER(), LAG(). Covers customer spend ranking, running revenue totals, cumulative spend per customer, product share of monthly revenue, top customer per region, and month-over-month revenue change.

**Section 7 — CTEs** *(Q37–Q40)*
Readable, reusable logic using Common Table Expressions. Covers top customers with region and mailing list enrichment, YoY product revenue growth, a full RFM (Recency, Frequency, Monetary) customer scoring model, and repeat vs one-time buyer revenue contribution.

**Section 8 — Advanced Analysis** *(Q41–Q48)*
Business intelligence queries. Covers product affinity (market basket pairs), purchase cadence (avg days between orders), cohort revenue analysis, declining product detection, discount impact analysis, Pareto/80-20 revenue concentration, 3-month moving average revenue, and a full Customer 360 view with all key metrics in a single row per customer.

---

### 💡 Key Business Insights Uncovered

- **🛒 RFM Segmentation (Q39)** — customers are scored on Recency, Frequency, and Monetary value using NTILE(), enabling tiered marketing and retention strategies.

- **📦 Product Affinity (Q41)** — identifies which product pairs are most frequently ordered together, directly supporting cross-sell and bundle recommendations.

- **📉 Declining Products (Q44)** — flags products where current year revenue is lower than the prior year, giving sales teams an early warning signal.

- **💸 Discount Impact (Q45)** — compares average order value with and without discounts per product, revealing whether discounting is driving or eroding revenue.

- **🏆 Pareto Check (Q46)** — uses NTILE(5) to validate whether the top 20% of customers generate ~80% of revenue, a key insight for prioritising account management.

- **👤 Customer 360 (Q48)** — produces a single-row summary per customer combining spend, order frequency, recency, discount received, and segment — the kind of output that feeds directly into CRM systems or dashboards.
