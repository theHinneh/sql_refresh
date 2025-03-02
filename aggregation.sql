/* Aggregation is one of those capabilities that really make you appreciate the power of relational database systems.
   It allows you to move beyond merely persisting your data, into the realm of asking fascinating questions that can be used to inform decision-making.
   This category covers aggregation at length, making use of standard grouping as well as more recent window functions.
 */

-- Count the number of facilities
/* For our first foray into aggregates, we're going to stick to something simple.
   We want to know how many facilities exist - simply produce a total count
 */
select count(facid)
from cd.facilities;

-- Count the number of expensive facilities
/*
Produce a count of the number of facilities that have a cost to guests of 10 or more.
 */
select count(facid)
from cd.facilities
where guestcost >= 10;

-- Count the number of recommendations each member makes.
/*
Produce a count of the number of recommendations each member has made. Order by member ID.
 */
select recommendedby, count(*)
from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby;

-- List the total slots booked per facility
/* Produce a list of the total number of slots booked per facility.
   For now, just produce an output table consisting of facility id and slots, sorted by facility id.
 */
select f.facid, sum(b.slots)
from cd.facilities f
         join cd.bookings b on b.facid = f.facid
group by f.facid
order by f.facid;

-- List the total slots booked per facility in a given month
/* Produce a list of the total number of slots booked per facility in the month of September 2012.
   Produce an output table consisting of facility id and slots, sorted by the number of slots.
 */
select facid, sum(slots) "Total Slots"
from cd.bookings
where to_char(starttime, 'YYYY-MM') = '2012-09'
group by facid
order by sum(slots);

-- List the total slots booked per facility per month
/* Produce a list of the total number of slots booked per facility per month in the year of 2012.
   Produce an output table consisting of facility id and slots, sorted by the id and month.
 */
select facid, extract(month from starttime) as month, sum(slots) "Total Slots"
from cd.bookings
where extract(year from starttime) = 2012
group by facid, month
order by facid, month;

-- Find the count of members who have made at least one booking
/*
Find the total number of members (including guests) who have made at least one booking.
 */
select count(distinct memid)
from cd.bookings;

-- List facilities with more than 1000 slots booked
/* Produce a list of facilities with more than 1000 slots booked.
   Produce an output table consisting of facility id and slots, sorted by facility id.
 */
select facid, sum(slots) "Total Slots"
from cd.bookings
group by facid
having sum(slots) > 1000
order by facid;

-- Find the total revenue of each facility
/* Produce a list of facilities along with their total revenue.
   The output table should consist of facility name and revenue, sorted by revenue.
   Remember that there's a different cost for guests and members!
 */
select f.name,
       sum(case
               when b.memid = 0 then guestcost * slots
               else membercost * slots end) as "revenue"
from cd.facilities f
         join cd.bookings b on f.facid = b.facid
group by f.name
order by revenue;

-- Find facilities with a total revenue less than 1000
/* Produce a list of facilities with a total revenue less than 1000.
   Produce an output table consisting of facility name and revenue, sorted by revenue.
   Remember that there's a different cost for guests and members!
 */
select name, revenue
from (select f.name,
             sum(case
                     when b.memid = 0 then guestcost * slots
                     else membercost * slots end) as "revenue"
      from cd.facilities f
               join cd.bookings b on f.facid = b.facid
      group by f.name) agg
where revenue < 1000
order by revenue;

-- Output the facility id that has the highest number of slots booked
/* Output the facility id that has the highest number of slots booked.
   For bonus points, try a version without a LIMIT clause. This version will probably look messy!
 */
select facid, sum(slots) "Total Slots"
from cd.bookings
group by facid
order by "Total Slots" desc
limit 1;

with sum as (select facid, sum(slots) as totalslots
             from cd.bookings
             group by facid)
select facid, totalslots
from sum
where totalslots = (select max(totalslots) from sum);

-- List the total slots booked per facility per month, part 2
/* Produce a list of the total number of slots booked per facility per month in the year of 2012.
   In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities.
   The output table should consist of facility id, month and slots, sorted by the id and month.
   When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
 */
select facid, extract(month from starttime) as month, sum(slots) slots
from cd.bookings
where to_char(starttime, 'YYYY') = '2012'
group by rollup (facid, month)
order by facid, month;

-- List the total hours booked per named facility
/* Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour.
   The output table should consist of the facility id, name, and hours booked, sorted by facility id.
   Try formatting the hours to two decimal places.
 */
with hours as (select facid, round(sum(slots) * 0.5, 2) "Total Hours"
               from cd.bookings
               group by facid
               order by facid)
select hours.facid, name, "Total Hours"
from hours
         join cd.facilities f on f.facid = hours.facid;

-- List each member's first booking after September 1st 2012
/*
Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
 */
select surname, firstname, m.memid, min(b.starttime)
from cd.members m
         join cd.bookings b on m.memid = b.memid
where starttime > '2012-09-01'
group by m.memid, firstname, surname
order by m.memid;

-- Produce a list of member names, with each row containing the total member count
/* Produce a list of member names, with each row containing the total member count.
   Order by join date, and include guest members.
 */
select count(*) over (), firstname, surname
from cd.members
order by joindate;

-- Produce a numbered list of members
/* Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining.
   Remember that member IDs are not guaranteed to be sequential.
 */
select row_number() over (order by joindate), firstname, surname
from cd.members;

-- Output the facility id that has the highest number of slots booked, again
/* Output the facility id that has the highest number of slots booked.
   Ensure that in the event of a tie, all tieing results get output.
 */
select facid, total
from (select facid, sum(slots) total, rank() over (order by sum(slots) desc) rank
      from cd.bookings
      group by facid) as ranked
where rank = 1;

-- Rank members by (rounded) hours used
/* Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours.
   Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank.
   Sort by rank, surname, and first name.
 */
select m.firstname,
       m.surname,
       ((sum(b.slots) + 10) / 20) * 10                             as hours,
       rank() over (order by ((sum(b.slots) + 10) / 20) * 10 desc) as rank
from cd.members m
         join cd.bookings b on m.memid = b.memid
group by m.firstname, m.surname
order by rank, surname, firstname;

-- Find the top three revenue generating facilities
/* Produce a list of the top three revenue generating facilities (including ties).
   Output facility name and rank, sorted by rank and facility name.
 */
select name, rank
from (select name, rank() over (order by sum(slots * case when memid = 0 then guestcost else membercost end) desc) rank
      from cd.facilities f
               join cd.bookings b on f.facid = b.facid
      group by name) s
where rank <= 3
order by rank, name;

-- Classify facilities by value
/* Classify facilities into equally sized groups of high, average, and low based on their revenue.
   Order by classification and facility name.
 */
select s.name, case when s.revenue = 1 then 'high' when s.revenue = 2 then 'average' else 'low' end
from (select name,
             ntile(3) over (order by sum(slots * case when memid = 0 then guestcost else membercost end) desc) revenue
      from cd.facilities f
               join cd.bookings b on f.facid = b.facid
      group by name
      order by revenue, name) s;

-- Calculate the payback time for each facility
/* Based on the 3 complete months of data so far, calculate the amount of time each facility will take to repay its cost of ownership.
   Remember to take into account ongoing monthly maintenance.
   Output facility name and payback time in months, order by facility name.
   Don't worry about differences in month lengths, we're only looking for a rough value here!
 */
select name, initialoutlay / (monthlyrevenue - monthlymaintenance) as repaytime
from (select f.name                                                                            name,
             f.initialoutlay                                                                   initialoutlay,
             f.monthlymaintenance                                                              monthlymaintenance,
             sum(case when memid = 0 then slots * f.guestcost else slots * membercost end) / 3 monthlyrevenue
      from cd.bookings b
               join cd.facilities f
                    on b.facid = f.facid
      group by f.facid) as subq
order by name;

-- Calculate a rolling average of total revenue
/* For each day in August 2012, calculate a rolling average of total revenue over the previous 15 days.
   Output should contain date and revenue columns, sorted by the date.
   Remember to account for the possibility of a day having zero revenue.
 */
create or replace view cd.dailyrevenue as
select cast(b.starttime as date) date, sum(case when memid = 0 then slots * f.guestcost else slots * membercost end) rev
from cd.bookings b
         join cd.facilities f
              on b.facid = f.facid
group by cast(b.starttime as date);

select date, avgrev
from (select dategen.date date, avg(revdata.rev) over (order by dategen.date rows 14 preceding) avgrev
      from (select cast(generate_series(timestamp '2012-07-10', '2012-08-31', '1 day') as date) as date) dategen
               left join
           cd.dailyrevenue revdata on dategen.date = revdata.date) s
where date >= '2012-08-01'
order by date;