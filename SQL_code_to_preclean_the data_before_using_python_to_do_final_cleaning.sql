
--# check if there are any NULL values in the vaccination table(VAERSVAX2)

SELECT * FROM vaccine_test..VAERSVAX2 
WHERE VAX_NAME IS NULL

--# check if there are any NULL values in the vaccination table(VAERSDATA2)

SELECT COUNT(AGE_YRS) 
FROM vaccine_test..VAERSDATA2
WHERE DIED IS NULL

--# if so, change the NULL values for subjects who didn't die to N

UPDATE vaccine_test..VAERSDATA2
SET DIED = 'N'
WHERE DIED IS NULL


--# check that it worked


SELECT COUNT(AGE_YRS) 
FROM vaccine_test..VAERSDATA2
WHERE DIED = 'N'

SELECT * 
FROM vaccine_test..VAERSDATA2



--# convert dates into a single integer that is counted by the range 0-365

SELECT (MONTH(ONSET_DATE)*30 + DAY(ONSET_DATE)) 
FROM vaccine_test..VAERSDATA2

SELECT (MONTH(VAX_DATE)*30 + DAY(VAX_DATE)) 
FROM vaccine_test..VAERSDATA2



--# Take the difference and save it as SICKNESS_DURATION(the amount of time the sickness lasted)

SELECT  VAERS_ID, VAX_DATE, ONSET_DATE, NUMDAYS , (MONTH(ONSET_DATE)*30 + DAY(ONSET_DATE)) - (MONTH(VAX_DATE)*30 + DAY(VAX_DATE)) AS SICKNESS_DURATION
FROM vaccine_test..VAERSDATA2
WHERE (MONTH(ONSET_DATE)*30 + DAY(ONSET_DATE)) - (MONTH(VAX_DATE)*30 + DAY(VAX_DATE)) >= 0


--# add SICKNESS_DURATION to the table

ALTER TABLE vaccine_test..VAERSDATA2
ADD SICKNESS_DURATION Int

UPDATE vaccine_test..VAERSDATA2
SET SICKNESS_DURATION = (MONTH(ONSET_DATE)*30 + DAY(ONSET_DATE)) - (MONTH(VAX_DATE)*30 + DAY(VAX_DATE))




--# remove ONSET_DATE, VAX_DATE and NUMDAYS from the table


ALTER TABLE vaccine_test..VAERSDATA2
DROP COLUMN ONSET_DATE, NUMDAYS




--# delete the rows with negative sickness values 

DELETE FROM vaccine_test..VAERSDATA2 
WHERE SICKNESS_DURATION < 0 


--# We've got enough data to train a model so let's delete points  where SICKNESS_DURATION IS NULL


DELETE FROM vaccine_test..VAERSDATA2 
WHERE SICKNESS_DURATION IS NULL



--# Change null values to No for subjects with no vaccination record


UPDATE vaccine_test..VAERSDATA2
SET PRIOR_VAX = 'N'
WHERE PRIOR_VAX IS NULL


--# Change the rest to yes

UPDATE vaccine_test..VAERSDATA2
SET PRIOR_VAX = 'Y'
WHERE NOT PRIOR_VAX = 'N' 

--# do the same for HISTORY, OTHER_MEDS, CURRENT ILLNESS, ALLERGIES, RECOVERED

UPDATE vaccine_test..VAERSDATA2
SET HISTORY = 'N'
WHERE HISTORY IS NULL OR HISTORY LIKE '%n/a%'    


UPDATE vaccine_test..VAERSDATA2
SET HISTORY = 'Y'
WHERE NOT HISTORY = 'N' 



UPDATE vaccine_test..VAERSDATA2
SET OTHER_MEDS = 'N'
WHERE OTHER_MEDS IS NULL OR OTHER_MEDS = 'None' OR OTHER_MEDS = 'n/a'


UPDATE vaccine_test..VAERSDATA2
SET OTHER_MEDS = 'Y'
WHERE NOT OTHER_MEDS = 'N'



UPDATE vaccine_test..VAERSDATA2
SET CUR_ILL = 'N'
WHERE CUR_ILL IS NULL OR CUR_ILL = 'None' OR CUR_ILL = 'n/a' OR CUR_ILL = 'no' OR CUR_ILL = 'na' OR CUR_ILL LIKE 'none%' OR CUR_ILL LIKE 'unknown%' 



UPDATE vaccine_test..VAERSDATA2
SET CUR_ILL = 'Y'
WHERE NOT CUR_ILL = 'N'


UPDATE vaccine_test..VAERSDATA2
SET ALLERGIES = 'N'
WHERE ALLERGIES IS NULL OR ALLERGIES = 'None' OR ALLERGIES = 'n/a' OR ALLERGIES = 'no' OR ALLERGIES = 'na' OR ALLERGIES LIKE 'none%' OR ALLERGIES LIKE 'unknown%' 



UPDATE vaccine_test..VAERSDATA2
SET ALLERGIES = 'Y'
WHERE NOT ALLERGIES = 'N'



UPDATE vaccine_test..VAERSDATA2
SET RECOVD = 'N'
WHERE DIED = 'Y'

UPDATE vaccine_test..VAERSDATA2
SET RECOVD = 'N'
WHERE DIED = 'Y'

SELECT COUNT(RECOVD)
FROM vaccine_test..VAERSDATA2
WHERE RECOVD = 'U' OR RECOVD IS NULL



UPDATE vaccine_test..VAERSDATA2
SET RECOVD = 'None'
WHERE RECOVD IS NULL

--# replace the sickness duration with a more appropriate name start_date(our target variable) which identifies the onset time of adverse effects

ALTER TABLE vaccine_test..VAERSDATA2
ADD START_DATE varchar(255)

UPDATE vaccine_test..VAERSDATA2
SET START_DATE = SICKNESS_DURATION


ALTER TABLE vaccine_test..VAERSDATA2
DROP COLUMN SICKNESS_DURATION


UPDATE vaccine_test..VAERSDATA2
SET RECOVD = 'NONE'
WHERE RECOVD IS NULL

SELECT COUNT(VAERS_ID)
FROM vaccine_test..VAERSDATA2
WHERE STATE IS NULL

--# impute null age values with an average
UPDATE vaccine_test..VAERSDATA2
SET AGE_YRS = (SELECT ROUND(AVG(AGE_YRS),1)
			  FROM vaccine_test..VAERSDATA2)
WHERE AGE_YRS IS NULL

--# change Null to None for state names

UPDATE vaccine_test..VAERSDATA2
SET STATE = 'None'
WHERE STATE IS NULL



