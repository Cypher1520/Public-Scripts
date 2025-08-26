/*  SELECT Computers with apps installed */
	SELECT Distinct	SMS_R_System.Name, SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName
	FROM
		SMS_R_System INNER JOIN SMS_G_System_ADD_REMOVE_PROGRAMS ON SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId 
	WHERE 
		SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName LIKE "%Kingdom%"	


	SELECT SMS_R_User.FullUserName, SMS_R_System.Name, SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName FROM SMS_R_System INNER JOIN SMS_G_System_SYSTEM_CONSOLE_USAGE ON SMS_G_System_SYSTEM_CONSOLE_USAGE.ResourceId = SMS_R_System.ResourceId INNER JOIN SMS_R_User ON SMS_G_System_SYSTEM_CONSOLE_USAGE.TopCONsoleUser = SMS_R_User.UniqueUserName INNER JOIN SMS_G_System_ADD_REMOVE_PROGRAMS ON SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName LIKE "%Petrel%"

	select distinct SMS_R_System.Name, SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName from  SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like "%Petrel%"

/* SELECT Distinct */
	SELECT Distinct 
		SMS_R_System.Name
	FROM SMS_R_System 
		INNER JOIN SMS_AppDeploymentAssetDetails ON SMS_AppDeploymentAssetDetails.MachineID = SMS_R_System.ResourceId 
	WHERE 
		SMS_AppDeploymentAssetDetails.StatusType = "5" AND 
		SMS_AppDeploymentAssetDetails.Technology = "AppV5X" AND 
		SMS_R_System.OperatingSystemNameANDVersiON = "Microsoft Windows NT WorkstatiON 10.0" AND 
		SMS_AppDeploymentAssetDetails.EnforcementState = "5001"

/* Query Primary user of device with full username */
	SELECT
		SMS_R_User.FullUserName, SMS_R_System.Name
	FROM SMS_R_System 
		INNER JOIN SMS_G_System_SYSTEM_CONSOLE_USAGE ON SMS_G_System_SYSTEM_CONSOLE_USAGE.ResourceId = SMS_R_System.ResourceId
		INNER JOIN SMS_R_User ON SMS_G_System_SYSTEM_CONSOLE_USAGE.TopCONsoleUser = SMS_R_User.UniqueUserName

/* SELECT computers part of AD group */
	SELECT 
		SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client 
	FROM 
		SMS_R_System 
	WHERE 
		SMS_R_System.SystemGroupName = "COMPANY\\G CGY Geox Computers"

/* SELECT computers part of AD group */
SELECT sr.* FROM SMS_R_System as sr join SMS_G_System_WINDOWSUPDATE as su on sr.ResourceID=su.ResourceID WHERE su.UseWUServer is null

/*laptop*/
select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ( “8”, “9”, “10”, “14” )