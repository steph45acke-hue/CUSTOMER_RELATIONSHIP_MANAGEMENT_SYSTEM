-- ==============================
-- step 1:initialize the CRM container
-- ===============================
CREATE DATABASE IF NOT EXISTS enterprise_CRM_system;
USE enterprise_CRM_system;

-- clean up dependent tables first to ensure a fresh execution environment
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS interactions;
DROP TABLE IF EXISTS customers;

-- ===========================
-- step 2: the customer directory(master parent table)
-- =======================================
CREATE TABLE customers (
customer_id INT PRIMARY KEY AUTO_INCREMENT,
company_name VARCHAR(100) NOT NULL,
contact_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(20),
country VARCHAR(50) DEFAULT 'kenya',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============
-- step 3: the interaction ledger (one-to-many-dependent tables)
-- ================
CREATE TABLE interactions (
interaction_id INT PRIMARY KEY AUTO_INCREMENT,
Customer_id INT,
interaction_date DATE NOT NULL,
interaction_type ENUM ('call','email','in-person meeting','video demo') NOT NULL,
notes TEXT,
follow_up_required BOOLEAN DEFAULT FALSE,
FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE
);



-- =========================
-- =========================================================================
-- STEP 4: THE SALES PIPELINE (Revenue Tracking)
-- =========================================================================
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



-- =========================================================================
-- STEP 5: THE SERVICE DESK (Issue Tracking)
-- =========================================================================
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
-- STEP 6: DATA SEEDING (Populating the CRM Ecosystem)
-- =========================================================================

-- 1. Populating the Master Customer Directory
INSERT INTO customers (company_name, contact_name, email, phone, country) VALUES
('Safari Retail Logistics', 'Alex Mwangi', 'alex.m@safarilogistics.co.ke', '+254711222333', 'Kenya'),
('Kilimani Fintech Solutions', 'Amara Okafor', 'amara.o@kilimanifintech.com', '+254722333444', 'Kenya'),
('Nile Agricultural Export', 'Youssef Mansour', 'y.mansour@nileexport.eg', '+2025550199', 'Egypt');

-- 2. Populating the Interactions Ledger
-- (Linking logs back to Customer 1, 2, and 3)
INSERT INTO interactions (customer_id, interaction_date, interaction_type, notes, follow_up_required) VALUES
(1, '2026-06-15', 'In-Person Meeting', 'Met with Alex to discuss scaling up their warehouse database architecture. High interest.', TRUE),
(1, '2026-06-20', 'Email', 'Sent formal corporate proposal breakdown and custom server pricing sheet.', FALSE),
(2, '2026-06-25', 'Call', 'Routine check-in regarding system latency complaints. Transferred details to tech team.', TRUE),
(3, '2026-06-28', 'Video Demo', 'Showed Youssef our automated reporting pipeline. He requested a final contract quote.', TRUE);

-- 3. Populating the Sales Pipeline
INSERT INTO deals (customer_id, deal_name, value, stage, closing_date) VALUES
(1, 'Warehouse Management Software Suite', 450000.00, 'Negotiation', NULL),
(2, 'API Infrastructure Core Upgrade', 125000.00, 'Closed Won', '2026-06-24'),
(3, 'Supply Chain Predictive Analytics Dashboard', 850000.00, 'Proposal Sent', NULL);

-- 4. Populating the Service Desk
INSERT INTO support_tickets (customer_id, issue_subject, priority, status, assigned_to) VALUES
(2, 'Payment gateway webhooks dropping transactions intermittently', 'Critical', 'In Progress', 'Lead Engineer Peter'),
(1, 'Password reset email link expiring too quickly for warehouse staff', 'Low', 'Resolved', 'Support Desk Mary');

-- =========================================================================
-- STEP 7: THE 360-DEGREE EXECUTIVE CLIENT VIEW
-- =========================================================================
SELECT 
    c.company_name AS 'Client Company',
    c.contact_name AS 'Primary Contact',
    d.deal_name AS 'Active Deal Pipeline',
    FORMAT(d.value, 2) AS 'Deal Value (KES/USD)',
    d.stage AS 'Pipeline Stage',
    st.issue_subject AS 'Outstanding Support Issue',
    st.priority AS 'Issue Severity'
FROM customers c
LEFT JOIN deals d ON c.customer_id = d.customer_id
LEFT JOIN support_tickets st ON c.customer_id = st.customer_id AND st.status != 'Closed'
ORDER BY d.value DESC;


-- =========================================================================
-- STEP 8: THE EXECUTIVE KPI DASHBOARD (BI Aggregations)
-- =========================================================================
SELECT 
    COUNT(deal_id) AS 'Total Active Deals',
    FORMAT(SUM(value), 2) AS 'Total Pipeline Value',
    FORMAT(AVG(value), 2) AS 'Average Deal Size',
    FORMAT(MAX(value), 2) AS 'Largest Deal on Table'
FROM deals
WHERE stage NOT IN ('Closed Won', 'Closed Lost');





