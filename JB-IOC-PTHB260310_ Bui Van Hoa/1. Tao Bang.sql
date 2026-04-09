create table customer(
	customer_id varchar(5) not null primary key,
	customer_full_name varchar(100) not null,
	customer_email varchar(100) not null unique,
	customer_phone varchar(15) not null,
	customer_address varchar(255) not null
);

create table room(
	room_id varchar(5) not null primary key,
	room_type varchar(50) not null,
	room_price decimal(10,2) not null,
	room_status varchar(20) not NULL,
	room_area int not null
);

create table booking(
	booking_id serial primary key,
	customer_id varchar(5) not null references customer(customer_id),
	room_id varchar(5) not null references room(room_id),
	check_in_date date not null,
	check_out_date date not null,
	total_amount decimal(10,2)
);

create table payment(
	payment_id serial primary key,
	booking_id int not null references booking(booking_id),
	payment_method varchar(50) not null,
	payment_date date not null,
	payment_amount decimal(10,2) not null
);
