classDiagram
direction BT
class bookings {
   integer facid
   integer memid
   timestamp starttime
   integer slots
   integer bookid
}
class facilities {
   varchar(100) name
   numeric membercost
   numeric guestcost
   numeric initialoutlay
   numeric monthlymaintenance
   integer facid
}
class members {
   varchar(200) surname
   varchar(200) firstname
   varchar(300) address
   integer zipcode
   varchar(20) telephone
   integer recommendedby
   timestamp joindate
   integer memid
}

bookings  -->  facilities : facid
bookings  -->  members : memid
members  -->  members : recommendedby:memid
