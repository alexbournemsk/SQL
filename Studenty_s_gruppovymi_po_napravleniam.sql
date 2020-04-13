-- Чтобы задать дату, напишите её в одинарных кавычках в следующем виде: '1993-12-31 13:00:00.000'
DECLARE @fromDate DATETIME = '2019-06-01 00:00:00.000' -- Нижняя граница даты последнего посещения студента
DECLARE @toDate DATETIME = '2019-12-01 00:00:00.000' -- Верхняя граница даты последнего посещения студента

SELECT
	[s].*
FROM
	(
		SELECT
			[s].*,
			(
				SELECT TOP 1
					[ev2].[StartsAt]
				FROM
					[CourseTimeline].[EventRecord] [evr2]
					INNER JOIN [CourseTimeline].[Event] [ev2]
						ON [ev2].[Id] = [evr2].[EventId]
					INNER JOIN [CourseTimeline].[EventType] [et2]
						ON [et2].[Id] = [ev2].[EventTypeId]
				WHERE
					[evr2].[StudentId] = [s].[Id]
					AND [evr2].[RecordStatus] = 1 -- Посещён
					AND [et2].[CategoryId] NOT IN ('00000000-0000-0000-0000-000000000003', 'A4DE0675-4454-49A1-A51E-EC0010A5E31C', 'AE784CF0-A99F-4F52-B8CE-B5A67BF4CA1A') -- Бесплатные МК, Бесплатные групповые, Платные промо
				ORDER BY
					[ev2].[StartsAt] DESC
			) as [LastVisitDate],
			(
				SELECT TOP 1
					[subj].[Name]
				FROM
					[CourseTimeline].[EventRecord] [evr3]
					INNER JOIN [CourseTimeline].[Event] [ev3]
						ON [ev3].[Id] = [evr3].[EventId]
					INNER JOIN [CourseTimeline].[EventType] [et3]
						ON [et3].[Id] = [ev3].[EventTypeId]
					INNER JOIN [CourseTimeline].[Subject] [subj]
						ON [subj].[Id] = [et3].[SubjectId]
				WHERE
					[evr3].[StudentId] = [s].[Id]
					AND [evr3].[RecordStatus] = 1 -- Посещён
					AND [et3].[CategoryId] NOT IN ('00000000-0000-0000-0000-000000000003', 'A4DE0675-4454-49A1-A51E-EC0010A5E31C', 'AE784CF0-A99F-4F52-B8CE-B5A67BF4CA1A') -- Бесплатные МК, Бесплатные групповые, Платные промо
				ORDER BY
					(CASE [subj].[Name] WHEN 'Гитара' THEN 1 ELSE 0 END) DESC
			) as [SubjectName],
			[CourseTimeline].[GetStudentBranchName]([s].[BranchIds]) as [Branch]
		FROM
			(
				SELECT
					[s1].[Id]
				FROM [CourseTimeline].[Student] [s1]
					INNER JOIN [CourseTimeline].[EventRecord] [evr1]
						ON [evr1].[StudentId] = [s1].[Id]
					INNER JOIN [CourseTimeline].[Event] [ev1]
						ON [ev1].[Id] = [evr1].[EventId]
					INNER JOIN [CourseTimeline].[EventType] [et1]
						ON [et1].[Id] = [ev1].[EventTypeId]
				WHERE
					[et1].[CategoryId] NOT IN ('00000000-0000-0000-0000-000000000003', 'A4DE0675-4454-49A1-A51E-EC0010A5E31C', 'AE784CF0-A99F-4F52-B8CE-B5A67BF4CA1A') -- Бесплатные МК, Бесплатные групповые, Платные промо
				GROUP BY
					[s1].[Id]
			) [studentIds]
			INNER JOIN [CourseTimeline].[Student] [s]
				ON [s].[Id] = [studentIds].[Id]
	) [s]
WHERE
	[s].[LastVisitDate] IS NOT NULL
	AND (@fromDate IS NULL OR [s].[LastVisitDate] >= @fromDate)
	AND (@toDate IS NULL OR [s].[LastVisitDate] <= @toDate)
ORDER BY
	[s].[LastVisitDate] DESC