
/* ======================================================
-- FILE: 06_overview_dashboard.sql
-- DASHBOARD: OVERVIEW DASHBOARD ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- This section provides high-level aggregated views
-- used in the executive overview dashboard.
-- The queries support trend analysis, regional
-- performance comparison, and portfolio segmentation.
-- These visuals help leadership quickly assess
-- lending activity, funding levels, and cash inflows.
-- ======================================================*/

USE bankloan_db;

-- ----------------------------------------------------------
-- VIEW: Monthly Lending & Collection Trend (Line/Area Chart)
-- BUSINESS PURPOSE:
-- Enables time-based trend analysis of loan applications,
-- capital deployment, and amount received.
-- Used for identifying seasonality and growth patterns.
-- ----------------------------------------------------------
SELECT
    YEAR(issue_date) AS year,
    MONTH(issue_date) AS month_number,
    MONTHNAME(issue_date) AS month_name,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount,
    SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY 
    YEAR(issue_date),
    MONTH(issue_date),
    MONTHNAME(issue_date)
ORDER BY 
    year,
    month_number;



-- -------------------------------------------------------
-- VIEW: Loan Applications & Funding by Region (Shape Map)
-- BUSINESS PURPOSE:
-- Compares lending activity and funded amounts
-- across different states.
-- Helps identify high-performing and underperforming
-- geographic regions.
-- -------------------------------------------------------
SELECT
    address_state,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY address_state;



-- -------------------------------------------------------------
-- VIEW: Loan Applications & Funding by Loan Purpose (Bar Chart)
-- BUSINESS PURPOSE:
-- Analyzes customer borrowing intent by purpose.
-- Supports product strategy and risk segmentation.
-- -------------------------------------------------------------
SELECT
    purpose,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY purpose;



-- ------------------------------------------------------------
-- VIEW: Loan Applications & Funding by Loan Term (Donut Chart)
-- BUSINESS PURPOSE:
-- Evaluates customer preference for loan duration.
-- Helps assess exposure across short-term
-- and long-term lending products.
-- ------------------------------------------------------------
SELECT
    term,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY term;



-- ------------------------------------------------------
-- VIEW: Employment Length Loan Analysis (Bar Chart)
-- BUSINESS PURPOSE:
-- Provides analysis of loan applications based on 
-- borrower employment length.
-- Helps identify which employment segments contribute 
-- most to loan volume, funding amount, and repayments.
-- ------------------------------------------------------

SELECT
    emp_length,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount,
    SUM(total_payment) AS total_amount_received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;



-- --------------------------------------------------------------
-- VIEW: Loan Applications & Funding by Home Ownership (Tree Map)
-- BUSINESS PURPOSE:
-- Segments the loan portfolio by borrower
-- home ownership status.
-- Supports credit risk and demographic analysis.
-- --------------------------------------------------------------
SELECT
    home_ownership,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY home_ownership;
