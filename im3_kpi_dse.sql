with nbs as (
    select *
from (
select organization_id,parent_org_id,a.site_id, b.circle, b.region_circle, 
b.area, b.sales_area, b.micro_cluster, b.pt_nm, b.mpc_nm,
row_number() over (partition by organization_id order by dt_id desc) rn
from biadm.omn_outlet_loc_ns a
left join (select *
from biadm.ref_site_mth
where month_id=strleft('${var:dt_id}',6)
) b on a.site_id=b.site_id 
where strleft(dt_id,6)=strleft('${var:dt_id}',6)
) a
where rn =1
),
---visit unique dse im3
visit_unique_im3 as (
    SELECT DISTINCT
    operatorid,
    a.username, 
    mc_pjp cluster, 
    visitedsaldomobo_orgid,
    'VISIT-CSO' parameter,
    strleft('${var:dt_id}',6) mth
from rdm.spa_tbl_daily_dump_visitcsosf_v2 a
join
    (
        select id_outlet, username, micro_cluster mc_pjp
        from stg.outlet_cso_mapping
        where month=(select max(month) from stg.outlet_cso_mapping)
    ) pjp
    on a.visitedsaldomobo_orgid = pjp.id_outlet
    and a.username = pjp.username
where 1=1
and strleft(part_id,6) = strleft('${var:dt_id}',6)
and visitdatetime <> ''
),
---mapping based on data hq
map_outlet_hq as (
    select distinct
    c.circle, c.region_circle, c.area, c.sales_area, c.micro_cluster, 
    b.id_outlet, b.outlet_name, b.category, b.fisik_nonfisik, 
    b.username, b.operator_type, 
    b.status, b.spv_username, b.mpc_code, c.site_id, if(c.site_id=d.site_id,"LRS","NON LRS") lrs_flag
from stg.outlet_cso_mapping b
left join nbs c
on b.id_outlet=c.organization_id
left join c_java.ar_phoenix_site_lrs_ext d 
on c.site_id=d.site_id
where month=(select max(month) from stg.outlet_cso_mapping)
and circle="JAVA"
),
---mapping outlet im3 based on data SnD with LRS site
map_outlet_java as (
    select distinct a.brand, a.region, a.area, a.branch, a.mpc_name, a.mpc_short_code, a.micro_cluster,
    a.supervisor_code, a.dse_code, a.outlet_code, a.outlet_name, a.dse_category, 
    b.site_id, 
    if(b.site_id=c.site_id,"LRS","NON LRS") lrs_flag
--    if(a.outlet_code=d.visitedsaldomobo_orgid,"1","0") visit_unique 
from c_java.dse_outlet_map_ext a
left join nbs b 
on a.outlet_code=b.organization_id
left join c_java.ar_phoenix_site_lrs_ext c 
on b.site_id=c.site_id
--left join visit_unique_im3 d
--on a.dse_code=d.username
where a.month_id=(select max(month_id) from c_java.dse_outlet_map_ext)
and brand="IM3"
),

---KPI FOR OKTOBER 2024---
kpi_okt as (
    ---Sellin/FRC
select a.outlet_code, 'frc' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
nvl(b.amount_mtd,0) amount_mtd, nvl(b.amount_lmtd,0) amount_lmtd
--case when b.parameter="supply_inj_sp_hits" and amount_mtd >= 10 then 1 else 0 end amount_mtd,
--case when b.parameter="supply_inj_sp_hits" and amount_lmtd >= 10 then 1 else 0 end amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on a.outlet_code=b.organization_id and b.month_id=strleft('${var:dt_id}',6) and b.brand="IM3" and b.parameter = "supply_inj_sp_hits"
union all
---secondary
select a.outlet_code, 'secondary' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
sum(nvl(b.amount_mtd,0)) amount_mtd,sum(nvl(b.amount_lmtd,0)) amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on a.outlet_code=b.organization_id and b.month_id=strleft('${var:dt_id}',6) and b.brand="IM3" and b.parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
union all
---secondary 200k
select a.outlet_code, 'secondary_200k' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
case when b.amount_mtd>=200000 then 1 else 0 end amount_mtd,
case when b.amount_lmtd>=200000 then 1 else 0 end amount_lmtd
from (
select organization_id, 'secondary_200k' parameter, as_of_dt, brand, month_id,sum(amount_mtd) amount_mtd,sum(amount_lmtd) amount_lmtd
from c_java.nw_dse_kpi_tracker a  
where a.month_id=strleft('${var:dt_id}',6) and a.brand="IM3"
and parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
) b
right join map_outlet_java a on b.organization_id=a.outlet_code
union all
---secondary 500k
select a.outlet_code, 'secondary_500k' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
case when b.amount_mtd>=500000 then 1 else 0 end amount_mtd,
case when b.amount_lmtd>=500000 then 1 else 0 end amount_lmtd
from (
select organization_id, 'secondary_500k' parameter, as_of_dt, brand, month_id,sum(amount_mtd) amount_mtd,sum(amount_lmtd) amount_lmtd
from c_java.nw_dse_kpi_tracker a  
where a.month_id=strleft('${var:dt_id}',6) and a.brand="IM3"
and parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
) b
right join map_outlet_java a on b.organization_id=a.outlet_code
union all
---CVM Participant
select a.outlet_code, 'cvm_ret_hits_5k' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
case when b.parameter="cvm_ret_hits_5k" and amount_mtd >= 3 then 1 else 0 end amount_mtd,
case when b.parameter="cvm_ret_hits_5k" and amount_lmtd >= 3 then 1 else 0 end amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on a.outlet_code=b.organization_id and b.month_id=strleft('${var:dt_id}',6) and b.brand="IM3" and b.parameter = "cvm_ret_hits_5k"
),

---KPI FOR NOVEMBER 2024---
kpi_nov as(
---osa dse
    select a.outlet_code, a.dse_code, 'osa_amt' parameter, strright('${var:dt_id}',2) as_of_dt, 'IM3' brand, strleft('${var:dt_id}',6) month_id,
    nvl(sum(case when strleft(b.dt_id,6) = strleft('${var:dt_id}',6) then b.metric end),0) amount_mtd,
    nvl(sum(case when strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') then b.metric end),0) amount_lmtd
from c_java.omn_outletwise b
right join map_outlet_java a 
on a.outlet_code=b.organization_id 
and b.operator_id=a.dse_code 
and ((strleft(b.dt_id,6) = strleft('${var:dt_id}',6) and b.dt_id <= '${var:dt_id}')  
    or (strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') and b.dt_id <= from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1), 'yyyyMMdd'))
    )
and b.brand="IM3"
and b.kpi_code = "osa_amt"
group by 1,2,3,4,5,6
union all
---secondary
select 
a.outlet_code, 
a.dse_code, 
'secondary' parameter, 
strright('${var:dt_id}',2) as_of_dt, 
'IM3' brand, 
strleft('${var:dt_id}',6) month_id,
nvl(sum(case when strleft(b.dt_id,6) = strleft('${var:dt_id}',6) then b.metric end),0) amount_mtd,
nvl(sum(case when strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') then b.metric end),0) amount_lmtd
from c_java.omn_outletwise b
right join map_outlet_java a
on a.outlet_code=b.organization_id
--and b.operator_id=a.dse_code 
and ((strleft(b.dt_id,6) = strleft('${var:dt_id}',6) and b.dt_id <= '${var:dt_id}')  
    or (strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') and b.dt_id <= from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1), 'yyyyMMdd'))
    )
and b.brand="IM3"
and b.kpi_code in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5,6
)
select 
    a.region, a.area, a.branch, a.mpc_name, a.mpc_short_code, a.micro_cluster,
    a.supervisor_code, a.dse_code, b.outlet_code, a.outlet_name, a.dse_category, 
    a.site_id, a.lrs_flag,
    b.amount_mtd,
    b.amount_lmtd,
    b.as_of_dt, 
    b.brand,
    b.parameter, 
    b.month_id
from kpi_nov b
inner join map_outlet_java a on b.outlet_code=a.outlet_code and month_id=strleft('${var:dt_id}',6);