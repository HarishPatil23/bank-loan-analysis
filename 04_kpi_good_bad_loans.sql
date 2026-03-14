-- ======================================================
-- FILE: 04_kpi_good_bad_loans.sql
-- GOOD LOAN ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Good loans represent performing assets that generate
-- stable cash flows and low credit risk.
-- Tracking good loan metrics helps assess overall
-- portfolio health and lending quality.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Good Loan Application Percentage
-- BUSINESS PURPOSE:
-- Indicates the proportion of healthy loans
-- in the overall loan portfolio.
-- Higher percentage = better portfolio quality.
-- ------------------------------------------------------
SELECT 
    ROUND(
        (SUM(CASE 
            WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 
            ELSE 0 
        END) * 100.0) / COUNT(id),
        2
    ) AS good_loan_application_percentage
FROM bank_loan_data;


-- ------------------------------------------------------
-- KPI: Good Loan Applications
-- BUSINESS PURPOSE:
-- Counts total number of loan applications
-- that are currently performing or fully repaid.
-- ------------------------------------------------------
SELECT 
    COUNT(id) AS good_loan_applications
FROM bank_loan_data
WHERE loan_status IN ('Fully Paid', 'Current');


-- ------------------------------------------------------
-- KPI: Good Loan Funded Amount
-- BUSINESS PURPOSE:
-- Measures total capital deployed into
-- performing (low-risk) loans.
-- ------------------------------------------------------
SELECT 
    SUM(loan_amount) AS good_loan_funded_amount
FROM bank_loan_data
WHERE loan_status IN ('Fully Paid', 'Current');


-- ------------------------------------------------------
-- KPI: Good Loan Total Amount Received
-- BUSINESS PURPOSE:
-- Represents total cash inflow received
-- from healthy loans.
-- Critical for liquidity and revenue assessment.
-- ------------------------------------------------------
SELECT 
    SUM(total_payment) AS good_loan_amount_received
FROM bank_loan_data
WHERE loan_status IN ('Fully Paid', 'Current');


-- ======================================================
-- BAD LOAN ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Bad loans represent non-performing assets that
-- pose credit risk and potential financial losses.
-- Monitoring these metrics helps banks evaluate
-- risk exposure and portfolio stability.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Bad Loan Application Percentage
-- BUSINESS PURPOSE:
-- Measures proportion of loans that have defaulted.
-- Higher percentage indicates elevated credit risk.
-- ------------------------------------------------------
SELECT 
    ROUND(
        (SUM(CASE 
            WHEN loan_status = 'Charged Off' THEN 1 
            ELSE 0 
        END) * 100.0) / COUNT(id),
        2
    ) AS bad_loan_application_percentage
FROM bank_loan_data;


-- ------------------------------------------------------
-- KPI: Bad Loan Applications
-- BUSINESS PURPOSE:
-- Counts total number of loans that have defaulted.
-- ------------------------------------------------------
SELECT 
    COUNT(id) AS bad_loan_applications
FROM bank_loan_data
WHERE loan_status = 'Charged Off';


-- ------------------------------------------------------
-- KPI: Bad Loan Funded Amount
-- BUSINESS PURPOSE:
-- Measures total capital exposed to default risk.
-- ------------------------------------------------------
SELECT 
    SUM(loan_amount) AS bad_loan_funded_amount
FROM bank_loan_data
WHERE loan_status = 'Charged Off';


-- ------------------------------------------------------
-- KPI: Bad Loan Total Amount Received
-- BUSINESS PURPOSE:
-- Captures partial repayments received before
-- loans were charged off.
-- Used to assess recovery levels.
-- ------------------------------------------------------
SELECT 
    SUM(total_payment) AS bad_loan_amount_received
FROM bank_loan_data
WHERE loan_status = 'Charged Off';