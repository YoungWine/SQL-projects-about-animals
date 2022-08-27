# SQL-projects
Here are a database that contains various information about animals who are under an animal shelter's care.

The first task is:
Write a query that return the top 25% of animals per species that had the fewest "temperature exceptions". Ignore animals that had no routine checkuos.

A "temperature exceptions" is a checkup temperature measurement that is either equal to or exceeds +/- 0.5% from the species' average.

If two or more animals of the same species have the same number of temperature exceptions, those with the more recent exceptions should be returned.

There is no need to return additional ried animals over the 25% mark.

If the number of animals for species does not divide by 4 without remainder, you may return 1 more animal, but not less.

The second task is:
Write a query that return top 5 most improved quarters in terms of the number of adoptions, both per species, and overall.

Improvement means the increase in number of adoptions compared to the previous calendar quarter,

The first quarter in which animals were adopted for each species, and for all species, does not constitute an improvement from zero, and should be treated as no improvement.

In case there are quarters that are tied in terms of adoption improvement, terurn the most recent ones.
