--------------------------------------------------------------------------------
-- PaySQL :: Package :: pkg_error
-- Central error logging. Writes to error_log in an autonomous transaction so the
-- record survives a rollback of the failing business transaction.
-- Replaces the old 'Something wrong happened' handlers.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_error AS
    -- Log the current exception (call from an EXCEPTION block), then the caller re-raises.
    PROCEDURE log_error(p_module IN VARCHAR2 DEFAULT NULL);
END pkg_error;
/

CREATE OR REPLACE PACKAGE BODY pkg_error AS
    PROCEDURE log_error(p_module IN VARCHAR2 DEFAULT NULL) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO error_log (error_code, error_message, backtrace, module)
        VALUES (SQLCODE,
                SUBSTR(SQLERRM, 1, 4000),
                DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                p_module);
        COMMIT;
    END log_error;
END pkg_error;
/
