WITH checkups_with_temperature_differences AS
    (
        SELECT 	species,
		name,
		temperature,
		checkup_time,
		CAST ( 	AVG (temperature)
				OVER (PARTITION BY species)
			 	AS DECIMAL (5,2)
			 ) AS species_average_temperature,
		CAST (	temperature - 	AVG (temperature)
								OVER (PARTITION BY species)
			 	AS DECIMAL (5, 2)
			 ) AS difference_from_average
        FROM 	routine_checkups
    )

,temperature_differences_with_exception_indicator AS
    (
        SELECT	*,
		CASE
		WHEN ABS (difference_from_average / species_average_temperature) >= 0.005
			THEN 1
		    ELSE 0
		END AS is_temperature_exception
        FROM 	checkups_with_temperature_differences
    )

,grouped_animals_with_exceptions AS
    (
        SELECT species,name,
        SUM(is_temperature_exception) as number_of_exceptions,
        MAX( CASE
             WHEN is_temperature_exception = 1 THEN checkup_time
             ELSE NULL
             END) as latest_exception
        FROM temperature_differences_with_exception_indicator
        GROUP BY species,name)

, animal_exceptions_with_ntile as
    (
        SELECT *,
        NTILE(4) OVER (PARTITION BY species ORDER BY number_of_exceptions ASC,
        latest_exception DESC)
        FROM grouped_animals_with_exceptions
    )


SELECT 	species,
		name,
		number_of_exceptions,
		latest_exception
FROM 	animal_exceptions_with_ntile
WHERE 	ntile = 1
ORDER BY 	species ASC,
			number_of_exceptions ASC,
			latest_exception DESC;


