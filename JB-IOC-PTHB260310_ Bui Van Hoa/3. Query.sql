--3. Update data
update booking b
set total_amount = r.room_price * (b.check_out_date - b.check_in_date)
from room r
where b.room_id = r.room_id
  and r.room_status = 'Booked'
  and b.check_in_date < current_date;

--4. delete data
delete from payment
where payment_method = 'Cash' and payment_amount < 500;

--Query
--5. Lay danh sach khach hang sap xep theo ten ( tang dan )
select *
from customer
order by customer_full_name;

--6.
select room_id, room_type, room_price, room_area
from room
order by room_price desc;

--7. Join table customer, booking, room
select 
    c.customer_id,
    c.customer_full_name,
    r.room_id,
    b.check_in_date,
    b.check_out_date
from customer c
join booking b on c.customer_id = b.customer_id
join room r on b.room_id = r.room_id;

--8. Thong tin khach hang, tong so tien moi khach hang da thanh toan theo tung phuong thuc thanh toan
select 
	c.customer_id,
	c.customer_full_name,
	p.payment_method,
	sum(p.payment_amount)
from customer c
join booking b on b.customer_id = c.customer_id
join payment p on p.booking_id = b.booking_id
group by c.customer_id, p.payment_method
order by sum(p.payment_amount) desc;

--9. order in asc
select * 
from customer
order by customer_full_name
limit 3 offset 1

--10. Danh sach khach hang: da dat 2 phong (khac nhau) va tong tien thanh toan > 1000
select
	c.customer_id,
	c.customer_full_name, 
	count(distinct b.room_id)
from booking b
join customer c on c.customer_id = b.customer_id
join payment p on p.booking_id = b.booking_id
group by c.customer_id
having count(distinct b.room_id) >= 2 -- tinh so phong moi khach hang
	   and sum(p.payment_amount) > 1000;

--11. Lay danh sach phong: co it nhat 3 KH khac nhau dat va tong tien nho hon 1000
select
	r.room_id,
	r.room_type,
	r.room_price,
	sum(p.payment_amount)
from room r
join booking b on r.room_id = b.room_id
join payment p on b.booking_id = p.booking_id
group by r.room_id
having count(distinct b.customer_id) >= 3 -- tinh so khach hang cua moi phong
	   and sum(p.payment_amount) < 1000;

--12. Khach hang co tong so tien da thanh toan (tong chung cho tat ca cac phong) hon 1000
select 
    c.customer_id,
    c.customer_full_name,
    r.room_id,
    t.total_paid
from customer c
join (
    select 
        b.customer_id,
        sum(p.payment_amount) as total_paid
    from booking b
    join payment p on b.booking_id = p.booking_id
    group by b.customer_id
    having sum(p.payment_amount) > 1000
) t on c.customer_id = t.customer_id
join booking b on c.customer_id = b.customer_id
join room r on b.room_id = r.room_id;

--13.
select customer_id, customer_full_name, customer_email, customer_phone
from customer
where customer_full_name like '%Minh%' or customer_address like '%Hanoi%'
order by customer_full_name;

--14.
select room_id, room_type, room_price 
from room
order by room_price desc
limit 5 offset 5

--Create View
--15.
create or replace view room_booked
as
select r.room_id, r.room_type, c.customer_id, c.customer_full_name
from room r
join booking b on r.room_id = b.room_id
join customer c on b.customer_id = c.customer_id
where b.check_in_date <'2025-03-10';

--16.
create or replace view customer_booked
as
select c.customer_id, c.customer_full_name, r.room_id, r.room_area
from room r 
join booking b on r.room_id = b.room_id
join customer c on b.customer_id = c.customer_id
where r.room_area > 30;

-- create trigger
--17.
create or replace function f_check_insert_booking()
returns trigger 
language plpgsql
as $$
begin
	if new.check_out_date < new.check_in_date then
		raise exception 'Ngày đặt phòng không thể sau ngày trả phòng được !';
	end if;
	return new;
end; $$;

create or replace trigger check_insert_booking
before insert on booking
for each row
execute function f_check_insert_booking();

--18.
create or replace function f_update_room_status_on_booking()
returns trigger 
language plpgsql
as $$
begin
	update room
	set room_status='Booked'
	where room_id=new.room_id;
	return null;
end; $$ ;

create or replace trigger update_room_status_on_booking
after insert on booking
for each row
execute function f_update_room_status_on_booking();

--19.
create or replace procedure add_customer(
	p_customer_id varchar(5),
	p_customer_full_name varchar(100),
	p_customer_email varchar(100),
	p_customer_phone varchar(15),
	p_customer_address varchar(255)
)
language plpgsql
as $$
begin
	insert into customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address) values
	(p_customer_id, p_customer_full_name, p_customer_email, p_customer_phone, p_customer_address);
end; $$;

--20.
create or replace procedure add_payment(
	p_booking_id int,
	p_payment_method varchar(50),
	p_payment_date date,
	p_payment_amount decimal(10,2)
)
language plpgsql
as $$
begin
	insert into payment(booking_id, payment_method, payment_date, payment_amount) values
	(p_booking_id, p_payment_method, p_payment_date, p_payment_amount);
end; $$;
