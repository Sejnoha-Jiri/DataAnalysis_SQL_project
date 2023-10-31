# DataAnalysis_SQL_project
Project for Engeto data analysis course - SQL part

Prerequisites - MariaDB - Relational database management system (for of MySQL) (Download and install MariaDB from **[here](https://mariadb.org/download/)**.)
              - Dbeaver - SQL client tool (Download and install Dbeaver from MariaDB prompt or **[here](https://dbeaver.io/download/)**.)
              - Imported Engeto database (To import the DB, create an empty db)
                                         (Empty DB - open Dbeaver, click "database", "new database connection", "MariaDB", "Next", Set database name to "Engeto", (adjust port if necessary), "Finish"
                                         (Right click "Engeto", "Tools", "restore database", locate the db, "Start")
File description - t_jiri_sejnoha_project_SQL_primary_final.sql - This script creates table t_jiri_sejnoha_project_SQL_primary_final table that contains all data needed for asnwering all questions below
                 -  t_jiri_sejnoha_project_SQL_research_final.sql - This script creates individual temporary tables for adjusting the data and tables that contain answers to the individual questions below
Questions and answers - Question 1 - Have wages grown in all industry branches over the years, or do some of them decrease?
                          Answer 1 - The wage decreased in almost every industry in the recorded years, except "Transportation and Warehousing", "Other Activities", "Healthcare and Social Care" and "Manufacturing Industry".
                        Question 2 - How many liters of milk and kilograms of bread can be bought for the first and last recorded period of available prices and wages
                          Answer 2 - 
                        Question 3 - Which produce category is experiencing the slowest price increase? (Which has the slowest percentage increase per year)
                          Answer 3 - The slowest increase has been recorded for granulated sugar at average 1.77% decrease.
                        Question 4 - Has a year, where the price increase was at least 10% higher than wage increase, been recorded?
                          Answer 4 - There wasn't any year that had 10% difference between the increase of wages and prices, the highest difference occured in year 2009, the difference was 8.49%.
                        Question 5 - Does the GDP's value affect wage and food prices? If GDP rises significantly in one year, will it be reflected in food prices or wage in the same or subsequent year with a more significant increase?
                          Answer 5 - Upon closer inspection, the values do not show any direct causal relationship.
