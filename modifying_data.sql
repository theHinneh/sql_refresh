-- Insert some data into a table
/* The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
   facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
 */

insert into cd.facilities
values (9, 'Spa', 20, 30, 100000, 800);

-- Insert multiple rows of data into a table
/* In the previous exercise, you learned how to add a facility. Now you're going to add multiple facilities in one command.
   Use the following values:
   facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
   facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
 */
insert into cd.facilities
values
--     (9, 'Spa', 20, 30, 100000, 800),
       (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

-- Insert calculated data into a table