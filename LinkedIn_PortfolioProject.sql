/*
LinkedIn data onderzoek
Vaardigheden: joins, filtring functions, aggregate functions, sorting/grouping functions, case statements, partition by
*/

--LinkedIn data Talent&Pro gefocust op bezorging
SELECT *
FROM LinkedIn_Bezorging

--LinkedIn data Talent&Pro gefocust op prestaties
SELECT * 
FROM LinkedIn_Prestaties

--Totale uitgaven en gemiddlede uitgaven per campagne op LinkedIn 
SELECT SUM([Total Spent]) AS [Totale uitgaven LinkedIn], AVG([Total Spent]) AS [Gemiddelde uitgaven LinkedIn campagne], SUM([Impressions]) AS [Totale weergaven], AVG([Impressions])AS [Gemiddelde weergaven]
FROM LinkedIn_Prestaties

--Beste CTR i.c.m. weergaven en kosten
SELECT [Campaign ID], [Ad ID], [Click Through Rate] * 100 AS [CTR percentage], Impressions, [Total Spent]
FROM LinkedIn_Prestaties
WHERE [Click Through Rate] > 0
ORDER BY 3 DESC

--Beste CPM i.c.m. weergaven en kosten
SELECT [Campaign ID], [Ad ID], [Average CPM], Impressions, [Total Spent]
FROM LinkedIn_Prestaties
WHERE [Average CPM] > 0
ORDER BY 3

--Beste CPC i.c.m. weergaven en kosten
SELECT [Campaign ID], [Ad ID], [Average CPC], Impressions, [Total Spent]
FROM LinkedIn_Prestaties
WHERE [Average CPC] > 0
ORDER BY 3

--Beoordeling van CTR t.o.v. de benchmark
SELECT [Campaign ID], [Ad ID], [Click Through Rate]*100 AS [CTR percentage], Impressions, [Total Spent],
CASE
	WHEN [Click Through Rate]*100 > 0.4 THEN 'GOED'
	ELSE 'SLECHT'
END AS [CTR kwaliteit t.o.v. benchmark]
FROM LinkedIn_Prestaties
WHERE [Click Through Rate]*100 > 0
ORDER BY 3 DESC

--Beoordeling van CPC t.o.v. de benchmark
SELECT [Campaign ID], [Ad ID], [Average CPC], Impressions, [Total Spent],
CASE
	WHEN [Average CPC] < 3 THEN 'ZEER GOED'
	WHEN ([Average CPC] >=3) AND ([Average CPC] <10)  THEN 'GOED'
	ELSE 'SLECHT'
END AS [CPC kwaliteit t.o.v. benchmark]
FROM LinkedIn_Prestaties
WHERE [Average CPC] > 0
ORDER BY 3

--Gemiddelde CPM vs. Kosten per 1000 bereikte mensen
SELECT LinkedIn_Prestaties.[Ad ID], [Average CPM], [Cost per 1,000 People Reached], ([Cost per 1,000 People Reached]-[Average CPM]) AS [Verschil CPM en Cost per 1000]
FROM LinkedIn_Prestaties
JOIN LinkedIn_Bezorging
	ON LinkedIn_Prestaties.[Ad ID]=LinkedIn_Bezorging.[Ad ID]
WHERE [Average CPM] > 0
ORDER BY 4 DESC

--Advertenties met de hoogste totale kosten
SELECT [Campaign ID], [Ad ID], [Total Spent]
FROM LinkedIn_Prestaties
GROUP BY [Campaign ID], [Ad ID], [Total Spent]
HAVING MAX([Total Spent]) > 1000

--Totale uitgaven per campagne gesorteerd van hoog naar laag
SELECT [Campaign ID], [Total Spent], 
SUM([Total Spent]) OVER (PARTITION BY [Campaign ID]) AS [Totale uitgaven per campagne]
FROM LinkedIn_Prestaties
ORDER BY [Totale uitgaven per campagne] DESC
