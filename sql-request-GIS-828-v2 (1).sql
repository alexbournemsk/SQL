-- „тобы задать дату, напишите еЄ в одинарных кавычках в следующем виде: '1993-12-31 13:00:00.000'
DECLARE @fromDate DATETIME = '2019-06-01 00:00:00.000' -- Ќижн€€ граница даты последнего посещени€ студента
DECLARE @toDate DATETIME = '2019-12-01 00:00:00.000' -- ¬ерхн€€ граница даты последнего посещени€ студента

DROP TABLE IF EXISTS #t1
SELECT [e].[CourseId], min([e].[StartsAt]) [firstEventOfCourseInPeriod], [rec].[StudentId]
INTO #t1
FROM [CourseTimeline].[EventRecord] [rec]
JOIN [CourseTimeline].[Event] [e] ON [e].[Id] = [rec].[EventId]
inner JOIN [CourseTimeline].[EventType] [et] ON [et].[Id] = [e].[EventTypeId]
inner JOIN [CourseTimeline].[EventCategory] [ec] ON [ec].[Id] = [et].[CategoryId]
WHERE [rec].[RecordStatus] = 1
  and [e].[StartsAt] >= @fromDate
  and [e].[StartsAt] <= @toDate
  and [ec].IsPromo = 0
GROUP BY [e].[CourseId], [rec].[StudentId]


DROP TABLE IF EXISTS #t2
SELECT [e].[CourseId], min([e].[StartsAt]) [realFirstEventOfCourse], [rec].[StudentId]
INTO #t2
FROM #t1 t
JOIN [CourseTimeline].[Event] [e] ON [e].[CourseId] = t.[CourseId]
join [CourseTimeline].[EventRecord] [rec] on rec.[EventId] = e.id and rec.[StudentId] = t.[StudentId]
WHERE [rec].[RecordStatus] = 1
GROUP BY [e].[CourseId], [rec].[StudentId]

SELECT subj.[Name], et.[Name], s.[FullName], s.[PhoneNumber], s.[Email], s.[CreatedAt], t1.[firstEventOfCourseInPeriod], t2.[realFirstEventOfCourse],
[CourseTimeline].[GetStudentBranchName]([s].[BranchIds]) as [Branch]
FROM #t1 t1
join #t2 t2 on t1.[CourseId] = t2.[CourseId] and t1.[StudentId] = t2.[StudentId]
inner join [CourseTimeline].[Student] [s] on t1.StudentId = s.Id
inner join [CourseTimeline].[Course] [c] on t1.CourseId = c.Id
inner join [CourseTimeline].[EventType] [et] on et.Id = c.CourseTypeId
inner join [CourseTimeline].[Subject] [subj] on subj.Id = et.SubjectId
where 1=1
  and t2.[realFirstEventOfCourse] >= @fromDate
  and t2.[realFirstEventOfCourse] <= @toDate

DROP TABLE IF EXISTS #t1
DROP TABLE IF EXISTS #t2