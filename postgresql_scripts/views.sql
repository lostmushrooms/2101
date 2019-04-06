--important views
DROP VIEW IF EXISTS UserRating CASCADE;


--table of user, whether they are owner or caretaker,0 and their average rating as a caretaker or petowner. Rating is null if user has no ratings.
--is_owner is True if user is an owner.
create view UserRating (username, is_owner, rating) as
select U.username, case 
		when exists (select 1 from Owners where username = U.username) then True
		else False
	end as is_owner,
	coalesce(
		(select avg(ctrating)
		from (AcceptedBids natural join Bids) AB join Availabilities A on AB.availabilityId = A.id 
		where ctname = U.username),
		(select avg(orating)
		from AcceptedBids natural join Bids
		where oname = U.username)
	) as rating
from Users U;


--testing queries
select *
from UserRating