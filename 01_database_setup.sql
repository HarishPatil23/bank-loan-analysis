/* =============================================================================
   FILE: 01_database_setup.sql
   PURPOSE:
   --------
   Creates the database and core table structure for the
   Bank Loan Analysis project.

   BUSINESS CONTEXT:
   -----------------
   Each row represents a single loan issued to a borrower.
   This structure supports loan-level KPI analysis.
============================================================================= */

DROP DATABASE IF EXISTS bankloan_db;
CREATE DATABASE bankloan_db;
USE bankloan_db;

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
    sub_grade               CHAR(3),
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
