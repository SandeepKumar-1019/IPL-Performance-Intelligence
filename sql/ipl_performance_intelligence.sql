select count(*)
from ipl_ball_by_ball;

-- Question 1: View the first 5 rows
select *
from ipl_ball_by_ball
limit 5;

-- Question 2: Count unique matches
select count(distinct match_id) as total_matches
from ipl_ball_by_ball;

-- Question 3: View all unique seasons
select distinct season
from ipl_ball_by_ball
order by season;

-- Question 4: Count matches in each season
select season, count(distinct match_id) as matches_played
from ipl_ball_by_ball 
group by season
order by season;

-- Question 5: Count matches played in the 2026 season
select count(distinct match_id) as matches_played_2026
from ipl_ball_by_ball 
where season = '2026';

-- Question 6: View all unique batting teams
select distinct batting_team
from ipl_ball_by_ball
order by batting_team;

-- Question 7: Matches played by each team
select batting_team, count(distinct match_id) as matches_played
from ipl_ball_by_ball
group by batting_team
order by matches_played desc;

-- Question 8: Matches hosted at each venue
select venue, count(distinct match_id) as matches_hosted
from ipl_ball_by_ball
group by venue
order by matches_hosted desc;

-- Question 8.1: Top 10 venues
select venue, count(distinct match_id) as matches_hosted
from ipl_ball_by_ball 
group by venue
order by matches_hosted desc
limit 10;

-- Question 9: Top 10 run scorers
select batter, sum(runs_batter) as runs_scored
from ipl_ball_by_ball
group by batter
order by runs_scored desc
limit 10;

-- Question 10: Top 10 batters with the most sixes
select batter, sum(is_six) as max_sixes
from ipl_ball_by_ball
group by batter
order by max_sixes desc
limit 10;

-- Question 10.1: Top 10 batters with the most sixes in 2026
select batter, sum(is_six) as max_sixes
from ipl_ball_by_ball
where season = '2026'
group by batter
order by max_sixes desc
limit 10;

-- Question 11: Top 10 batters with the most fours
select batter, sum(is_four) as max_fours
from ipl_ball_by_ball 
group by batter
order by max_fours desc
limit 10;

-- Question 11.1: Top 10 batters with the most fours in 2026
select batter, sum(is_four) as max_fours
from ipl_ball_by_ball 
where season = '2026'
group by batter
order by max_fours desc

-- Question 12: Top 10 wicket takers
select bowler, sum(bowler_wicket) as total_wickets
from ipl_ball_by_ball
group by bowler
order by total_wickets desc
limit 10;

-- Question 12.1: Top 10 wicket takers in 2026
select bowler, sum(bowler_wicket) as total_wickets
from ipl_ball_by_ball
where season = '2026'
group by bowler
order by total_wickets desc
limit 10;

-- Question 13: Top 10 bowlers with the most dot balls
select bowler, sum(is_dot_ball) as total_dot_balls
from ipl_ball_by_ball
group by bowler
order by total_dot_balls desc
limit 10;

-- Question 13.1: Top 10 bowlers with the most dot balls in 2026
select bowler, sum(is_dot_ball) as total_dot_balls
from ipl_ball_by_ball
where season = '2026'
group by bowler
order by total_dot_balls desc
limit 10;

-- Question 14: Top 10 bowlers by runs conceded
select bowler, sum(runs_bowler) as total_runs
from ipl_ball_by_ball
group by bowler
order by total_runs desc
limit 10;

-- Question 14.1: Top 10 bowlers by runs conceded in 2026
select bowler, sum(runs_bowler) as total_runs
from ipl_ball_by_ball
where season = '2026'
group by bowler
order by total_runs desc
limit 10;

-- Question 15: Top 10 batters by strike rate
-- Minimum 500 valid balls faced
select batter, 
round(
	(sum(runs_batter) * 100.0/ count(*) filter (where valid_ball = 1)),2
	)as strike_rate
from ipl_ball_by_ball
group by batter
having count(*) filter (where valid_ball = 1) >=500
order by strike_rate desc
limit 10;

-- Question 15.1: Top 10 batters by strike rate in 2026
-- Minimum 100 valid balls faced
select batter, 
round(
sum(runs_batter)*100.0/count(*) filter (where valid_ball = 1),2) as strike_rate
from ipl_ball_by_ball
where season = '2026'
group by batter
having count(*) filter (where valid_ball = 1) >= 100
order by strike_rate desc
limit 10;

-- Question 16: Top 10 bowlers with highest wickets in 2024
-- Minimum 20 matches played
select bowler,
count(distinct match_id) as total_matches,
count(*) filter (where bowler_wicket = 1) as total_wickets
from ipl_ball_by_ball
where season = '2024'
group by bowler
having count(distinct match_id) >= 10
order by total_wickets desc
limit 10;

-- Question 17: Top bowlers by average wickets per match
-- Minimum 20 matches played
select bowler,
count(*) filter (where bowler_wicket = 1) as total_wickets,
count(distinct match_id) as total_matches,
round(
count(*) filter (where bowler_wicket = 1) * 1.0 / count(distinct match_id), 2
) as avg_wicket_per_match
from ipl_ball_by_ball
group by bowler
having count(distinct match_id) >= 20
order by avg_wicket_per_match desc
limit 10;

-- Question 18: Top 10 highest team innings scores
select batting_team, season, max(team_runs) as total_runs
from ipl_ball_by_ball
group by
batting_team,match_id,innings,season
order by total_runs desc
limit 10;

--check
select distinct match_won_by
from ipl_ball_by_ball
order by match_won_by

-- Question 19: Wins While Chasing vs Defending
select batting_team,
count(distinct case
when batting_team = match_won_by and is_chasing = 1 then match_id end) as chasing_wins,
count(distinct case
when batting_team = match_won_by and is_chasing = 0 then match_id end) as defending_wins
from ipl_ball_by_ball
where match_won_by <> 'Unknown'
group by batting_team
order by chasing_wins desc;

-- Question 19: Average team innings score by season
select season, round(avg(total_runs),2) as avg_team_score
from(
select match_id, season, innings, max(team_runs) as total_runs
from ipl_ball_by_ball
group by match_id, season, innings
) 
group by season
order by season;

--Question 20: Which batters have scored more total runs than the average total runs scored by all batters?
select batter, sum(runs_batter) as total_runs
from ipl_ball_by_ball
group by batter
having sum(runs_batter)>(
select avg(batters_total) as avg_total_batters
from(
select sum(runs_batter) as batters_total
from ipl_ball_by_ball
group by batter
)
)
order by total_runs desc;

--Question 21: 20 with CTE
with batter_totals as(
	select batter,sum(runs_batter) as total_runs
	from ipl_ball_by_ball
	group by batter
),
	avg_batter as(
	select avg(total_runs) as avg_total_runs
	from batter_totals
	)
select batter, total_runs
from batter_totals
where total_runs > (
	select avg_total_runs
	from avg_batter
)
order by total_runs desc;
