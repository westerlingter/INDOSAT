with nbs_3id as (
    select *
from (
select a.partner_qr_cd,a.site_id, b.circle, b.region_circle, 
b.area, b.sales_area, b.micro_cluster, b.branch_kiosk_nm, b.branch_kiosk_id,
row_number() over (partition by a.partner_qr_cd order by a.mth_id desc) rn
from c_java.omn_tri_outlet_hirarki a
left join (select *
from biadm.ref_site_h3i_mth
where mth_id=strleft('${var:dt_id}',6) 
) b on a.site_id=b.site_id 
where a.mth_id=strleft('${var:dt_id}',6) 
) a
where a.rn =1
),
---visit unique dse 3id
--visit_unique_3id as (
--),
---mapping based on data hq
map_outlet_3id as (
    select distinct
    c.circle, c.region_circle, c.area, c.sales_area, c.micro_cluster, 
    b.retailer_qrcode, b.retailer_outlet_name, b.se_category, b.se_partnerid, 
    b.tm_partnerid, b.mp3_name, 
    b.mp3_partnerid, c.site_id, if(c.site_id=d.site_id,"LRS","NON LRS") lrs_flag
from c_java.omn_tri_outlet_map b
left join nbs_3id c
on b.retailer_qrcode=c.partner_qr_cd
left join c_java.ar_phoenix_site_lrs_ext d 
on c.site_id=d.site_id
where mth_id=(select max(mth_id) from c_java.omn_tri_outlet_map)
and c.circle="JAVA"
),
---mapping outlet 3id based on data SnD with LRS site
map_outlet_java as (
    select distinct a.brand, a.region, a.area, a.branch, a.mpc_name, a.mpc_short_code, a.micro_cluster,
    a.supervisor_code, a.dse_code, a.outlet_code, a.outlet_name, a.dse_category, 
    b.site_id, 
    if(b.site_id=c.site_id,"LRS","NON LRS") lrs_flag
--    if(a.outlet_code=d.visitedsaldomobo_orgid,"1","0") visit_unique 
from c_java.dse_outlet_map_ext a
left join nbs_3id b 
on cast(a.outlet_code as INT)=cast(b.partner_qr_cd as INT)
left join c_java.ar_phoenix_site_lrs_ext c 
on b.site_id=c.site_id
--left join visit_unique_3id d
--on a.dse_code=d.username
where a.month_id=(select max(month_id) from c_java.dse_outlet_map_ext)
and brand="3ID"
),

---KPI FOR OKTOBER 2024---
kpi_okt as (
---Sellin/FRC
select a.outlet_code, 'frc' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
nvl(b.amount_mtd,0) amount_mtd, nvl(b.amount_lmtd,0) amount_lmtd
--case when b.parameter="supply_inj_sp_hits" and amount_mtd >= 10 then 1 else 0 end amount_mtd,
--case when b.parameter="supply_inj_sp_hits" and amount_lmtd >= 10 then 1 else 0 end amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.organization_id as INT) and b.month_id=strleft('${var:dt_id}',6) and b.brand="TRI" and b.parameter = "supply_inj_sp_hits"
union all
---secondary
select a.outlet_code, 'secondary' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
sum(nvl(b.amount_mtd,0)) amount_mtd,sum(nvl(b.amount_lmtd,0)) amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.organization_id as INT) and b.month_id=strleft('${var:dt_id}',6) and b.brand="TRI" and b.parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
union all
---secondary 200k
select a.outlet_code, 'secondary_200k' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
case when b.amount_mtd>=200000 then 1 else 0 end amount_mtd,
case when b.amount_lmtd>=200000 then 1 else 0 end amount_lmtd
from (
select organization_id, 'secondary_200k' parameter, as_of_dt, brand, month_id,sum(amount_mtd) amount_mtd,sum(amount_lmtd) amount_lmtd
from c_java.nw_dse_kpi_tracker a  
where a.month_id=strleft('${var:dt_id}',6) and a.brand="TRI"
and parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
) b
right join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.organization_id as INT)
union all
---secondary 300k
select a.outlet_code, 'secondary_300k' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
case when b.amount_mtd>=300000 then 1 else 0 end amount_mtd,
case when b.amount_lmtd>=300000 then 1 else 0 end amount_lmtd
from (
select organization_id, 'secondary_300k' parameter, as_of_dt, brand, month_id,sum(amount_mtd) amount_mtd,sum(amount_lmtd) amount_lmtd
from c_java.nw_dse_kpi_tracker a  
where a.month_id=strleft('${var:dt_id}',6) and a.brand="TRI"
and parameter in ("secondary_saldo_amt","secondary_vou_amt","secondary_sp_amt")
group by 1,2,3,4,5
) b
right join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.organization_id as INT)
union all
---CVM Participant
select a.outlet_code, 'cvm_ret_hits_5k' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
case when b.parameter="cvm_ret_hits_5k" and amount_mtd >= 3 then 1 else 0 end amount_mtd,
case when b.parameter="cvm_ret_hits_5k" and amount_lmtd >= 3 then 1 else 0 end amount_lmtd
from c_java.nw_dse_kpi_tracker b
right join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.organization_id as INT) and b.month_id=strleft('${var:dt_id}',6) and b.brand="TRI" and b.parameter = "cvm_ret_hits_5k"
),

---KPI FOR NOVEMBER 2024---
kpi_nov as (
---osa dse
    select a.outlet_code, a.dse_code, 'osa_amt' parameter, strright('${var:dt_id}',2) as_of_dt, 'TRI' brand, strleft('${var:dt_id}',6) month_id,
    nvl(sum(case when strleft(b.dt_id,6) = strleft('${var:dt_id}',6) then b.metric end),0) amount_mtd,
    nvl(sum(case when strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') then b.metric end),0) amount_lmtd
from c_java.omn_outletwise b
right join map_outlet_java a 
on cast(a.outlet_code as INT)=cast(b.organization_id as INT)
and b.operator_id=a.dse_code 
and ((strleft(b.dt_id,6) = strleft('${var:dt_id}',6) and b.dt_id <= '${var:dt_id}')  
    or (strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') and b.dt_id <= from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1), 'yyyyMMdd'))
    )
and b.brand="TRI"
and b.kpi_code = "osa_amt"
group by 1,2,3,4,5,6
union all
---secondary
select 
a.outlet_code, 
a.dse_code, 
'secondary' parameter, 
strright('${var:dt_id}',2) as_of_dt, 
'TRI' brand, 
strleft('${var:dt_id}',6) month_id,
nvl(sum(case when strleft(b.dt_id,6) = strleft('${var:dt_id}',6) then b.metric end),0) amount_mtd,
nvl(sum(case when strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') then b.metric end),0) amount_lmtd
from c_java.omn_outletwise b
right join map_outlet_java a
on cast(a.outlet_code as INT)=cast(b.organization_id as INT)
--and b.operator_id=a.dse_code 
and ((strleft(b.dt_id,6) = strleft('${var:dt_id}',6) and b.dt_id <= '${var:dt_id}')  
    or (strleft(b.dt_id,6) = from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1),'yyyyMM') and b.dt_id <= from_timestamp(add_months(to_timestamp('${var:dt_id}','yyyyMMdd'),-1), 'yyyyMMdd'))
    )
and b.brand="TRI"
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
inner join map_outlet_java a on cast(a.outlet_code as INT)=cast(b.outlet_code as INT) and month_id=strleft('${var:dt_id}',6);
