/* =============================================================================
   PROJECT: BANK LOAN ANALYSIS
   DATABASE: MySQL 8.0
   FILE: 00_master_bank_loan_analysis.sql

   PURPOSE:
   --------
   This master SQL script documents the complete analytical logic used to
   validate KPIs and dashboard metrics before visualizing them in Power BI.

   WHY THIS FILE EXISTS:
   ---------------------
   • Acts as a single source of truth for all KPIs
   • Ensures Power BI results are not “garbage in, garbage out”
   • Enables row-level and aggregate validation
   • Provides interview-ready explanations for each metric

   IMPORTANT DESIGN NOTE:
   ----------------------
   • Loan issuance metrics -> based on issue_date
   • Cash received metrics -> based on last_payment_date
   • Dataset contains full historical months (2021), so MTD = full month
============================================================================= */


/* =============================================================================
   SECTION 0: DATABASE SETUP
============================================================================= */

DROP DATABASE IF EXISTS bankloan_db;
CREATE DATABASE bankloan_db;
USE bankloan_db;


/* =============================================================================
   SECTION 1: TABLE CREATION
   BUSINESS CONTEXT:
   -----------------
   This table represents loan-level granularity.
   Each row = one loan issued to a borrower.
============================================================================= */

CREATE TABLE bank_loan_data (
    id                      INT PRIMARY KEY,
    address_state           CHAR(2),
    application_type        VARCHAR(30),
    emp_length              VARCHAR(20),
    emp_title               VARCHAR(100),
    grade                   CHAR(1),
    home_ownership          VARCHAR(20),

    issue_date              DATE,
    last_credit_pull_date   DATE,
    last_payment_date       DATE,
    next_payment_date       DATE,

    loan_status             VARCHAR(30),
    member_id               INT,
    purpose                 VARCHAR(50),
    sub_grade               VARCHAR(3),
    term                    VARCHAR(20),
    verification_status     VARCHAR(30),

    annual_income           DECIMAL(12,2),
    dti                     DECIMAL(5,2),
    installment             DECIMAL(10,2),
    int_rate                DECIMAL(5,4),   -- stored as decimal (e.g., 0.1345)
    loan_amount             DECIMAL(12,2),
    total_acc               INT,
    total_payment           DECIMAL(12,2)
);


/* =============================================================================
   SECTION 2: DATA INGESTION (CSV -> TABLE)
   DATA QUALITY HANDLING:
   ----------------------
   • Empty date fields handled using NULLIF
   • Dates converted from DD-MM-YYYY format
============================================================================= */

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_loan.csv'
INTO TABLE bank_loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id,
    address_state,
    application_type,
    emp_length,
    emp_title,
    grade,
    home_ownership,

    @issue_date,
    @last_credit_pull_date,
    @last_payment_date,

    loan_status,
    @next_payment_date,

    member_id,
    purpose,
    sub_grade,
    term,
    verification_status,

    annual_income,
    dti,
    installment,
    int_rate,
    loan_amount,
    total_acc,
    total_payment
)
SET
    issue_date = STR_TO_DATE(NULLIF(@issue_date,''), '%d-%m-%Y'),
    last_credit_pull_date = STR_TO_DATE(NULLIF(@last_credit_pull_date,''), '%d-%m-%Y'),
    last_payment_date = STR_TO_DATE(NULLIF(@last_payment_date,''), '%d-%m-%Y'),
    next_payment_date = STR_TO_DATE(NULLIF(@next_payment_date,''), '%d-%m-%Y');


/* =============================================================================
   SECTION 3: DATA SANITY CHECK
============================================================================= */

SELECT COUNT(*) AS total_records FROM bank_loan_data;
SELECT * FROM bank_loan_data LIMIT 100;


-- ======================================================
-- SECTION 4: LOAN APPLICATION VOLUME ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Loan application volume reflects customer demand
-- for credit and overall market activity.
-- It is an early indicator of lending growth,
-- sales pipeline strength, and future disbursements.
--
-- NOTE ON MTD / PMTD:
-- The dataset contains complete historical months (2021).
-- Therefore, "MTD" represents the full month for
-- reporting consistency with Power BI.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Total Loan Applications
-- BUSINESS PURPOSE:
-- Measures the total number of loan applications
-- received across the entire portfolio.
-- ------------------------------------------------------
SELECT 
    COUNT(id) AS total_loan_applications
FROM bank_loan_data;


-- ======================================================
-- KPI: Month-to-Date (MTD) Loan Applications
-- ASSUMPTION:
-- December 2021 is treated as the current reporting month
-- based on dataset timeline.
-- ======================================================
SELECT 
    COUNT(id) AS mtd_loan_applications
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';


-- ======================================================
-- KPI: Previous Month-to-Date (PMTD) Loan Applications
-- BUSINESS PURPOSE:
-- Serves as a baseline for Month-over-Month
-- application volume comparison.
-- ======================================================
SELECT 
    COUNT(id) AS pmtd_loan_applications
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';


-- ======================================================
-- KPI: Month-over-Month (MoM) Growth – Loan Applications
-- BUSINESS PURPOSE:
-- Measures the percentage change in loan
-- application volume between the current
-- and previous month.
-- Indicates demand growth or slowdown.
-- ======================================================
SELECT
    ROUND(
        ((mtd_applications - pmtd_applications)
        / NULLIF(pmtd_applications, 0)) * 100,
        2
    ) AS mom_loan_application_growth_percentage
FROM (
    SELECT
        COUNT(CASE 
                WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
                THEN id
            END) AS mtd_applications,

        COUNT(CASE 
                WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
                THEN id
            END) AS pmtd_applications
    FROM bank_loan_data
) t;



-- ======================================================
-- SECTION 5: FUNDED AMOUNT ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Funded amount represents the total capital deployed
-- by the bank through loan issuance.
-- It is a key indicator of lending activity,
-- portfolio growth, and capital utilization.
--
-- NOTE ON MTD / PMTD:
-- The dataset contains complete historical months (2021).
-- Therefore, "MTD" represents the full month for
-- reporting consistency with Power BI.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Total Funded Amount
-- BUSINESS PURPOSE:
-- Measures the total loan amount funded
-- across the entire loan portfolio.
-- ------------------------------------------------------
SELECT 
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data;



-- ======================================================
-- KPI: Month-to-Date (MTD) Total Funded Amount
-- ASSUMPTION:
-- December 2021 is treated as the current reporting month
-- based on dataset timeline.
-- ======================================================
SELECT 
    SUM(loan_amount) AS mtd_total_funded_amount
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';


-- ======================================================
-- KPI: Previous Month-to-Date (PMTD) Total Funded Amount
-- BUSINESS PURPOSE:
-- Serves as a baseline for Month-over-Month
-- funded amount comparison.
-- ======================================================
SELECT 
    SUM(loan_amount) AS pmtd_total_funded_amount
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';



-- ======================================================
-- KPI: Month-over-Month (MoM) Growth – Funded Amount
-- BUSINESS PURPOSE:
-- Measures the percentage change in total
-- capital deployed between the current and
-- previous month.
-- Indicates lending growth or slowdown.
-- ======================================================
SELECT 
    ROUND(
        ((mtd_funded_amount - pmtd_funded_amount)
        / NULLIF(pmtd_funded_amount, 0)) * 100,
        2
    ) AS mom_funded_amount_growth_percentage
FROM (
    SELECT
        SUM(CASE 
                WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31' 
                THEN loan_amount
            END) AS mtd_funded_amount,

        SUM(CASE 
                WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30' 
                THEN loan_amount
            END) AS pmtd_funded_amount
    FROM bank_loan_data
) t;


-- ======================================================
-- SECTION 6: AMOUNT RECEIVED ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Amount received represents actual cash inflow
-- from borrowers and reflects repayment behavior,
-- liquidity position, and portfolio health.
--
-- NOTE ON MTD / PMTD:
-- The dataset contains complete historical months (2021).
-- Therefore, "MTD" represents the full month for
-- reporting consistency with Power BI.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Total Amount Received
-- BUSINESS PURPOSE:
-- Measures total cash inflow collected from borrowers
-- across the entire loan portfolio.
-- ------------------------------------------------------
SELECT 
    SUM(total_payment) AS total_amount_received
FROM bank_loan_data;



-- ======================================================
-- KPI: Month-to-Date (MTD) Total Amount Received
-- ASSUMPTION:
-- December 2021 is treated as the current reporting month
-- based on dataset timeline.
-- ======================================================
SELECT 
    SUM(total_payment) AS mtd_total_amount_received
FROM bank_loan_data
WHERE last_payment_date BETWEEN '2021-12-01' AND '2021-12-31';



-- ======================================================
-- KPI: Previous Month-to-Date (PMTD) Total Amount Received
-- BUSINESS PURPOSE:
-- Acts as a baseline for Month-over-Month
-- cash inflow comparison.
-- ======================================================
SELECT 
    SUM(total_payment) AS pmtd_total_amount_received
FROM bank_loan_data
WHERE last_payment_date BETWEEN '2021-11-01' AND '2021-11-30';



-- ======================================================
-- KPI: Month-over-Month (MoM) Growth – Amount Received
-- BUSINESS PURPOSE:
-- Measures percentage change in cash inflow
-- between current and previous month.
-- Indicates repayment trend improvement or decline.
-- ======================================================
SELECT 
    ROUND(
        ((mtd_amt_received - pmtd_amt_received)
        / NULLIF(pmtd_amt_received, 0)) * 100,
        2
    ) AS mom_amount_received_growth_percentage
FROM (
    SELECT
        SUM(CASE 
                WHEN last_payment_date BETWEEN '2021-12-01' AND '2021-12-31'
                THEN total_payment
            END) AS mtd_amt_received,

        SUM(CASE 
                WHEN last_payment_date BETWEEN '2021-11-01' AND '2021-11-30'
                THEN total_payment
            END) AS pmtd_amt_received
    FROM bank_loan_data
) t;


-- ======================================================
-- SECTION 7: AVERAGE INTEREST RATE ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Interest rate analysis helps assess the overall cost of
-- lending and pricing strategy of the bank.
--
-- NOTE ON MTD / PMTD:
-- The dataset contains complete historical months (2021).
-- Therefore, "MTD" represents the full month for reporting
-- and validation consistency with Power BI.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Overall Average Interest Rate
-- BUSINESS PURPOSE:
-- Measures the average cost of lending across
-- the entire loan portfolio.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate_percentage
FROM bank_loan_data;


-- ------------------------------------------------------
-- KPI: Month-to-Date (MTD) Average Interest Rate
-- ASSUMPTION:
-- December 2021 is treated as the current reporting month.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(int_rate) * 100, 2) AS mtd_average_interest_rate_percentage
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';


-- ------------------------------------------------------
-- KPI: Previous Month-to-Date (PMTD) Average Interest Rate
-- Used for Month-over-Month comparison.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(int_rate) * 100, 2) AS pmtd_average_interest_rate_percentage
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';


-- ------------------------------------------------------
-- KPI: Month-over-Month (MoM) Change – Average Interest Rate
-- BUSINESS PURPOSE:
-- Measures change in average lending rates between
-- the current and previous month.
-- Expressed as percentage point difference.
-- ------------------------------------------------------
SELECT 
    ROUND(
        ((mtd_avg_rate - pmtd_avg_rate) / pmtd_avg_rate) * 100,
        2 
    ) AS mom_interest_rate_change_percentage
FROM (
    SELECT
        AVG(CASE 
                WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
                THEN int_rate * 100
            END) AS mtd_avg_rate,
        AVG(CASE 
                WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
                THEN int_rate * 100
            END) AS pmtd_avg_rate
    FROM bank_loan_data
) t;


-- ======================================================
-- OPTIONAL KPI: Weighted Average Interest Rate
-- BUSINESS PURPOSE:
-- Reflects the true portfolio-level interest rate by
-- weighting interest rates by loan amount.
-- More accurate indicator of revenue yield.
-- ======================================================
SELECT 
    ROUND(
        SUM(int_rate * loan_amount) / SUM(loan_amount) * 100,
        2
    ) AS weighted_avg_interest_rate_percentage
FROM bank_loan_data;



-- ======================================================
-- SECTION 8: AVERAGE DEBT-TO-INCOME (DTI) ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- Debt-to-Income (DTI) ratio measures a borrower’s
-- monthly debt obligations relative to income.
-- Lower DTI indicates better repayment capacity and
-- lower credit risk.
--
-- NOTE ON MTD / PMTD:
-- The dataset contains complete historical months (2021).
-- Therefore, MTD and PMTD represent full calendar months
-- for reporting consistency with Power BI.
-- ======================================================


-- ------------------------------------------------------
-- KPI: Overall Average DTI
-- BUSINESS PURPOSE:
-- Assesses overall borrower financial health
-- across the loan portfolio.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(dti) * 100, 2) AS average_dti_percentage
FROM bank_loan_data;


-- ------------------------------------------------------
-- KPI: Month-to-Date (MTD) Average DTI
-- ASSUMPTION:
-- December 2021 is treated as the current reporting month.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(dti) * 100, 2) AS mtd_average_dti_percentage
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31';


-- ------------------------------------------------------
-- KPI: Previous Month-to-Date (PMTD) Average DTI
-- Used for Month-over-Month comparison.
-- ------------------------------------------------------
SELECT 
    ROUND(AVG(dti) * 100, 2) AS pmtd_average_dti_percentage
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-11-01' AND '2021-11-30';


-- ------------------------------------------------------
-- KPI: Month-over-Month (MoM) Change – Average DTI
-- BUSINESS PURPOSE:
-- Measures change in borrower leverage and
-- repayment stress between consecutive months.
-- ------------------------------------------------------
SELECT 
    ROUND(
        ((mtd_avg_dti - pmtd_avg_dti) / pmtd_avg_dti) * 100,
        2
    ) AS mom_dti_change_percentage
FROM (
    SELECT
        AVG(CASE 
                WHEN issue_date BETWEEN '2021-12-01' AND '2021-12-31'
                THEN dti
            END) AS mtd_avg_dti,
        AVG(CASE 
                WHEN issue_date BETWEEN '2021-11-01' AND '2021-11-30'
                THEN dti
            END) AS pmtd_avg_dti
    FROM bank_loan_data
) t;



-- ======================================================
-- SECTION 9: GOOD LOAN ANALYSIS
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
-- SECTION 10: BAD LOAN ANALYSIS
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


-- ======================================================
-- SECTION 11: LOAN STATUS GRID VIEW
-- ======================================================
-- BUSINESS PURPOSE:
-- Provides a consolidated view of loan performance
-- by loan status.
-- Used in summary table visuals for portfolio monitoring.
-- ======================================================
SELECT
    loan_status,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount,
    SUM(total_payment) AS total_amount_received,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_percentage,
    ROUND(AVG(dti) * 100, 2) AS avg_dti_percentage
FROM bank_loan_data
GROUP BY loan_status;

-- ------------------------------------------------------
-- MTD Loan Status Summary
-- ASSUMPTION:
-- December 2021 is treated as the current month
-- based on dataset timeline.
-- ------------------------------------------------------
SELECT 
    loan_status,
    COUNT(id) AS mtd_loan_applications,
    SUM(loan_amount) AS mtd_total_funded_amount,
    SUM(total_payment) AS mtd_total_amount_received
FROM bank_loan_data
WHERE issue_date BETWEEN '2021-12-01' AND '2021-12-31'
GROUP BY loan_status;

-- ======================================================
-- SECTION 12: OVERVIEW DASHBOARD ANALYSIS
-- ======================================================
-- BUSINESS CONTEXT:
-- This section provides high-level aggregated views
-- used in the executive overview dashboard.
-- The queries support trend analysis, regional
-- performance comparison, and portfolio segmentation.
-- These visuals help leadership quickly assess
-- lending activity, funding levels, and cash inflows.
-- ======================================================


-- ------------------------------------------------------
-- VIEW: Monthly Lending & Collection Trend
-- BUSINESS PURPOSE:
-- Enables time-based trend analysis of loan applications,
-- capital deployment, and amount received.
-- Used for identifying seasonality and growth patterns.
-- ------------------------------------------------------
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



-- ------------------------------------------------------
-- VIEW: Loan Applications & Funding by Region
-- BUSINESS PURPOSE:
-- Compares lending activity and funded amounts
-- across different states.
-- Helps identify high-performing and underperforming
-- geographic regions.
-- ------------------------------------------------------
SELECT
    address_state,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY address_state;



-- ------------------------------------------------------
-- VIEW: Loan Applications & Funding by Loan Purpose
-- BUSINESS PURPOSE:
-- Analyzes customer borrowing intent by purpose.
-- Supports product strategy and risk segmentation.
-- ------------------------------------------------------
SELECT
    purpose,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY purpose;



-- ------------------------------------------------------
-- VIEW: Loan Applications & Funding by Loan Term
-- BUSINESS PURPOSE:
-- Evaluates customer preference for loan duration.
-- Helps assess exposure across short-term
-- and long-term lending products.
-- ------------------------------------------------------
SELECT
    term,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY term;



-- ------------------------------------------------------
-- VIEW: Employment Length Loan Analysis
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



-- ------------------------------------------------------
-- VIEW: Loan Applications & Funding by Home Ownership
-- BUSINESS PURPOSE:
-- Segments the loan portfolio by borrower
-- home ownership status.
-- Supports credit risk and demographic analysis.
-- ------------------------------------------------------
SELECT
    home_ownership,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount
FROM bank_loan_data
GROUP BY home_ownership;

