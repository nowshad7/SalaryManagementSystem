--------------------------------------------------------------------------------
-- PaySQL :: Package :: pkg_leave
-- Leave requests and the unpaid-days calculation that feeds loss-of-pay.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_leave AS
    -- Create a leave request (status PENDING). Returns the new id.
    FUNCTION apply_for_leave(
        p_employee_id   IN NUMBER,
        p_leave_code    IN VARCHAR2,
        p_start_date    IN DATE,
        p_end_date      IN DATE,
        p_days          IN NUMBER,
        p_reason        IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;

    -- Move a request to APPROVED / REJECTED / CANCELLED.
    PROCEDURE set_status(p_leave_request_id IN NUMBER, p_status IN VARCHAR2);

    -- Approved unpaid-leave days overlapping a pay period (drives loss-of-pay).
    FUNCTION unpaid_days(p_employee_id IN NUMBER, p_pay_period_id IN NUMBER) RETURN NUMBER;
END pkg_leave;
/

CREATE OR REPLACE PACKAGE BODY pkg_leave AS

    FUNCTION apply_for_leave(
        p_employee_id   IN NUMBER,
        p_leave_code    IN VARCHAR2,
        p_start_date    IN DATE,
        p_end_date      IN DATE,
        p_days          IN NUMBER,
        p_reason        IN VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS
        v_id            leave_request.leave_request_id%TYPE;
        v_leave_type_id leave_type.leave_type_id%TYPE;
    BEGIN
        SELECT leave_type_id INTO v_leave_type_id
        FROM   leave_type WHERE code = p_leave_code;

        INSERT INTO leave_request (employee_id, leave_type_id, start_date, end_date, days, status, reason)
        VALUES (p_employee_id, v_leave_type_id, p_start_date, p_end_date, p_days, 'PENDING', p_reason)
        RETURNING leave_request_id INTO v_id;

        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Unknown leave type code: ' || p_leave_code);
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_leave.apply_for_leave');
            RAISE;
    END apply_for_leave;

    PROCEDURE set_status(p_leave_request_id IN NUMBER, p_status IN VARCHAR2) IS
    BEGIN
        IF p_status NOT IN ('PENDING','APPROVED','REJECTED','CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20011, 'Invalid leave status: ' || p_status);
        END IF;

        UPDATE leave_request SET status = p_status
        WHERE  leave_request_id = p_leave_request_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Leave request not found: ' || p_leave_request_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_leave.set_status');
            RAISE;
    END set_status;

    FUNCTION unpaid_days(p_employee_id IN NUMBER, p_pay_period_id IN NUMBER) RETURN NUMBER IS
        v_days NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(lr.days), 0) INTO v_days
        FROM   leave_request lr
        JOIN   leave_type lt  ON lt.leave_type_id = lr.leave_type_id
        JOIN   pay_period pp  ON pp.pay_period_id = p_pay_period_id
        WHERE  lr.employee_id = p_employee_id
        AND    lr.status = 'APPROVED'
        AND    lt.is_paid = 0
        AND    lr.start_date <= pp.end_date
        AND    lr.end_date   >= pp.start_date;

        RETURN v_days;
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_leave.unpaid_days');
            RAISE;
    END unpaid_days;

END pkg_leave;
/
