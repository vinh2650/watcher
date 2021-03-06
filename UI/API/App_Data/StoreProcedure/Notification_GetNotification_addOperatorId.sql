USE [amssystemondemand]
GO
/****** Object:  StoredProcedure [dbo].[Notification_GetNotificationTest]    Script Date: 7/26/2016 2:07:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Notification_GetNotification]
	@linkId nvarchar(128),
	@type int,
	@onwerId nvarchar(128),
	@operatorId NVARCHAR(128),
	@createdDateUtc datetime,
	@skip int,
	@take int
as
begin
	--validate
	if @linkId is null or @type is null
		return;

	if @skip is null and @take is null and @createdDateUtc is null
		return;			

	--get by created date
	if @createdDateUtc is not null
	begin
		;with paging as (
		SELECT [Id],[OwnerId],[OperatorId],[Content],[CreatedDateUtc],[UpdatedDateUtc],[Subject],[AttachmentList]
		FROM [dbo].[Notification]
		WHERE [LinkId] = @linkId and [Type] = @type
		and ((@onwerId is not null and OwnerId = @onwerId) or (@onwerId is null))
		and ((@operatorId is not null and OperatorId = @operatorId) or (@operatorId is null))
		and CreatedDateUtc > @createdDateUtc)

		SELECT 	x.[Id],x.[OwnerId],x.[OperatorId],x.[Content],x.[CreatedDateUtc],x.[Subject],x.[AttachmentList], 
		(select count(*) from Notificationcomment p where NotificationId = x.Id) as Total, (u.FirstName + ' ' + u.LastName) as Author,(SELECT COUNT_BIG(*) FROM paging)  AS RowCounts
		FROM paging x join [User] u on u.Id = x.OwnerId
		ORDER BY CreatedDateUtc Desc

		return;
	end	

	--get by skip and take
	if @skip is not null and @take is not null
	BEGIN
    
		;with paging as (
		SELECT [Id],[OwnerId],[OperatorId],[Content],[CreatedDateUtc],[UpdatedDateUtc],[Subject],[AttachmentList]
		FROM [dbo].[Notification]
		WHERE [LinkId] = @linkId and [Type] = @type
		and ((@onwerId is not null and OwnerId = @onwerId) or (@onwerId is null))
		and ((@operatorId is not null and OperatorId = @operatorId) or (@operatorId is null)))
		
		SELECT 	x.[Id],x.[OwnerId],x.OperatorId,x.[Content],x.[CreatedDateUtc],x.[Subject],x.[AttachmentList], 
		(select count(*) from Notificationcomment p where NotificationId = x.Id) as Total, (u.FirstName + ' ' + u.LastName) as Author,(SELECT COUNT_BIG(*) FROM paging)  AS RowCounts
		FROM paging x join [User] u on u.Id = x.OwnerId
		ORDER BY CreatedDateUtc Desc
		OFFSET @skip ROWS
		FETCH NEXT @take ROWS ONLY;
		return;
	end
end
