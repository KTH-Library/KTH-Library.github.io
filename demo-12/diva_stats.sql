drop table if exists school_abbr;

create table school_abbr(unit_school varchar, school_name varchar);

insert into school_abbr values
('ABE',  'Skolan för arkitektur och samhällsbyggnad'),
('CBH',  'Skolan för kemi, biologi och hälsa'),
('EECS', 'Skolan för elektronik och datavetenskap'),
('ITM',  'Skolan för industriell teknik och management'),
('SCI',  'Skolan för teknikvetenskap'),
('VS',   'Verksamhetsstöd')
;

set variable hr_today_filepath = 's3://hr24/HR_ 2025-12-03 05.30.39 261.csv';

create or replace table hr_latest as (
    from (
        from read_csv_auto(getvariable('hr_today_filepath'), types={'ÄMNESKOD': 'VARCHAR'})
        select
            kthid: KTHID,
            yob: FÖDELSEÅR,
            unit_abbr: ORG_NR,
            unit_name: ORG_NAMN,
            unit_status: STATUS,
            lastname: trim(EFTERNAMN),
            firstname: trim(FÖRNAMN),
            email: KTH_EMAIL,
            gender: "MAN/KVINNA",
            emp_code: TJ_BEN_KOD,
            emp_desc: TJ_BEN_TEXT,
            emp_nr: BEF_NR,
            emp_first_beg: BEF_FROM::DATE,
            emp_beg: DATUM_NUV_BEF::DATE,
            emp_end: ifnull(BEF_TOM, '2999-12-31')::DATE,
            emp_degree: SYSS_GRAD,
            scb_topic: ÄMNESKOD,
            emp_title_swe: FUNKTION_SV,
            school_name: SKOLA
    ) left join school_abbr using (school_name)
    select *,
        fullname: concat(lastname, ', ', firstname),
        plainname: concat(firstname, ' ', lastname),
        username: regexp_replace(email, '@.*$', ''),
);

create or replace table diva_stats_1 as (

    with diva_stats as (
        from (
            from recordInfo 
            select 
                pid, 
                origin, 
                creation_date, 
                change_date
            where
                creation_date between '2010-01-01'::date and '2025-12-31'::date
        ) ri 
        left join (
            from hr_latest 
            select 
                origin: kthid, columns('^unit_')
        ) hr using (origin)
        left join (
            from publicationType
            select
                pid,
                type_diva,
                code_subtype,
                latest_oai: datestamp::date,
        ) pt using (pid)
        left join (
            from contentType
            select
                pid, 
                code_diva,
        ) ct using (pid)        
        select
            y: year(creation_date),
            type: lower(left(type_diva, 3)),
            n_pi: count(distinct pid) filter (left(unit_abbr, 2) = 'TR')::int,
            n_r: count(distinct pid) filter (left(unit_abbr, 2) != 'TR')::int,
            share: round(n_pi / (n_r + n_pi), 2),
        group by all
        having 
            (type_diva = 'Conference paper') or-- and code_subtype = 'publishedPaper') or 
            (type_diva = 'Article in journal') -- and code_diva = 'refereed') 
        order by y desc
    ),

    uds as (
        unpivot diva_stats
        on n_pi, n_r, share
        into 
            name count_type
            value n
    ),

    p as (
        pivot uds on (type || '_' || count_type) using (first(n))
    )

    from p
    select
        y,
        columns('art_n_')::int,
        columns('art_share'),
        columns('con_n_')::int,
        columns('con_share'),
    order by y asc
);

from diva_stats_1;

-- install textplot from community;
load textplot;

create or replace table diva_stats_2 as (

    with diva_stats as (
        from (
            from recordInfo 
            select 
                pid, 
                origin, 
                creation_date, 
                change_date
            where
                creation_date between '2025-01-01'::date and '2025-12-31'::date
        ) ri 
        left join (
            from hr_latest 
            select 
                origin: kthid, columns('^unit_')
        ) hr using (origin)
        left join (
            from publicationType
            select
                pid,
                type_diva,
                code_subtype,
                latest_oai: datestamp::date,
        ) pt using (pid)
        left join (
            from contentType
            select
                pid, 
                code_diva
        ) ct using (pid)
        select
            y: year(creation_date),
            m: month(creation_date),
            type: lower(left(type_diva, 3)),
            n_pi: count(distinct pid) filter (left(unit_abbr, 2) = 'TR')::int,
            n_r: count(distinct pid) filter (left(unit_abbr, 2) != 'TR')::int,
            share: round(n_pi / (n_r + n_pi), 2),
        group by all
        having
            (type_diva = 'Article in journal') or -- and code_diva = 'refereed') or 
            (type_diva = 'Conference paper') -- and code_subtype = 'publishedPaper')
        order by y asc, m asc
    ),

    uds as (
        unpivot diva_stats
        on n_pi, n_r, share
        into 
            name count_type
            value n
    ),

    p as (
        pivot uds on (type || '_' || count_type) using (first(n))
    )

    from p
    select
        year: y, month: m,
        columns('..._n_')::int,
        columns('..._share'),
    order by y desc
);

from diva_stats_2;

copy (
    from diva_stats_1
    select
        y,
        art_n_pi, pi: tp_bar(art_n_pi, min:=0, max:=3200, width:=15, "on" := '░', "off":=' '), 
        art_n_r, r: tp_bar(art_n_r, min:=0, max:=3200, width:=15, "on":='░', "off":=' '),
        shr: tp_bar(art_share, min:=0, max:=1, width:=15, "on":='█', "off":='░'),
        pct: printf('%3i %%', (100 * art_share::decimal(3, 2))::int),      
    where y between 2015 and 2025
    order by y asc
) to 'diva_stats_art_10y.csv'
;

.sh duckdb -c "from 'diva_stats_art_10y.csv'" | sed 's/[┌─┐├┼┤│└┘┬┴]/ /g' | head -n -2 | sed '3d' > diva_stats_art_11y.csv
.sh rm diva_stats_art_10y.csv

copy (
    from diva_stats_1
    select
        y,
        con_n_pi, pi: tp_bar(con_n_pi, min:=0, max:=1500, width:=15, "on" := '░', "off":=' '), 
        con_n_r, r: tp_bar(con_n_r, min:=0, max:=1500, width:=15, "on":='░', "off":=' '),
        shr: tp_bar(con_share, min:=0, max:=1, width:=15, "on":='█', "off":='░'),    
        pct: printf('%3i %%', (100 * con_share::decimal(3, 2))::int),      
    where y between 2015 and 2025
    order by y asc
) to 'diva_stats_con_10y.csv'
;

.sh duckdb -c "from 'diva_stats_con_10y.csv'" | sed 's/[┌─┐├┼┤│└┘┬┴]/ /g' | head -n -2 | sed '3d' > diva_stats_con_11y.csv
.sh rm diva_stats_con_10y.csv

copy (
    from (
        from diva_stats_2 
        select year, month, columns('art_n'), columns('con_n'), columns('(art|con)_share')
    ) 
    select 
        t: year::int || '-' || printf('%02i', month::int), 
        art_n_pi, pi: tp_bar(art_n_pi, min:=0, max:=800, width:=15, "on" := '░', "off":=' '), 
        art_n_r, r: tp_bar(art_n_r, min:=0, max:=800, width:=15, "on":='░', "off":=' '),
        shr: tp_bar(art_share, min:=0, max:=1, width:=15, "on":='█', "off":='░'), 
        pct: printf('%3i %%', (100 * art_share::decimal(3, 2))::int),      
) to 'diva_stats_art_2025.csv'
;

.sh duckdb -c "from 'diva_stats_art_2025.csv'" | sed 's/[┌─┐├┼┤│└┘┬┴]/ /g' | head -n -2 | sed '3d' > diva_stats_art.csv
.sh rm diva_stats_art_2025.csv

copy (
    from (
        from diva_stats_2 
        select year, month, columns('art_n'), columns('con_n'), columns('(art|con)_share')
    ) 
    select 
        t: year::int || '-' || printf('%02i', month::int), 
        con_n_pi, pi: tp_bar(con_n_pi, min:=0, max:=200, width:=15, "on" := '░', "off":=' '), 
        con_n_r, r: tp_bar(con_n_r, min:=0, max:=200, width:=15, "on":='░', "off":=' '),
        shr: tp_bar(con_share, min:=0, max:=1, width:=15, "on":='█', "off":='░'),    
        pct: printf('%3i %%', (100 * con_share::decimal(3, 2))::int),      
) to 'diva_stats_con_2025.csv'
;

.sh duckdb -c "from 'diva_stats_con_2025.csv'" | sed 's/[┌─┐├┼┤│└┘┬┴]/ /g' | head -n -2 | sed '3d' > diva_stats_con.csv
.sh rm diva_stats_con_2025.csv
