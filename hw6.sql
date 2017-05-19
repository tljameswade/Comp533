
drop table if exists Org cascade;
drop table if exists Meet cascade;
drop table if exists Participant cascade;
drop table if exists Leg cascade;
drop table if exists Stroke cascade;
drop table if exists Distance cascade;
drop table if exists Event cascade;
drop table if exists StrokeOf cascade;
drop table if exists Heat cascade;
drop table if exists Swim cascade;

create table Org (
    id char(4),
    name varchar(50),
    is_univ boolean,
    primary key (id)
);

create table Meet (
    name varchar(50),
    start_date date,
    num_days int,
    org_id char(4),
    primary key (name),
    foreign key (org_id) references Org(id)
);

create table Participant (
    id char(7),
    gender char(1),
    org_id char(4),
    first_name varchar(20),
    primary key (id)
);

create table Leg (
    leg int,
    primary key (leg)
);

create table Stroke (
    stroke varchar(20),
    primary key (stroke)
);

create table Distance (
    distance int,
    primary key (distance)
);

create table Event (
    id char(5),
    gender char(1),
    distance int,
    primary key (id),
    foreign key (distance) references Distance(distance)
);

create table StrokeOf (
    event_id char(5),
    leg int,
    stroke varchar(20),
    primary key (event_id, leg, stroke),
    foreign key (event_id) references Event(id),
    foreign key (leg) references Leg(leg),
    foreign key (stroke) references Stroke(stroke)
);

create table Heat (
    id int,
    event_id char(5),
    meet_name varchar(50),
    primary key (id, event_id, meet_name),
    foreign key (event_id) references Event(id),
    foreign key (meet_name) references Meet(name)
);

create table Swim (
    heat_id int,
    event_id char(5),
    meet_name varchar(50),
    participant_id char(7),
    leg int,
    time numeric,
    primary key (heat_id, event_id, meet_name, participant_id),
    foreign key (heat_id, event_id, meet_name) references Heat(id, event_id, meet_name),
    foreign key (meet_name) references Meet(name),
    foreign key (event_id) references Event(id),
    foreign key (participant_id) references Participant(id)
);

GRANT ALL PRIVILEGES ON TABLE Meet TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Org TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Participant TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Leg TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Stroke TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Distance TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Event TO ricedb;
GRANT ALL PRIVILEGES ON TABLE StrokeOf TO ricedb;
GRANT ALL PRIVILEGES ON TABLE Heat TO ricedb;
GRANT ALL PRIVILEGES ON TABLE isRelay TO ricedb;
GRANT ALL PRIVILEGES ON TABLE new_Table TO ricedb;

drop function if exists InsertOrUpdateOrg(m_id char(4), m_name varchar(50), m_is_univ boolean);
drop function if exists InsertMeet(m_name varchar(50), m_start_date date, m_num_days int, m_org_id char(4));
drop function if exists InsertOrUpdateParticipant(m_id char(7), m_gender char(1), m_org_id char(4), m_first_name varchar(20));
drop function if exists InsertLeg(m_leg int);
drop function if exists InsertStroke(m_stroke varchar(20));
drop function if exists InsertDistance(m_distance int);
drop function if exists InsertOrUpdateEvent(m_id char(5), m_gender char(1), m_distance int);
drop function if exists InsertStrokeOf(m_event_id char(5), m_leg int, m_stroke varchar(20));
drop function if exists InsertHeat(m_id int, m_event_id char(5), m_meet_name varchar(50));
drop function if exists InsertSwim(m_heat_id int, m_event_id char(5), m_meet_name varchar(50), m_participant_id char(7), m_leg int, m_time numeric);
drop function if exists MeetToHeatSheet(m_meet_name varchar(50));
drop function if exists ParticipantMeetToHeatSheet(m_participant_id char(7), m_meet_name varchar(50));
drop function if exists OrgMeetToHeatSheet(m_org_id char(4), m_meet_name varchar(50));
drop function if exists OrgMeetToSwimmerName(m_org_id char(4), m_meet_name varchar(50));
drop function if exists EventMeetToHeatSheet(m_event_id char(5), m_meet_name varchar(50));
drop function if exists MeetOrgToScore(m_meet_name varchar(50));

create or replace function InsertOrUpdateOrg(
    m_id char(4),
    m_name varchar(50),
    m_is_univ boolean
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Org
    where id = m_id;
    if matches = 0
        then insert into Org values (m_id, m_name, m_is_univ);
    else
        update Org
        set name = m_name, is_univ = m_is_univ
        where id = m_id;
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertMeet(
    m_name varchar(50),
    m_start_date date,
    m_num_days int,
    m_org_id char(4)
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Meet
    where name = m_name;
    if matches = 0
        then insert into Meet values (m_name, m_start_date, m_num_days, m_org_id);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertOrUpdateParticipant(
    m_id char(7),
    m_gender char(1),
    m_org_id char(4),
    m_first_name varchar(20)
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Participant
    where id = m_id;
    if matches = 0
        then insert into Participant values (m_id, m_gender, m_org_id, m_first_name);
    else
        update Participant
        set gender = m_gender, org_id = m_org_id, first_name = m_first_name
        where id = m_id;
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertLeg(
    m_leg int
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Leg
    where leg = m_leg;
    if matches = 0
        then insert into Leg values (m_leg);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertStroke(
    m_stroke varchar(20)
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Stroke
    where stroke = m_stroke;
    if matches = 0
        then insert into Stroke values (m_stroke);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertDistance(
    m_distance int
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Distance
    where distance = m_distance;
    if matches = 0
        then insert into Distance values (m_distance);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertOrUpdateEvent(
    m_id char(5),
    m_gender char(1),
    m_distance int
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Event
    where id = m_id;
    if matches = 0
        then insert into Event values (m_id, m_gender, m_distance);
    else
        update Event
        set gender = m_gender, distance = m_distance
        where id = m_id;
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertStrokeOf(
    m_event_id char(5),
    m_leg int,
    m_stroke varchar(20)
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from StrokeOf
    where event_id = m_event_id And leg = m_leg AND stroke = m_stroke;
    if matches = 0
        then insert into StrokeOf values (m_event_id, m_leg, m_stroke);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertHeat(
    m_id int,
    m_event_id char(5),
    m_meet_name varchar(50)
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Heat
    where id = m_id And event_id = m_event_id AND meet_name = m_meet_name;
    if matches = 0
        then insert into Heat values (m_id, m_event_id, m_meet_name);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function InsertSwim(
    m_heat_id int,
    m_event_id char(5),
    m_meet_name varchar(50),
    m_participant_id char(7),
    m_leg int,
    m_time numeric
)
returns VOID
as $$
declare matches int;
begin
    select count(*) into matches from Swim
    where heat_id = m_heat_id AND meet_name = m_meet_name
        AND participant_id = m_participant_id AND leg = m_leg;
    if matches = 0
        then insert into Swim values (m_heat_id, m_event_id, m_meet_name, m_participant_id, m_leg, m_time);
    end if;
end $$
LANGUAGE plpgsql;

create or replace function MeetToHeatSheet(m_meet_name varchar(50))
returns table(
    Event_id char(5),
    Heat_id int,
    Participant_id char(7),
    Org_Name varchar(50),
    Individual_Time numeric,
    Relay_Time numeric,
    Rank bigint
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists new_Table cascade;
    create table new_Table as (
        select distinct i.event_id, i.heat_id, i.participant_id, o.name, i.time, 0.00 as Relay_Time, i.Indiv_rank as Event_rank
        from Indiv i
        inner join Org o on i.org_id = o.id
    UNION
        select distinct r.event_id, r.heat_id, r.participant_id, o.name, r.time, r.Relay_Time, r.Relay_Rank as Event_rank
        from Relay r
        inner join Org o on r.org_id = o.id
    );
    return query select * from new_Table T order by T.event_id, T.heat_id, T.Relay_Time, T.Event_rank;
end $$
LANGUAGE plpgsql
VOLATILE;

create or replace function ParticipantMeetToHeatSheet(m_participant_id char(7), m_meet_name varchar(50))
returns table(
    Event_id char(5),
    Heat_id int,
    Org_Name varchar(50),
    Individual_Time numeric,
    Relay_Time numeric,
    Rank bigint
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists new_Table cascade;
    create table new_Table as (
        select distinct i.event_id, i.heat_id, o.name, i.time, 0.00 as Relay_Time, i.Indiv_rank as Event_rank
        from Indiv i
        inner join Org o on i.org_id = o.id
        where i.participant_id = m_participant_id
    UNION
        select distinct r.event_id, r.heat_id, o.name, r.time, r.Relay_Time, r.Relay_Rank as Event_rank
        from Relay r
        inner join Org o on r.org_id = o.id
        where r.participant_id = m_participant_id
    );
    return query select * from new_Table T order by T.event_id, T.heat_id, T.Relay_Time, T.Event_rank;
end $$
LANGUAGE plpgsql
VOLATILE;

create or replace function OrgMeetToHeatSheet(m_org_id char(4), m_meet_name varchar(50))
returns table(
    Event_id char(5),
    Heat_id int,
    Participant_id char(7),
    Individual_Time numeric,
    Relay_Time numeric,
    Rank bigint
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists new_Table cascade;
    create table new_Table as (
        select distinct i.event_id, i.heat_id, i.participant_id, i.time, 0.00 as Relay_Time, i.Indiv_rank as Event_rank
        from Indiv i
        inner join Org o on i.org_id = o.id
        where i.org_id = m_org_id
    UNION
        select distinct r.event_id, r.heat_id, r.participant_id, r.time, r.Relay_Time, r.Relay_Rank as Event_rank
        from Relay r
        inner join Org o on r.org_id = o.id
        where r.org_id = m_org_id
    );
    return query select * from new_Table T order by T.event_id, T.heat_id, T.Relay_Time, T.Event_rank;
end $$
LANGUAGE plpgsql
VOLATILE;

create or replace function OrgMeetToSwimmerName(m_org_id char(4), m_meet_name varchar(50))
returns table(
    Participant_Name varchar(20)
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists new_Table cascade;
    create table new_Table as (
        select p.first_name from Participant p
        inner join Indiv i on i.participant_id = p.id
        where p.org_id = m_org_id
    UNION
        select p.first_name from Participant p
        inner join Relay r on r.participant_id = p.id
        where r.org_id = m_org_id
    );
    return query select * from new_Table T order by T.first_name;
end $$
LANGUAGE plpgsql
VOLATILE;

create or replace function EventMeetToHeatSheet(m_event_id char(5), m_meet_name varchar(50))
returns table(
    Heat_id int,
    Participant_id char(7),
    Participant_Name varchar(20),
    Org_Name varchar(50),
    Individual_Time numeric,
    Relay_Time numeric,
    Rank bigint
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists new_Table cascade;
    create table new_Table as (
        select distinct i.heat_id, i.participant_id, p.first_name, o.name, i.time, 0.00 as Relay_Time, i.Indiv_rank as Event_rank
        from Indiv i
        inner join Org o on i.org_id = o.id
        inner join Participant p on i.participant_id = p.id
        where i.event_id = m_event_id
    UNION
        select distinct r.heat_id, r.participant_id, p.first_name, o.name, r.time, r.Relay_Time, r.Relay_Rank as Event_rank
        from Relay r
        inner join Org o on r.org_id = o.id
        inner join Participant p on r.participant_id = p.id
        where r.event_id = m_event_id
    );
    return query select * from new_Table T order by T.Relay_Time, T.heat_id, T.Event_rank;
end $$
LANGUAGE plpgsql
VOLATILE;

create or replace function MeetOrgToScore(m_meet_name varchar(50))
returns table(
    org_id char(4),
    Org_Name varchar(50),
    score numeric
)
as $$
begin
    drop table if exists isRelay cascade;
    create table isRelay as (
        select distinct s.heat_id, s.event_id from Swim s
        where s.leg > 1 AND s.meet_name = m_meet_name
    );
    drop table if exists RelayHelper1 cascade;
    create table RelayHelper1 as (
        select p.org_id, i.event_id, i.heat_id, sum(s.time) as Relay_Time
        from isRelay i
        inner join Swim s on s.heat_id = i.heat_id AND s.event_id = i.event_id
        inner join Participant p on s.participant_id = p.id
        group by p.org_id, i.event_id, i.heat_id);
    drop table if exists RelayHelper2 cascade;
    create table RelayHelper2 as (
        select r1.org_id, r1.event_id, min(r1.Relay_Time) as Relay_Time_Best
        from RelayHelper1 r1
        group by r1.org_id, r1.event_id);
    drop table if exists RelayHelper3 cascade;
    create table RelayHelper3 as (
        select r2.org_id, r2.event_id, rank() over (partition by r2.event_id order by r2.Relay_Time_Best) as Relay_Rank
        from RelayHelper2 r2);
    drop table if exists Relay cascade;
    create table Relay as (
        select r3.org_id, r3.event_id, r1.heat_id, s.participant_id, s.time, r1.Relay_Time, r3.Relay_Rank
        from RelayHelper3 r3
        inner join RelayHelper1 r1 on r1.org_id = r3.org_id AND r1.event_id = r3.event_id
        inner join Participant p on p.org_id = r3.org_id
        inner join Swim s on s.heat_id = r1.heat_id AND s.event_id = r1.event_id AND p.id = s.participant_id
        order by r1.event_id, r3.Relay_Rank
    );
    drop table if exists ScoreHelperRelay cascade;
    create table ScoreHelperRelay as (
        select r.org_id, count(r.org_id) / count(r.participant_id) * 8 as score from Relay r
        where r.Relay_Rank = 1
        group by r.org_id
    UNION ALL
        select r.org_id, count(r.org_id) / count(r.participant_id) * 4 as score from Relay r
        where r.Relay_Rank = 2
        group by r.org_id
    UNION ALL
        select r.org_id, count(r.org_id) / count(r.participant_id) * 2 as score from Relay r
        where r.Relay_Rank = 3
        group by r.org_id
    );
    drop table if exists TotalRelay cascade;
    create table TotalRelay as (
        select s.org_id, sum(s.score) as score from ScoreHelperRelay s
        group by s.org_id
    );
    drop table if exists IndivHelper1 cascade;
    create table IndivHelper1 as (
        select p.org_id, s.event_id, s.participant_id, min(s.time) as Indiv_Best
        from Swim s
        inner join Participant p on s.participant_id = p.id
        where s.meet_name = m_meet_name AND s.leg = 1 AND not exists(
            select * from Relay r where s.event_id = r.event_id AND s.heat_id = r.heat_id
        )
        group by p.org_id, s.event_id, s.participant_id
    );
    drop table if exists IndivHelper2 cascade;
    create table IndivHelper2 as (
        select i1.org_id, i1.event_id, i1.participant_id, rank()
            over (partition by i1.event_id order by i1.Indiv_Best) as Indiv_rank
        from IndivHelper1 i1
    );
    drop table if exists Indiv cascade;
    create table Indiv as (
        select i2.org_id, i2.event_id, s.heat_id, i2.participant_id, s.time, i2.Indiv_rank
        from IndivHelper2 i2
        inner join Swim s on i2.event_id = s.event_id AND i2.participant_id = s.participant_id
        order by i2.event_id, i2.Indiv_rank
    );
    drop table if exists ScoreIndiv cascade;
    create table ScoreIndiv as (
        select i.org_id, count(i.org_id) * 6 as score from Indiv i
        where i.Indiv_rank = 1
        group by i.org_id
    UNION ALL
        select i.org_id, count(i.org_id) * 4 as score from Indiv i
        where i.Indiv_rank = 2
        group by i.org_id
    UNION ALL
        select i.org_id, count(i.org_id) * 3 as score from Indiv i
        where i.Indiv_rank = 3
        group by i.org_id
    UNION ALL
        select i.org_id, count(i.org_id) * 2 as score from Indiv i
        where i.Indiv_rank = 4
        group by i.org_id
    UNION ALL
        select i.org_id, count(i.org_id) * 1 as score from Indiv i
        where i.Indiv_rank = 5
        group by i.org_id
    );
    drop table if exists TotalIndiv cascade;
    create table TotalIndiv as (
        select s.org_id, sum(s.score) as score from ScoreIndiv s
        group by s.org_id
    );
    drop table if exists CombineRelayIndiv cascade;
    create table CombineRelayIndiv as (
        select * from TotalRelay
        UNION ALL
        select * from TotalIndiv
    );
    drop table if exists FinalScore cascade;
    create table FinalScore as (
        select c.org_id, o.name, sum(c.score) as score from CombineRelayIndiv c
        inner join Org o on c.org_id = o.id
        group by c.org_id, o.name
    );
    return query select * from FinalScore f order by f.score desc;
end $$
LANGUAGE plpgsql
VOLATILE;
