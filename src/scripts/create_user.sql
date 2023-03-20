IF EXISTS(SELECT principal_id FROM sys.database_principals WHERE [name] = '$(username)')
    DROP USER $(username);

CREATE USER $(username) FOR LOGIN $(username);
EXEC sp_addrolemember 'db_owner', '$(username)';