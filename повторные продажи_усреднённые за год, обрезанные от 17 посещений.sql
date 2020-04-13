select visited.tn 'Педагог', visited.students 'Ходили (> 16ур)', upsaled.students 'Продлили', (upsaled.students * 100 / visited.students) as 'Конверсия, %'
from (
select ts.tn, count(distinct ts.sid) students
from TeacherStudentLastYear ts
where ts.qty > 16
group by ts.tn
) visited
left join (
select ts.tn, count(distinct deal.StudentId) students
from dbo.PaidDeals deal
join CourseTimeline.Branch branch on deal.BranchId = branch.Id
join dbo.TeacherStudentLastYear ts on ts.sid = deal.StudentId
where
--not (ts.tn = N'Алена Гаврилова' and branch.Name = N'Москва-Цветной бульвар')
deal.CreatedAt between dateadd(year, -1, getdate()) and getdate()
and deal.Amount > 0
and deal.CategoryId in ('00000000-0000-0000-0000-000000000001', '6A84E095-9EB9-4CFC-AD49-06E7D0CD8131',
5DA4F7B7-6662-4FD8-A962-80C9B15A02F3')
and branch.IsCrown = 1
and exists(select Id
from dbo.PaidDeals prevDeal
where prevDeal.StudentId = deal.StudentId and prevDeal.CreatedAt < deal.CreatedAt)
and ts.qty > 16
group by ts.tn
) upsaled on visited.tn = upsaled.tn
order by (upsaled.students * 100 / visited.students) desc, visited.students desc
