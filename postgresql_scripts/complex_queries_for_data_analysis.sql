/*Question: How does the caretaker's rating affect the bidding prices of bids on his availabilities?
The following query finds the average bidded price per hour for each caretaker rating group, where the caretakers are grouped by their average rating (rounded to 0.1).
If there is no caretaker with a particular rating group, average bidded price per hour value for that group is NULL.
 */
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

/*Question: How does the owner's rating affect the rate at which his bids are accepted?
The following query finds the proportion of bids accepted for each owner rating group, where the owners are grouped by their average rating (rounded to 0.1).
If there are no bids from owners with a particular rating group, proportion of accepted bids for that group is NULL.
 */
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


/*Question: How does frequency of a caretaker's availability affect his popularity? 
If the frequency of a caretaker's availability is independent to his popularity, one might expect that after adjusting for caretaker ratings and other potential confounders,
for any given caretaker, the ratio of the number of bids placed to that caretaker over the total time length of their availabilities, would be roughly constant.
We want to check if this is the case or not.

The following query finds for a particular caretaker, the value of number of bids placed per day of his availability.
 */
with AvailabilitiesWithNumBids as (
	select ctname, (end_date - start_date + 1) as interval_length_in_days, (
		select count(*)
		from Bids
		where availabilityId = A.id
	) as num_bids
	from Availabilities A
)
select username, case
	when count(interval_length_in_days) > 0 then sum(num_bids)/sum(interval_length_in_days)
	else NULL
	end as num_bids_per_day
from Caretakers CT left join AvailabilitiesWithNumBids A on CT.username = A.ctname
group by username
;

/*Question: Can we find (Owner, Caretaker) pairs where they are each other's favorite Caretaker/Owner respectively?
The favorite caretaker for an owner is the caretaker who the owner has made the most number of bids for, and the average rating the owner gives the caretaker is at least 4.
If 2 or more caretakers satisfy the condition and are tied for most number of bids, then the favorite caretaker is the one with the highest given average rating by the owner. 
If there is still a tie, then the favorite caretaker is the one with the most recent bid by the owner (determined by id of bid).

The favorite owner for a caretaker is the owner who the caretaker has accepted the most number of bids from, and the average rating the caretaker gives the owner is at least 4.
If 2 or more owners satisfy the condition and are tied for most number of accepted bids, then the favorite owner is the one with the highest given average rating by the caretaker. 
If there is still a tie, then the favorite owner is the one with the most recent bid accepted (determined by id of bid). 
*/

/*Question: How does the caretaker's choice of service type affect their popularity?
*/