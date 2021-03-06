-- Чтобы задать дату, напишите её в одинарных кавычках в следующем виде: '1993-12-31 13:00:00.000'
DECLARE @fromDate DATETIME = '2020-03-09 00:00:00.000' -- Нижняя граница даты регистрации студента
DECLARE @toDate DATETIME = '2020-03-12 23:59:00.000' -- Верхняя граница даты регистрации студента
DECLARE @subjectName NVARCHAR(max) = null -- Направление пробного

SELECT
	[s].*,
	[studentIds].[Name] as [SubjectName],
	[CourseTimeline].[GetStudentBranchName]([s].[BranchIds]) as [Branch],
	[CourseTimeline].[GetStudentStageString]([ss].[Stage]) as [Stage]
FROM
	(
		SELECT
			[s1].[Id],
			[subj].[Name]
		FROM [CourseTimeline].[Student] [s1]
			INNER JOIN [CourseTimeline].[EventRecord] [evr1]
				ON [evr1].[StudentId] = [s1].[Id]
			INNER JOIN [CourseTimeline].[Event] [ev1]
				ON [ev1].[Id] = [evr1].[EventId]
			INNER JOIN [CourseTimeline].[EventType] [et1]
				ON [et1].[Id] = [ev1].[EventTypeId]
			INNER JOIN [CourseTimeline].[Subject] [subj]
				ON [subj].[Id] = [et1].[SubjectId]
		WHERE
			[et1].[CategoryId] IN ('00000000-0000-0000-0000-000000000003', 'A4DE0675-4454-49A1-A51E-EC0010A5E31C', 'AE784CF0-A99F-4F52-B8CE-B5A67BF4CA1A') -- Бесплатные МК, Бесплатные групповые, Платные промо
			AND (@fromDate IS NULL OR [s1].[CreatedAt] >= @fromDate)
			AND (@toDate IS NULL OR [s1].[CreatedAt] <= @toDate)
			AND (@subjectName IS NULL OR [subj].[Name] = @subjectName)
		GROUP BY
			[s1].[Id],
			[subj].[Name]
	) [studentIds]
	INNER JOIN [CourseTimeline].[Student] [s]
		ON [s].[Id] = [studentIds].[Id]
	LEFT JOIN [CourseTimeline].[StudentStage] [ss]
		ON [s].[Id] = [ss].[StudentId]
WHERE
	NOT EXISTS
	(
		SELECT
			TOP 1 *
		FROM [CourseTimeline].[EventRecord] [evr2]
		INNER JOIN [CourseTimeline].[Event] [ev2]
			ON [ev2].[Id] = [evr2].[EventId]
		INNER JOIN [CourseTimeline].[EventType] [et2]
			ON [et2].[Id] = [ev2].[EventTypeId]
	WHERE
		[et2].[CategoryId] NOT IN ('00000000-0000-0000-0000-000000000003', 'A4DE0675-4454-49A1-A51E-EC0010A5E31C', 'AE784CF0-A99F-4F52-B8CE-B5A67BF4CA1A') -- Бесплатные МК, Бесплатные групповые, Платные промо
		AND [evr2].[StudentId] = [studentIds].[Id]
	)
ORDER BY
	[s].[CreatedAt] DESC