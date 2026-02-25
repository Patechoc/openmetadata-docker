-- =============================================================
-- OpenMetadata - PostgreSQL Initialization Script
-- =============================================================
-- This script runs automatically on the FIRST startup of the
-- postgres container (when the data volume is empty).
-- It is mounted into /docker-entrypoint-initdb.d/ in the container.
--
-- The postgres image already creates the user and database via
-- POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB env vars.
-- This script adds the extra schema grants required by
-- PostgreSQL 15+ (where public schema is no longer world-writable).
-- =============================================================

-- Grant schema-level permissions (required on PostgreSQL 15+)
GRANT USAGE  ON SCHEMA public TO openmetadata_user;
GRANT CREATE ON SCHEMA public TO openmetadata_user;
