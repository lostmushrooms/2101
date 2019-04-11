--Query 1
with CTRatingsRounded as (
	select username as ctname, round(rating, 1) as rounded_rating
	from UserRating
	where is_owner = false
),
	RatingGroups as (
	select generate_series(1,5,0.1) as rounded_rating
)	
select rounded_rating as rating, avg(bidded_price_per_hour) as avg_bidded_price_per_hour
from RatingGroups natural left join ((Bids B join Availabilities A on B.availabilityId = A.id) natural join CTRatingsRounded)
group by rounded_rating
order by rounded_rating
;

--Query 2
with ORatingsRounded as (
	select username as oname, round(rating, 1) as rounded_rating
	from UserRating
	where is_owner = true
),	
	RatingGroups as (
	select generate_series(1,5,0.1) as rounded_rating
)		
select rounded_rating as rating, case 
	when count(B.id)>0 then cast(count(AB.id) as numeric)/count(B.id)
	else null 
	end as prop_accepted_bids
from RatingGroups natural left join ((Bids B left join AcceptedBids AB on B.id = AB.id) natural join ORatingsRounded)
group by rounded_rating
order by rounded_rating
;


--Query 3
with AvailabilitiesWithNumBids as (
	select ctname, (end_date - start_date + 1) as interval_length_in_days, (
		select count(*)
		from Bids
		where availabilityId = A.id
	) as num_bids
	from Availabilities A
)
select username, sum(interval_length_in_days) as total_days, case
	when count(interval_length_in_days) > 0 then sum(num_bids)/sum(interval_length_in_days)
	else NULL
	end as num_bids_per_day
from Caretakers CT left join AvailabilitiesWithNumBids A on CT.username = A.ctname
group by username
order by sum(interval_length_in_days) desc
;