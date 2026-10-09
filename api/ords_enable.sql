--------------------------------------------------------------------------------
-- PaySQL :: ORDS :: Enable the schema for REST
--
-- Run as the PAYSQL user in a database where Oracle REST Data Services (ORDS)
-- is installed. Exposes the schema under the base path /paysql/ .
--
-- Prerequisite: ORDS installed, and the PAYSQL user granted the ability to
-- REST-enable its schema (e.g. GRANT CONNECT to a REST-enabled user, or
-- ORDS_ADMIN.ENABLE_SCHEMA run by an admin).
--------------------------------------------------------------------------------
BEGIN
    ORDS.ENABLE_SCHEMA(
        p_enabled             => TRUE,
        p_schema              => 'PAYSQL',
        p_url_mapping_type    => 'BASE_PATH',
        p_url_mapping_pattern => 'paysql',
        p_auto_rest_auth      => TRUE   -- require authentication for the API
    );
    COMMIT;
END;
/
