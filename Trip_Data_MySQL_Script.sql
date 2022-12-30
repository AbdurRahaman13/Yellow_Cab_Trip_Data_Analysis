/*Importing data into database */
create database trip_data;
use trip_data;

create table cab(VendorID int,
				  lpep_pickup_datetime varchar(50),
                  lpep_dropoff_datetime varchar(50),
                  store_and_fwd_flag varchar(50),
                  RatecodeID int,
                  PULocationID int,
                  DOLocationID int,
                  passenger_count int,
                  trip_distance float,	
                  fare_amount float,
                  extra float,
                  mta_tax float,
                  tip_amount float,
                  tolls_amount float,
                  ehail_fee varchar(10),
                  improvement_surcharge float,
                  total_amount float,
                  payment_type varchar(50),
                  trip_type int,
                  congestion_surcharge float
);

select * from cab;


/*Data Manipulation*/


/*droping empty column*/
alter table cab
drop column ehail_fee;

/*updating column payment type*/
update cab
set payment_type = case 
                   when payment_type="1" then "credit_card"
                   when payment_type= "2" then "cash"
                   when payment_type="3" then "no_Charge"
                   when payment_type="4" then "dispute"
                   when payment_type="5" then "unknown"
                   when payment_type="6" then "voided_trip"
                   end;
                   
/*converting column from integer to string */
alter table cab
modify column ratecodeid varchar(50);

/*updating column ratecodeid*/
update cab
set ratecodeid = case 
                 when ratecodeid = "1" then "Standard rate"
                 when ratecodeid ="2" then "JFK"
                 when ratecodeid ="3" then "Newark"
                 when ratecodeid ="4" then "Nassau or Westchester"
                 when ratecodeid = "5" then "Negotiated fare"
                 when ratecodeid = "6" then "Group ride"
                 else "Null"
                 end;

/*converting column integer to char*/
alter table ride1
modify column payment_type varchar(50);

/*creating column for pickup_datetime*/
alter table cab
add column pickup_datetime datetime;

/*converting pickup_datetime column from varchar to datetime*/
update cab
set pickup_datetime = str_to_date(lpep_pickup_datetime,"%d-%m-%Y %H:%i:%s");

/*creating column for dropoff_datetime*/
alter table cab
add column dropoff_datetime datetime;

/*converting dropoff_datetime column from varchar to datetime*/
update cab
set dropoff_datetime = str_to_date(lpep_dropoff_datetime,"%d-%m-%Y %H:%i:%s");

/*droping columns*/
alter table cab
drop column lpep_pickup_datetime;

alter table cab
drop column lpep_dropoff_datetime;

select * from cab;

/*Exploratory Data Analysis */

/*Available Data from date*/
select min(pickup_datetime) as Start_Date
from cab;

/*Availabele Data to date*/
select max(pickup_datetime) as End_Date
from cab;

/*Total Bookings*/
select count(*) as Total_Bokings
from cab;

/*Total Revenue*/
select round(sum(total_Amount)) as Total_Revenue
from cab;

/*Average_month_bookings*/
select round(avg(Total_bookings)) as "Average_month_bookings"
from
(select day(pickup_datetime) as `day`,count(*) as Total_Bookings
from cab
group by 1
order by 1) as temp ;

/* Total Bookings by payment_type*/
select payment_type,count(payment_type) as Total_Bookings
from cab
group by payment_type
order by 2 desc; 

/*payment_type wise Revenue*/
select payment_type,round(sum(total_Amount)) as Revenue
from cab
group by payment_type
order by 2 desc; 

/*Total pickup_locations */
select count(pulocationid) as Total_Pickup_locations
from 
(select distinct pulocationid 
from cab) as temp;

/*Total Dropoff_locations */
select count(dolocationid) as Total_Dropoff_locations
from 
(select distinct dolocationid 
from cab) as temp;

/*Locations in Dropoff_locations but not in Pickup_locations*/
create view dropoff_locations_not_in_pickup_locations
as 
select count(*) as Total_Uncommon_Locations
from
(select distinct dolocationid 
from cab
where DOLocationID not in (select distinct pulocationid 
						   from cab)) as temp;
                           
select * from dropoff_locations_not_in_pickup_locations;
                           
/*Locations in Pickup_locations but not in Dropoff_locations*/
create view pickup_locations_not_in_dropoff_locations
as 
select distinct pulocationid 
from cab
where puLocationID not in (select distinct dolocationid 
						   from cab); 
                           
select * from pickup_locations_not_in_dropoff_locations;
                           
/*Common locations in pickup and dropoff*/
create view total_common_locations_in_pickup_locations_and_dropoff_locations
as
select count(*) as Total_common_locations
from
(select distinct pulocationid 
from cab
where DOLocationID in (select distinct dolocationid 
						   from cab)) as temp;
                           
select * from total_common_locations_in_pickup_locations_and_dropoff_locations;
                           
/*Top 20 Pickup location by Average Revenue*/
select PULocationID,round(avg(total_Amount)) as Average_Revenue
from cab
group by PULocationID
order by 2 desc
limit 20;

/*Bottom 20 Pickup location by Average Revenue*/
select PULocationID,round(AVG(total_Amount)) as Average_Revenue
from cab
group by PULocationID
order by 2 asc
limit 20;

/*Top 20 Dropoff location by Average Revenue*/
select DOLocationID,round(avg(total_Amount)) as Revenue
from cab
group by DOLocationID
order by 2 desc
limit 20;

/*Bottom 20 Dropoff location by Average Revenue*/
select DOLocationID,round(avg(total_Amount)) as Average_Revenue
from cab
group by DOLocationID
order by 2 asc
limit 20;

/*Passenger count wise Revenue*/
select passenger_count,round(sum(total_Amount)) as Revenue
from cab
group by passenger_count
order by 2 desc;

/*Passenger count wise Bookings*/
select passenger_count,count(passenger_count) as Total_Bookings
from cab
group by passenger_count
order by 2 desc;

/*ratecodeid wise total count*/
select ratecodeid,count(ratecodeid) as Total_Bookings
from cab
group by ratecodeid
order by 2 desc;

/*Average trip_distance*/
select round(avg(trip_distance)) as Average_trip_distance
from cab;

/*User defined variable*/
set @ATD := (select round(avg(trip_distance)) as Average_trip_distance
from cab);

/*Total Booking by above_average_trip_distance*/
select count(*) as Total_above_average_trip_distance
from cab
where trip_distance > @ATD;

/*Total Bookings by below_average_trip_distance*/
select count(*) as Total_Below_average_trip_distance
from cab
where trip_distance < @ATD;

/*Hour wise Bookings*/
select hour(pickup_datetime) as `hour`,count(*) as Total_Bookings
from cab
group by 1
order by 1 ;  

/*date wise bookings */
select day(pickup_datetime) as `day`,count(*) as Total_Bookings
from cab
group by 1
order by 1 ;

/*Weekname wise Bookings*/
create view Weekname_wise_Bookings 
as
select if(weekday(pickup_datetime)=0,"Monday",
	     if(weekday(pickup_datetime)=1,"Tuesday",
		   if(weekday(pickup_datetime)=2,"Wednesday",
			 if(weekday(pickup_datetime)=3,"Thursday",
			   if(weekday(pickup_datetime)=4,"Friday",
                 if(weekday(pickup_datetime)=5,"Saturday",
                   if(weekday(pickup_datetime)=6,"Sunday","")
                   )
				 )
				)
			  )
			)
		   )as "weekday", count(*) as Total_Bookings
from cab
group by weekday(pickup_datetime)
order by 1 ;

select * from Weekname_wise_Bookings;

