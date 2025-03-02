-- Working with Timestamps
/* Dates/Times in SQL are a complex topic, deserving of a category of their own.
   They're also fantastically powerful, making it easier to work with variable-length concepts like 'months' than many programming languages.

   Before getting started on this category, it's probably worth taking a look over the PostgreSQL docs page on date/time functions.
   You might also want to complete the aggregate functions category, since we'll use some of those capabilities in this section.
 */

-- Produce a timestamp for 1 a.m. on the 31st of August 2012
/*
 Produce a timestamp for 1 a.m. on the 31st of August 2012.
 */
select timestamp '2012-08-31 01:00:00';

-- Subtract timestamps from each other
/*
Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
 */
select '2012-08-31 01:00:00'::timestamp - '2012-07-30 01:00:00'::timestamp intervals;

-- Generate a list of all the dates in October 2012
/*
Produce a list of all the dates in October 2012. They can be output as a timestamp (with time set to midnight) or a date.
 */
select generate_series('2012-10-01', '2012-10-31', '1 day'::interval) ts;

-- Get the day of the month from a timestamp
/*
 Get the day of the month from the timestamp '2012-08-31' as an integer.
 */
select extract(day from '2012-08-31'::date) date_part;

-- Work out the number of seconds between timestamps
/*
 Work out the number of seconds between the timestamps '2012-08-31 01:00:00' and '2012-09-02 00:00:00'
 */
select extract(epoch from '2012-09-02 00:00:00'::timestamp - '2012-08-31 01:00:00'::timestamp)::int date_part;

-- Work out the number of days in each month of 2012
/* For each month of the year in 2012, output the number of days in that month.
   Format the output as an integer column containing the month of the year, and a second column containing an interval data type.
 */
select extract(month from cal.month), (cal.month + interval '1 month') - cal.month length
from (select generate_series(timestamp '2012-01-01', timestamp '2012-12-01', interval '1 month') as month) cal
order by month;

-- Work out the number of days remaining in the month
/* For any given timestamp, work out the number of days remaining in the month.
   The current day should count as a whole day, regardless of the time.
   Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer.
   Format the output as a single interval value.
 */
select (date_trunc('month', ts.t) + interval '1 month') - date_trunc('day', ts.t) remaining
from (select '2012-02-11 01:00:00'::timestamp t) ts;

-- Work out the end time of bookings
/*
Return a list of the start and end time of the last 10 bookings (ordered by the time at which they end, followed by the time at which they start) in the system.
 */
select starttime, starttime + slots * (interval '30 minutes') endtime
from cd.bookings
order by endtime desc, starttime desc
limit 10;

-- Return a count of bookings for each month
/*
 Return a count of bookings for each month, sorted by month
 */
select date_trunc('month', starttime) as month, count(*)
from cd.bookings
group by month
order by month;

-- Work out the utilisation percentage for each facility by month
/* Work out the utilisation percentage for each facility by month, sorted by name and month, rounded to 1 decimal place.
   Opening time is 8am, closing time is 8.30pm.
   You can treat every month as a full month, regardless of if there were some dates the club was not open.
 */
select name,
       month,
       round((100 * slots) / cast(25 * (cast((month + interval '1 month') as date) - cast(month as date)) as numeric),
             1) as utilisation
from (select f.name as name, date_trunc('month', starttime) as month, sum(slots) as slots
      from cd.bookings b
               inner join cd.facilities f
                          on b.facid = f.facid
      group by f.facid, month) as inn
order by name, month;