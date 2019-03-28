--pet owners filter for Availabitilies for manually specified dates from Owners offering the ServiceTypes, PetSpecies and WeightClasses manually specified by the pet owner.
/*Denote ostart_date = start date speciifed by owner
	oend_date = end_date specified by owner
	stypeid = service type id specified by owner
	sid = pet species id specified by owner
	wid = weight class id specified by owner

*/
select A.ctname, A.start_date, A.end_date
from Availabilities A
where A.start_date <= #ostart_date and A.end_date >= #oend_date
and exists (
	select 1
	from OfferedCares O
	where A.ctname = O.ctname and O.pet_sid = #sid and O.pet_wid = wid and O.service_type_id = #stypeid
)

--pet owners can sort their availabilities based on the owner rating.
with FilteredAvailabilities as (
	select A.ctname, A.start_date, A.end_date
	from Availabilities A
	where A.start_date <= #ostart_date and A.end_date >= #oend_date
	and exists (
		select 1
		from OfferedCares O
		where A.ctname = O.ctname and O.pet_sid = #sid and O.pet_wid = wid and O.service_type_id = #stypeid
	)
)
select A.ctname, A.start_date, A.end_date
from FilteredAvailabilities FA left join UserRatings UR on FA.ctname = UR.username
order by UR.ctrating desc

/*pet owners filter for Availabitilies for manually specified dates and service types from Owners offering offers which are automatedly choosen such that it satisfies the condition:
	at least one of the Pets owned by the pet owner satisfies the pet species and weight class of the offer.





