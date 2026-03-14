/* =============================================================================
   FILE: 03_kpi_summary.sql
   DASHBOARD: SUMMARY

   PURPOSE:
   --------
   Provides executive-level KPIs for monitoring loan volume,
   funding, cash inflow, pricing, and borrower risk.

   REPORTING LOGIC:
   ----------------
   • Dataset contains complete historical months (2021)
   • December 2021 treated as "current month" (MTD)
   • November 2021 treated as previous month (PMTD)
   • PMTD used only for MoM calculation (not displayed)

   KPI COVERAGE:
   -------------
   1. Loan Application Volume
   2. Funded Amount
   3. Amount Received
   4. Average Interest Rate (Simple Avg)
   5. Average DTI
   6. Good vs Bad Loan Performance
   7. Loan Status Grid (Power BI Table)
============================================================================= */


/* =============================================================================
   KPI 1: LOAN APPLICATION VOLUME
   LOGIC:
   - Applications are counted based on loan issuance (issue_date)
============================================================================= */

USE bankloan_db;

-- Total Loan Applications
SELECT 
	COUNT(id) AS total_loan_applications
FROM bank_loan_data;

-- MTD Loan Applications (Dec 2021)
SELECT 
	COUNT(id) AS mtd_loan_applications
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';

-- PMTD Loan Applications (Nov 2021)
SELECT 
	COUNT(id) AS pmtd_loan_applications
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';

-- MoM Growth (%)
SELECT
    dec_cnt,
    nov_cnt,
    ROUND(((dec_cnt - nov_cnt) / NULLIF(nov_cnt, 0)) * 100, 2)
        AS mom_loan_application_growth_pct
FROM (
    SELECT
        SUM(issue_date BETWEEN '2021-12-01' AND '2021-12-31') AS dec_cnt,
        SUM(issue_date BETWEEN '2021-11-01' AND '2021-11-30') AS nov_cnt
    FROM bank_loan_data
) t;


/* =============================================================================
   KPI 2: FUNDED AMOUNT
   LOGIC:
   - Funded amount is tied to loan origination (issue_date)
============================================================================= */

-- Total Funded Amount
SELECT 
	SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data;

-- MTD Funded Amount (Dec 2021)
SELECT 
	SUM(loan_amount) AS mtd_funded_amount
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';

-- PMTD Funded Amount (Nov 2021)
SELECT 
	SUM(loan_amount) AS pmtd_funded_amount
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';

-- MoM Growth (%)
SELECT
    dec_amt,
    nov_amt,
    ROUND(((dec_amt - nov_amt) / NULLIF(nov_amt, 0)) * 100, 2)
        AS mom_funded_amount_growth_pct
FROM (
    SELECT
        SUM(CASE
            WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
            THEN loan_amount END) AS dec_amt,
        SUM(CASE
            WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
            THEN loan_amount END) AS nov_amt
    FROM bank_loan_data
) t;


/* =============================================================================
   KPI 3: AMOUNT RECEIVED
   LOGIC:
   - Cash inflow depends on payment activity
   - last_payment_date must be used (not issue_date)
============================================================================= */

-- Total Amount Received
SELECT 
	SUM(total_payment) AS total_amount_received
FROM bank_loan_data;

-- MTD Amount Received (Dec 2021)
SELECT 
	SUM(total_payment) AS mtd_amount_received
FROM bank_loan_data
WHERE last_payment_date BETWEEN '2021-12-01' AND '2021-12-31';

-- PMTD Amount Received (Nov 2021)
SELECT 
	SUM(total_payment) AS pmtd_amount_received
FROM bank_loan_data
WHERE last_payment_date BETWEEN '2021-11-01' AND '2021-11-30';

-- MoM Growth (%)
SELECT
    dec_amt,
    nov_amt,
    ROUND(((dec_amt - nov_amt) / NULLIF(nov_amt, 0)) * 100, 2)
        AS mom_amount_received_growth_pct
FROM (
    SELECT
        SUM(CASE
            WHEN last_payment_date BETWEEN '2021-12-01' AND '2021-12-31'
            THEN total_payment END) AS dec_amt,
        SUM(CASE
            WHEN last_payment_date BETWEEN '2021-11-01' AND '2021-11-30'
            THEN total_payment END) AS nov_amt
    FROM bank_loan_data
) t;


/* =============================================================================
   KPI 4: AVERAGE INTEREST RATE (Simple Average)
   LOGIC:
   - Represents borrower-level pricing
   - Calculated at loan origination (issue_date)
============================================================================= */

-- Total Average Interest Rate
SELECT 
	ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct
FROM bank_loan_data;

-- MTD Average Interest Rate (Dec 2021)
SELECT 
	ROUND(AVG(int_rate) * 100, 2) AS mtd_avg_interest_rate_pct
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';

-- PMTD Average Interest Rate (Nov 2021)
SELECT 
	ROUND(AVG(int_rate) * 100, 2) AS pmtd_avg_interest_rate_pct
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';

-- MoM Growth (%)
SELECT
    dec_rate,
    nov_rate,
    ROUND(((dec_rate - nov_rate) / NULLIF(nov_rate, 0)) * 100, 2)
        AS mom_avg_interest_rate_growth_pct
FROM (
    SELECT
        AVG(CASE
            WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
            THEN int_rate END) AS dec_rate,
        AVG(CASE
            WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
            THEN int_rate END) AS nov_rate
    FROM bank_loan_data
) t;


/* =============================================================================
   KPI 5: AVERAGE DTI (DEBT-TO-INCOME)
   LOGIC:
   - Borrower risk metric at time of loan approval
============================================================================= */

-- Total Average DTI
SELECT 
	ROUND(AVG(dti) * 100, 2) AS avg_dti_pct
FROM bank_loan_data;

-- MTD Average DTI (Dec 2021)
SELECT 
	ROUND(AVG(dti) * 100, 2) AS mtd_avg_dti_pct
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';

-- PMTD Average DTI (Nov 2021)
SELECT 
	ROUND(AVG(dti) * 100, 2) AS pmtd_avg_dti_pct
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';

-- MoM Growth (%)
SELECT
    dec_dti,
    nov_dti,
    ROUND(((dec_dti - nov_dti) / NULLIF(nov_dti, 0)) * 100, 2)
        AS mom_avg_dti_growth_pct
FROM (
    SELECT
        AVG(CASE
            WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
            THEN dti END) AS dec_dti,
        AVG(CASE
            WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
            THEN dti END) AS nov_dti
    FROM bank_loan_data
) t;


/* =============================================================================
   KPI 6: GOOD vs BAD LOAN PERFORMANCE
============================================================================= */

-- Good Loans (Fully Paid + Current)
SELECT
    COUNT(*) AS good_loan_applications,
    SUM(loan_amount) AS good_loan_funded_amount,
    SUM(total_payment) AS good_loan_amount_received
FROM bank_loan_data
WHERE loan_status IN ('Fully Paid', 'Current');

-- Bad Loans (Charged Off)
SELECT
    COUNT(*) AS bad_loan_applications,
    SUM(loan_amount) AS bad_loan_funded_amount,
    SUM(total_payment) AS bad_loan_amount_received
FROM bank_loan_data
WHERE loan_status = 'Charged Off';


/* =============================================================================
   KPI 7: LOAN STATUS GRID (Power BI Table)
============================================================================= */

SELECT
    loan_status,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount,
    SUM(total_payment) AS total_amount_received,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct,
    ROUND(AVG(dti) * 100, 2) AS avg_dti_pct
FROM bank_loan_data
GROUP BY loan_status;

