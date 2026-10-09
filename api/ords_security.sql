--------------------------------------------------------------------------------
-- PaySQL :: ORDS :: API protection (roles + privilege)
--
-- Run as the PAYSQL user after ords_modules.sql. Creates ORDS roles and a
-- privilege that protects the /v1/ module, so callers must authenticate (via an
-- OAuth2 client) and hold an appropriate role.
--
-- NOTE: ORDS.DEFINE_PRIVILEGE below uses APEX collection types
-- (apex_t_varchar2). If APEX is not installed, protect the module from SQL
-- Developer Web / Database Actions (REST > Security) or the ORDS CLI instead.
-- Treat this as a template to adapt to your ORDS version and auth setup.
--------------------------------------------------------------------------------
BEGIN
    ORDS.CREATE_ROLE(p_role_name => 'PaySQL HR');
    ORDS.CREATE_ROLE(p_role_name => 'PaySQL Accountant');
    ORDS.CREATE_ROLE(p_role_name => 'PaySQL Employee');
    ORDS.CREATE_ROLE(p_role_name => 'PaySQL Auditor');

    ORDS.DEFINE_PRIVILEGE(
        p_privilege_name => 'paysql.api',
        p_roles          => apex_t_varchar2('PaySQL HR', 'PaySQL Accountant',
                                            'PaySQL Employee', 'PaySQL Auditor'),
        p_patterns       => apex_t_varchar2('/v1/*'),
        p_modules        => apex_t_varchar2('paysql.v1'),
        p_label          => 'PaySQL API',
        p_description     => 'Access to the PaySQL REST API');

    COMMIT;
END;
/

-- After this, register an OAuth2 client and grant it the relevant role, e.g.:
--
--   BEGIN
--     OAUTH.CREATE_CLIENT(
--       p_name            => 'paysql-accountant-app',
--       p_grant_type      => 'client_credentials',
--       p_privilege_names => 'paysql.api',
--       p_support_email   => 'admin@example.com');
--     OAUTH.GRANT_CLIENT_ROLE('paysql-accountant-app', 'PaySQL Accountant');
--     COMMIT;
--   END;
--   /
--
-- Then obtain a token from /ords/paysql/oauth/token and send it as
--   Authorization: Bearer <token>
