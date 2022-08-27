WITH adoption_quarters AS
    (
        SELECT 	species,
		    MAKE_DATE (	CAST (DATE_PART ('year', adoption_date) AS INT),
					CASE 
						WHEN DATE_PART ('month', adoption_date) < 4
							THEN 1
						WHEN DATE_PART ('month', adoption_date) BETWEEN 4 AND 6
							THEN 4
						WHEN DATE_PART ('month', adoption_date) BETWEEN 7 AND 9
							THEN 7
						WHEN DATE_PART ('month', adoption_date) > 9
							THEN 10
					END,
					1
	                   ) AS quarter_start
        FROM 	adoptions
    ),

quarterly_adoptions_table AS
    (
        SELECT species,
               quarter_start,
               COUNT (*) AS quarterly_adoptions,
               COUNT (*) - COALESCE (
					-- For quarters with no previous adoptions use 0, not NULL
							 	FIRST_VALUE(COUNT (*))
							 	OVER (PARTITION BY species
							 		  ORDER BY quarter_start ASC
								   	  RANGE BETWEEN 	INTERVAL '3 months' PRECEDING
														AND
														INTERVAL '3 months' PRECEDING
						 			 )
							, 0) AS adoption_difference_in_quarters
        FROM adoption_quarters
        GROUP BY species,
                 quarter_start
        UNION ALL
        SELECT 'All species',
               quarter_start,
               COUNT (*) AS quarterly_adoptions,
               COUNT (*) - COALESCE (
					-- For quarters with no previous adoptions use 0, not NULL
							 	FIRST_VALUE(COUNT (*))
							 	OVER (ORDER BY quarter_start ASC
								   	  RANGE BETWEEN 	INTERVAL '3 months' PRECEDING
														AND
														INTERVAL '3 months' PRECEDING
						 			 )
							, 0) AS adoption_difference_in_quarters
        FROM adoption_quarters
        GROUP BY quarter_start),

quarterly_adoptions_with_zeros_for_first_adoption AS
    (
        SELECT species,
               quarter_start,
               quarterly_adoptions,
        CASE
           WHEN quarter_start = first_value(quarter_start)
               OVER (
                    PARTITION BY species
                    ORDER BY quarter_start) THEN 0
           ELSE adoption_difference_in_quarters
        END AS adoption_difference_in_quarters
        FROM quarterly_adoptions_table
                    ),

quarterly_adoptions_ranked AS
    (
        SELECT *,
               RANK()
                   OVER (
                        PARTITION BY species
                        ORDER BY adoption_difference_in_quarters DESC, quarter_start DESC
                        ) AS ranking
        FROM quarterly_adoptions_with_zeros_for_first_adoption
    )

SELECT species,
       CAST(DATE_PART ('year', quarter_start) AS INT) AS year,
       CAST (DATE_PART ('quarter', quarter_start) AS INT) AS quarter,
       quarterly_adoptions,
       adoption_difference_in_quarters,
       ranking
FROM quarterly_adoptions_ranked
WHERE ranking <= 5
ORDER BY 	species ASC,
			adoption_difference_in_quarters DESC,
			quarter_start ASC;





		