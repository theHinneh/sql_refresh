-- Retrieve the start times of members' bookings
/* How can you produce a list of the start times for bookings by members named 'David Farrell'? */
select b.starttime
from cd.bookings b
         inner join cd.members m on m.memid = b.memid
where m.firstname = 'David'
  and m.surname = 'Farrell';

-- Work out the start times of bookings for tennis courts
/* How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'?
   Return a list of start time and facility name pairings, ordered by the time. */
select b.starttime start, f.name
from cd.bookings b
         left join cd.facilities f on f.facid = b.facid
where f.name ilike '%tennis court%'
  and b.starttime >= '2012-09-21'
  and b.starttime < '2012-09-22'
order by b.starttime;

-- Produce a list of all members who have recommended another member
/* How can you output a list of all members who have recommended another member?
   Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname). */
select distinct m.firstname, m.surname
from cd.members m
         inner join cd.members rec on rec.recommendedby = m.memid
order by m.surname, m.firstname;

-- Produce a list of all members, along with their recommender
/* How can you output a list of all members, including the individual who recommended them (if any)?
   Ensure that results are ordered by (surname, firstname). */
select mem.firstname memfname, mem.surname memsname, rec.firstname recfname, rec.surname recsname
from cd.members mem
         left join cd.members rec on rec.memid = mem.recommendedby
order by mem.surname, mem.firstname;

-- Produce a list of all members who have used a tennis court
/* How can you produce a list of all members who have used a tennis court?
   Include in your output the name of the court, and the name of the member formatted as a single column.
   Ensure no duplicate data, and order by the member name followed by the facility name. */
select distinct concat(m.firstname, ' ', m.surname) member, f.name facility
from cd.members m
         inner join cd.bookings b on m.memid = b.memid
         inner join cd.facilities f on b.facid = f.facid
where f.name ilike '%tennis court%'
order by member, facility;

-- Produce a list of costly bookings
/* How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30?
   Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0.
   Include in your output the name of the facility, the name of the member formatted as a single column, and the cost.
   Order by descending cost, and do not use any subqueries. */
select concat(m.firstname, ' ', m.surname)                                              member,
       f.name                                                                           facility,
       case when m.memid = 0 then f.guestcost * b.slots else f.membercost * b.slots end cost
from cd.members m
         inner join cd.bookings b on m.memid = b.memid
         inner join cd.facilities f on b.facid = f.facid
where b.starttime >= '2012-09-14'
  and b.starttime < '2012-09-15'
  and ((m.memid = 0 and b.slots * f.guestcost > 30) or (m.memid != 0 and b.slots * f.membercost > 30))
order by cost desc;

-- Produce a list of all members, along with their recommender, using no joins.
/* How can you output a list of all members, including the individual who recommended them (if any), without using any joins?
   Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered. */
select distinct concat(mem.firstname, ' ', mem.surname) member,
                (select concat(rec.firstname, ' ', rec.surname)
                 from cd.members rec
                 where rec.memid = mem.recommendedby)   recommender
from cd.members mem
order by member;

-- Produce a list of costly bookings, using a subquery
/* The Produce a list of costly bookings exercise contained some messy logic: we had to calculate the booking cost in both the WHERE clause and the CASE statement.

   Try to simplify this calculation using subqueries. For reference, the question was:
   How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30?
   Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0.
   Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost. */
select member, facility, cost
from (select concat(m.firstname, ' ', m.surname)                                              member,
             f.name                                                                           facility,
             case when m.memid = 0 then f.guestcost * b.slots else f.membercost * b.slots end cost
      from cd.members m
               inner join cd.bookings b on m.memid = b.memid
               inner join cd.facilities f on b.facid = f.facid
      where b.starttime >= '2012-09-14'
        and b.starttime < '2012-09-15'
      order by cost desc) booking
where cost > 30.0
order by cost desc;