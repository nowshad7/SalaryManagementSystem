--------------------------------------------------------------------------------
-- PaySQL :: Package :: pkg_tax
-- Progressive tax calculation driven by the tax_slab table (config, not code).
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_tax AS
    -- Tax on a taxable amount for a country, using slabs effective on a date.
    FUNCTION calc_tax(
        p_taxable  IN NUMBER,
        p_country  IN VARCHAR2 DEFAULT 'US',
        p_as_of    IN DATE     DEFAULT SYSDATE
    ) RETURN NUMBER;
END pkg_tax;
/

CREATE OR REPLACE PACKAGE BODY pkg_tax AS
    FUNCTION calc_tax(
        p_taxable  IN NUMBER,
        p_country  IN VARCHAR2 DEFAULT 'US',
        p_as_of    IN DATE     DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_tax   NUMBER := 0;
        v_upper NUMBER;
    BEGIN
        IF p_taxable IS NULL OR p_taxable <= 0 THEN
            RETURN 0;
        END IF;

        FOR r IN (
            SELECT lower_bound, upper_bound, rate
            FROM   tax_slab
            WHERE  country_code = p_country
            AND    p_as_of >= effective_from
            AND    (effective_to IS NULL OR p_as_of <= effective_to)
            ORDER  BY lower_bound
        ) LOOP
            IF p_taxable > r.lower_bound THEN
                v_upper := LEAST(p_taxable, NVL(r.upper_bound, p_taxable));
                v_tax   := v_tax + (v_upper - r.lower_bound) * r.rate;
            END IF;
        END LOOP;

        RETURN ROUND(v_tax, 2);
    EXCEPTION
        WHEN OTHERS THEN
            pkg_error.log_error('pkg_tax.calc_tax');
            RAISE;
    END calc_tax;
END pkg_tax;
/
