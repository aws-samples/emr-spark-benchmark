select 
 query_nm ,arm_kv1[1] AS it1_arm_tt,arm_kv1[2] AS it2_arm_tt,arm_kv1[3] AS it3_arm_tt,arm_kv1[4] AS it4_arm_tt,arm_kv1[5] AS it5_arm_tt,arm_kv1[6] AS it6_arm_tt,arm_kv1[7] AS it7_arm_tt,arm_kv1[8] AS it8_arm_tt,arm_kv1[9] AS it9_arm_tt,arm_kv1[10] AS it10_arm_tt
 ,x86_kv1[1] AS it1_x86_tt,x86_kv1[2] AS it2_x86_tt,x86_kv1[3] AS it3_x86_tt,x86_kv1[4] AS it4_x86_tt,x86_kv1[5] AS it5_x86_tt,x86_kv1[6] AS it6_x86_tt,x86_kv1[7] AS it7_x86_tt,x86_kv1[8] AS it8_x86_tt,x86_kv1[9] AS it9_x86_tt,x86_kv1[10] AS it10_x86_tt
 from
(SELECT query_nm, map_agg(rnk1 , Arm_Total_time) arm_kv1, map_agg(rnk1, x86_Total_time) x86_kv1
 from
 (
 select x.rnk1,x.query_nm,x.iteration,x.optimizationtime as arm_optimizationtime,x.planningtime as arm_planningtime,x.executiontime as arm_executiontime, (x.optimizationtime+x.planningtime+x.executiontime) as Arm_Total_time,y.optimizationtime as x86_optimizationtime,y.planningtime as x86_planningtime,y.executiontime as x86_executiontime, (y.optimizationtime+y.planningtime+y.executiontime) as x86_Total_time from
  (
  SELECT row_number() over(partition by element_at(results, 1).name order by timestamp) as rnk1, iteration, element_at(results, 1).name AS query_nm,
element_at(results, 1).parsingtime as parsingtime,element_at(results, 1).analysistime as analysistime,element_at(results, 1).optimizationtime as optimizationtime,element_at(results, 1).planningtime as  planningtime,element_at(results, 1).executiontime as executiontime
FROM "spark_benchmark_results"."emr_serverless_spark_graviton2_detail"
  where iteration >0
  ) x
  join 
   (
  SELECT  row_number() over(partition by element_at(results, 1).name order by timestamp) as rnk1,timestamp,iteration, element_at(results, 1).name AS query_nm,
element_at(results, 1).parsingtime as parsingtime,element_at(results, 1).analysistime as analysistime,element_at(results, 1).optimizationtime as optimizationtime,element_at(results, 1).planningtime as  planningtime,element_at(results, 1).executiontime as executiontime
FROM "spark_benchmark_results"."emr_serverless_spark_x86_detail"
  where iteration >0
  ) y
  on x.query_nm =y.query_nm and x.rnk1 = y.rnk1
)
group by 1) z
