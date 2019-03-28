--important views

--table of user and their average rating as a caretaker and as a petowner. Rating is null if user has no ratings.
create view UserRating (username, ctrating, orating) as
select U.username,
	(select avg(ctrating)
	from AcceptedBids natural join Bids
	where ctname = U.username) as ctname,
	(select avg(orating)
	from AcceptedBids natural join Bids
	where oname = U.username) as orating
from Users U