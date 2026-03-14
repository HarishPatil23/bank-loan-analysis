/* =============================================================================
   FILE: 02_data_ingestion.sql
   PURPOSE:
   --------
   Loads raw CSV loan data into MySQL and
   standardizes date formats.

   DATA QUALITY NOTES:
   -------------------
   • Empty date values handled using NULLIF
   • CSV date format: DD-MM-YYYY
============================================================================= */

USE bankloan_db;

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
