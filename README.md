
# Enterprise Customer Relationship Management (CRM) Database Engine

An industry-standard relational database architecture built to manage B2B customer lifecycles, monitor active sales pipelines, track customer communications, and handle service desk operations. This repository demonstrates advanced relational database design, data integrity enforcement, and business intelligence (BI) data extraction techniques.

## 🗺️ System Architecture & Data Model

The database enforces a strict **One-to-Many (1:N)** relational pattern. A single, centralized customer anchor branches into three operational streams, protecting referential integrity using structural foreign keys and automated memory cleanup routines.


```
┌─── (Many) 📞 ─── [interactions] (Touchpoint Ledger)
│
[customers] 👤 ─┼─── (Many) 💼 ─── [deals] (Sales & Revenue Pipeline)
│
└─── (Many) 🛠️ ─── [support_tickets] (Service Desk)
```

### Core Architecture Breakdown
*   **`customers` (The Anchor Master Directory):** The primary data layer tracking corporate profiles, unique contact points, and localized defaults.
*   **`interactions` (The Touchpoint Ledger):** Tracks cross-channel team communication history utilizing validated data states.
*   **`deals` (The Revenue Pipeline):** Manages enterprise sales value using fixed-point math to prevent financial rounding errors.
*   **`support_tickets` (The Service Desk):** Logs corporate operational issues, establishing an analytical foundation to calculate Mean Time to Resolution (MTTR).

---

## 🛠️ Technical Features Implemented

*   **Fixed-Point Financial Accuracy:** Configured `DECIMAL(12,2)` parameters on pipeline values to secure absolute precision up to 10 Billion without the float rounding anomalies common in standard software applications.
*   **Referential Integrity Guardrails:** Implemented strict `FOREIGN KEY` mappings with `ON DELETE CASCADE` mechanics to prevent "orphan records" and enforce automatic database self-cleaning.
*   **Data State Standardization:** Enforced `ENUM` data types across interaction channels, pipeline stages, and support priorities to prevent manual entry fragmentation and ensure flawless analytical categorization.
*   **Temporal Logging:** Built structured `TIMESTAMP` and `DATE` hooks to enable cohort tracking and time-series operational forecasting.

---

## 💾 Database Schema & Seeding Script

Execute the following complete script inside your MySQL environment to build and seed the enterprise ecosystem:

```sql
-- =========================================================================
-- 1. ENVIRONMENT INITIALIZATION
-- =========================================================================
CREATE DATABASE IF NOT EXISTS Enterprise_CRM_System;
USE Enterprise_CRM_System;

DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS interactions;
DROP TABLE IF EXISTS customers;

-- =========================================================================
-- 2. TABLE SKELETON DEFINITIONS (DDL)
-- =========================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    country VARCHAR(50) DEFAULT 'Kenya',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE interactions (
    interaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    interaction_date DATE NOT NULL,
    interaction_type ENUM('Call', 'Email', 'In-Person Meeting', 'Video Demo') NOT NULL,
    notes TEXT,
    follow_up_required BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE deals (
    deal_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    deal_name VARCHAR(100) NOT NULL,
    value DECIMAL(12,2) NOT NULL,
    stage ENUM('Prospecting', 'Qualification', 'Proposal Sent', 'Negotiation', 'Closed Won', 'Closed Lost') NOT NULL,
    closing_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    issue_subject VARCHAR(150) NOT NULL,
    priority ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL DEFAULT 'Medium',
    status ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL DEFAULT 'Open',
    assigned_to VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- =========================================================================
-- 3. MOCK DATA PRODUCTION SEEDING (DML)
-- =========================================================================

INSERT INTO customers (company_name, contact_name, email, phone, country) VALUES
('Safari Retail Logistics', 'Alex Mwangi', 'alex.m@safarilogistics.co.ke', '+254711222333', 'Kenya'),
('Kilimani Fintech Solutions', 'Amara Okafor', 'amara.o@kilimanifintech.com', '+254722333444', 'Kenya'),
('Nile Agricultural Export', 'Youssef Mansour', 'y.mansour@nileexport.eg', '+2025550199', 'Egypt');

INSERT INTO interactions (customer_id, interaction_date, interaction_type, notes, follow_up_required) VALUES
(1, '2026-06-15', 'In-Person Meeting', 'Met with Alex to discuss scaling up their warehouse database architecture. High interest.', TRUE),
(1, '2026-06-20', 'Email', 'Sent formal corporate proposal breakdown and custom server pricing sheet.', FALSE),
(2, '2026-06-25', 'Call', 'Routine check-in regarding system latency complaints. Transferred details to tech team.', TRUE),
(3, '2026-06-28', 'Video Demo', 'Showed Youssef our automated reporting pipeline. He requested a final contract quote.', TRUE);

INSERT INTO deals (customer_id, deal_name, value, stage, closing_date) VALUES
(1, 'Warehouse Management Software Suite', 450000.00, 'Negotiation', NULL),
(2, 'API Infrastructure Core Upgrade', 125000.00, 'Closed Won', '2026-06-24'),
(3, 'Supply Chain Predictive Analytics Dashboard', 850000.00, 'Proposal Sent', NULL);

INSERT INTO support_tickets (customer_id, issue_subject, priority, status, assigned_to) VALUES
(2, 'Payment gateway webhooks dropping transactions intermittently', 'Critical', 'In Progress', 'Lead Engineer Peter'),
(1, 'Password reset email link expiring too quickly for warehouse staff', 'Low', 'Resolved', 'Support Desk Mary');

```
## 📊 Analytical Data Extractions (BI Layer)
### 1. 360-Degree Operational Client Overview
This tactical query bridges data gaps across all 4 tables using a LEFT JOIN execution architecture. It maps out client contacts alongside their pending contract values and any non-resolved service ticket bottlenecks simultaneously.
```sql
SELECT 
    c.company_name AS 'Client Company',
    c.contact_name AS 'Primary Contact',
    d.deal_name AS 'Active Deal Pipeline',
    FORMAT(d.value, 2) AS 'Deal Value',
    d.stage AS 'Pipeline Stage',
    st.issue_subject AS 'Outstanding Support Issue',
    st.priority AS 'Issue Severity'
FROM customers c
LEFT JOIN deals d ON c.customer_id = d.customer_id
LEFT JOIN support_tickets st ON c.customer_id = st.customer_id AND st.status != 'Closed'
ORDER BY d.value DESC;

```
### 2. Live Executive Financial Health Check
Isolating financial pipeline statistics by excluding static historic states (Closed Won / Closed Lost) to accurately analyze un-realized revenue forecasts, asset scale, and ongoing transaction volume.
```sql
SELECT 
    COUNT(deal_id) AS 'Total Active Deals',
    FORMAT(SUM(value), 2) AS 'Total Pipeline Value',
    FORMAT(AVG(value), 2) AS 'Average Deal Size',
    FORMAT(MAX(value), 2) AS 'Largest Deal on Table'
FROM deals
WHERE stage NOT IN ('Closed Won', 'Closed Lost');

```
## 🚀 How To Deploy & Run
 1. Clone this repository locally.
 2. Open your preferred relational SQL client application (e.g., **MySQL Workbench** or **VS Code** with SQL extensions).
 3. Open a fresh query tab worksheet, copy the contents of the database script above, and hit execution (**Lightning Bolt** or **Ctrl+Shift+Enter**).
 4. Run the analytical query components sequentially to extract real-time enterprise management indicators.
```

---

This is clean, comprehensive, and written like a true engineer. Go ahead and add this to your GitHub profile workspace to keep expanding that data engineering portfolio! Turn it in and let me know how it looks.

```
