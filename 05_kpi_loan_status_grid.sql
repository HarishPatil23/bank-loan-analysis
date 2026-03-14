/* =============================================================================
   FILE: 05_kpi_loan_status_grid.sql
   PURPOSE:
   --------
   Provides a consolidated loan performance view
   grouped by loan status.
============================================================================= */

USE bankloan_db;

SELECT
    loan_status,
    COUNT(id) AS total_loan_applications,
    SUM(loan_amount) AS total_funded_amount,
    SUM(total_payment) AS total_amount_received,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct,
    ROUND(AVG(dti) * 100, 2) AS avg_dti_pct
FROM bank_loan_data
GROUP BY loan_status;
