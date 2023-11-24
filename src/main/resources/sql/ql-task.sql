-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса

SELECT ac.model, s.fare_conditions, count(s.seat_no)
from aircrafts as ac,
     seats as s
where ac.aircraft_code = s.aircraft_code
group by ac.model, s.fare_conditions
order by ac.model;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT ac.model, count(s.seat_no)
from aircrafts as ac,
     seats as s
where ac.aircraft_code = s.aircraft_code
GROUP BY ac.model
order by count desc
LIMIT 3;

-- 3. Найти все рейсы, которые задерживались более 2 часов

select *
from flights as f
where f.actual_arrival > f.scheduled_arrival + INTERVAL '2' HOUR;

-- 4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных

select t.ticket_no, t.passenger_name, t.contact_data
from tickets as t,
     ticket_flights as tf,
     bookings as b
where t.ticket_no = tf.ticket_no
  and b.book_ref = t.book_ref
  and tf.fare_conditions = 'Business'
order by b.book_date desc
limit 10;

-- 5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')

select *
from flights as f
where f.flight_id not in (select distinct f.flight_id
                          from flights f,
                               ticket_flights tf
                          where f.flight_id = tf.flight_id
                            and tf.fare_conditions = 'Business');

-- 6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой

select distinct a.airport_name, a.city
from airports as a,
     flights as f
where f.status = 'Delayed';

-- 7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов

select a.airport_name, count(f.flight_id) as counts_flights
from airports as a,
     flights as f
where a.airport_code = f.departure_airport
  and (f.status = 'Scheduled' or f.status = 'On Time' or f.status = 'Delayed')
GROUP BY a.airport_name
order by counts_flights desc;

-- 8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным

select *
from flights as f
where f.actual_arrival < f.scheduled_arrival
   or f.actual_arrival > f.scheduled_arrival;

-- 9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам

select a.aircraft_code, a.model, s.seat_no, s.fare_conditions
from aircrafts as a,
     seats as s
where a.model = 'Аэробус A321-200'
  and a.aircraft_code = s.aircraft_code
  and (s.fare_conditions = 'Comfort' or s.fare_conditions = 'Business')
order by s.seat_no;

-- 10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)

select a.airport_code, a.airport_name, a.city
from airports as a,
     (select a.city, count(a.city) as counts from airports a group by a.city) as counts_airport
where a.city = counts_airport.city
  and counts_airport.counts > 1;

-- 11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований

select t.passenger_id, t.passenger_name, t.contact_data
from tickets as t,
     bookings as b
where t.book_ref = b.book_ref
  and (select sum(b.total_amount) from bookings as b where t.book_ref = b.book_ref) >
      (select avg(b.total_amount) from bookings as b);

-- 12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

select *
from flights as f
where f.departure_airport in (select a.airport_code from airports a where a.city = 'Екатеринбург')
  and f.arrival_airport in (select a.airport_code from airports a where a.city = 'Москва')
  and (f.status = 'Scheduled' or f.status = 'On Time' or f.status = 'Delayed')
order by f.scheduled_departure asc
limit 1;

-- 13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)

select one_min_tiket.ticket_no, one_min_tiket.flight_id, one_min_tiket.fare_conditions, one_min_tiket.amount
from (select *
      from ticket_flights as tf
      where tf.amount = (select min(tf.amount) from ticket_flights as tf)
      limit 1) as one_min_tiket
union
(select *
 from ticket_flights as tf
 where tf.amount = (select max(tf.amount) from ticket_flights as tf)
 limit 1);

-- 14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)

create table customers
(
    id         serial PRIMARY KEY,
    first_name VARCHAR(30)        NOT NULL,
    last_name  VARCHAR(40)        NOT NULL,
    email      VARCHAR(60) UNIQUE NOT NULL check (email ~ $$^\S+@\S+\.\S+$$),
    phone      VARCHAR(13) UNIQUE NOT null check (phone ~ $$^\+\d{12}$$)
);

-- 15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints

create table orders
(
    id         serial PRIMARY KEY,
    customerId bigint         NOT NULL,
    quantity   numeric(19, 2) NOT NULL check (quantity >= 0),
    FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
);

-- 16. Написать 5 insert в эти таблицы

insert into customers (first_name, last_name, email, phone)
values ('Ivan', 'Ivanov', 'ivan2000@gmail.ru', '+375291234567');
insert into customers (first_name, last_name, email, phone)
values ('Sergei', 'Sergeev', 'sergei2003@gmail.ru', '+375291234568');
insert into customers (first_name, last_name, email, phone)
values ('Petia', 'Petrov', 'petia2001@gmail.ru', '+375291234569');
insert into customers (first_name, last_name, email, phone)
values ('Aleksandr', 'Sitnikov', 'aleksandr2002@gmail.ru', '+375291234517');
insert into customers (first_name, last_name, email, phone)
values ('Eduard', 'Sobolev', 'eduard98@gmail.ru', '+375291234527');

insert into orders (customerId, quantity)
values (1, 0);
insert into orders (customerId, quantity)
values (2, 11.26);
insert into orders (customerId, quantity)
values (2, 99.9);
insert into orders (customerId, quantity)
values (3, 150.36);
insert into orders (customerId, quantity)
values (4, 0.59);

-- 17. Удалить таблицы

drop table orders;
drop table customers;