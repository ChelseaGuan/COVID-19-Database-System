# MySQL code for displaying tables and performing specific queries



# Test trigger
INSERT INTO Region (region, alertState, alertDate) VALUES ('Monteregie', 2, '2021-04-14');
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (13, '2021-01-24', 2, 14, 'positive', '2021-03-04');



-- DISPLAYING TABLE CONTENTS

# ALERT
SELECT * 
FROM Alert;

# REGION
SELECT *
FROM Region
ORDER BY region, alertDate;

# PERSON
SELECT id, firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email, address, city, province, postalCode, region
FROM Person
LEFT JOIN LivesAt ON Person.id = LivesAt.personId
LEFT JOIN Address ON Address.addressId = LivesAt.addressId
WHERE Person.isDeleted=0;

# IS PARENT OF
SELECT *
FROM IsParentOf;
# Alternate, more concrete output
SELECT CONCAT(p.firstName, ' ', p.lastName) AS Parent, CONCAT(c.firstName, ' ', c.lastName) AS Child
FROM IsParentOf 
INNER JOIN Person p ON IsParentOf.parentId = p.id
INNER JOIN Person c ON IsParentOf.childId = c.id;

# GROUPZONE
SELECT * 
FROM GroupZone;
SELECT Person.firstName, Person.lastName, GroupZone.groupZoneName 
FROM Person, GroupZone
WHERE Person.id = GroupZone.personId
ORDER BY GroupZone.groupZoneName, Person.lastName, Person.firstName;

# PUBLIC HEALTH WORKER
SELECT *
FROM PublicHealthWorker;
# Alternate, more concrete output
SELECT *
FROM Person, PublicHealthWorker
WHERE Person.id = PublicHealthWorker.phwId;

# PUBLIC HEALTH CENTER
SELECT *
FROM PublicHealthCenter;

# WORKS AT
SELECT *
FROM WorksAt;
# Alternate, more concrete output
SELECT Person.firstName, Person.lastName, PublicHealthCenter.phcName, WorksAt.startDateTime, WorksAt.endDateTime
FROM Person, PublicHealthWorker, WorksAt, PublicHealthCenter 
WHERE Person.id = PublicHealthWorker.phwId AND PublicHealthWorker.phwId = WorksAt.phwId AND PublicHealthCenter.phcId = WorksAt.phcId
ORDER BY Person.lastName, Person.firstName;

# DIAGNOSIS
SELECT * 
FROM Diagnosis;
# Alternate, more concrete output
SELECT CONCAT(p.firstName, ' ', p.lastName) AS Patient, Diagnosis.testDate, PublicHealthCenter.phcName, PublicHealthCenter.phcAddress, CONCAT(phw.firstName, ' ', phw.lastName) AS Public_Health_Worker, Diagnosis.testResult, Diagnosis.testResultDate
FROM PublicHealthCenter, PublicHealthWorker, Diagnosis
INNER JOIN Person p ON Diagnosis.personId = p.id
INNER JOIN Person phw ON Diagnosis.phwId = phw.id
WHERE PublicHealthCenter.phcId = Diagnosis.phcId AND PublicHealthWorker.phwId = phw.id;

# MESSAGES
SELECT * 
FROM Messages;

# HEALTHRECOMMENDATIONS
SELECT * 
FROM HealthRecommendations;

# SYMPTOMS
SELECT * 
FROM Symptoms;

# SYMPTOMSHISTORY
SELECT firstName, lastName, dateTimeOfSymptom, testResultDate, temperature, symptoms
FROM Person, SymptomsHistory
WHERE id = personId;






-- QUERIES

# 8.
INSERT INTO SymptomsHistory (personId, dateTimeOfSymptom, testResultDate, temperature, symptoms) VALUES (
(SELECT Person.id FROM Person, Diagnosis WHERE Person.medicareNumber = '' AND Person.id = Diagnosis.personId AND Diagnosis.testResultDate = '2020-12-15'), 
'2020-12-12 08:00:00', '2020-12-15', 38.6, 'dry cough');

SELECT symptom 
FROM Symptoms 
WHERE (Symptoms.symptomType = 'main' OR Symptoms.symptomType = 'other') AND Symptoms.symptom = 'sd';

INSERT INTO Symptoms (symptom, symptomType) VALUES ('', 'non-listed');



# 9.
SELECT firstName, lastName, dateTimeOfSymptom, symptoms, testResultDate
FROM SymptomsHistory, Person 
WHERE SymptomsHistory.testResultDate = '2021-01-27' AND Person.id = SymptomsHistory.personId AND Person.medicareNumber = 'RICL 8433 0633' AND SymptomsHistory.isDeleted = 0 
ORDER BY dateTimeOfSymptom;


# 10.
SELECT * FROM Messages WHERE msgDate BETWEEN '2021-04-17' AND '2021-04-18' AND Messages.isDeleted=0;


# 11.
SELECT c.firstName, c.lastName, c.dateOfBirth, c.medicareNumber, c.phoneNumber, c.citizenship, c.email, GROUP_CONCAT(DISTINCT p.firstName, ' ', p.lastName SEPARATOR ', ') AS Parents
FROM Person p
INNER JOIN IsParentOf ON IsParentOf.parentId = p.id
INNER JOIN Person c ON IsParentOf.childId = c.id
	AND c.id IN (SELECT LivesAt.personId FROM LivesAt, Address WHERE Address.addressId = LivesAt.addressId AND Address.address = '95 Robert St')
GROUP BY c.firstName
UNION
SELECT c.firstName, c.lastName, c.dateOfBirth, c.medicareNumber, c.phoneNumber, c.citizenship, c.email, ('') AS Parents
FROM Person c
WHERE c.id NOT IN (SELECT IsParentOf.childId FROM IsParentOf)
	AND c.id IN (SELECT LivesAt.personId FROM LivesAt, Address WHERE Address.addressId = LivesAt.addressId AND Address.address = '95 Robert St')
GROUP BY c.firstName;


# 12.
SELECT phc.phcName, phc.phcAddress, (SELECT COUNT(*) FROM 
	(SELECT DISTINCT PublicHealthWorker.phwId FROM PublicHealthWorker
	INNER JOIN WorksAt ON WorksAt.phwId = PublicHealthWorker.phwId
	INNER JOIN PublicHealthCenter ON WorksAt.phcId = PublicHealthCenter.phcId AND PublicHealthCenter.phcName = phc.phcName
	WHERE PublicHealthWorker.isDeleted = 0
) AS phwList) AS phwCount, phc.methodOfTesting, IF(phc.drivethru=1, 'Available', 'Unavailable') AS 'Drive thru'
FROM PublicHealthCenter phc
WHERE phc.isDeleted = 0;


# 13.
SELECT region, city, GROUP_CONCAT(DISTINCT postalCode SEPARATOR ', ') 'Postal Codes' FROM Address
WHERE Address.isDeleted = 0
GROUP BY city
ORDER BY region;


# 14.
SELECT firstName, lastName, dateOfBirth, phoneNumber, email, testResultDate, testResult FROM Person, Diagnosis
WHERE Diagnosis.testResultDate = '2021-01-10' AND Person.id = Diagnosis.personId AND Diagnosis.isDeleted = 0
ORDER BY testResult ASC;


# 15.
SELECT DISTINCT firstName, lastName, PublicHealthCenter.phcName FROM Person
INNER JOIN PublicHealthWorker ON Person.id = PublicHealthWorker.phwId 
INNER JOIN WorksAt ON WorksAt.phwId = PublicHealthWorker.phwId
INNER JOIN PublicHealthCenter ON WorksAt.phcId = PublicHealthCenter.phcId AND PublicHealthCenter.phcName = "Viau Public Health Center"
WHERE PublicHealthWorker.isDeleted = 0;


# 16.
# (1)
SELECT firstName, lastName, Diagnosis.testResult, Diagnosis.testResultDate, PublicHealthCenter.phcName
FROM Person
INNER JOIN PublicHealthWorker ON PublicHealthWorker.phwId = Person.id
INNER JOIN Diagnosis ON Diagnosis.personId = PublicHealthWorker.phwId
INNER JOIN PublicHealthCenter ON PublicHealthCenter.phcId = Diagnosis.phcId
WHERE Diagnosis.testResult = "positive" and Diagnosis.testResultDate = "2021-01-10" and  PublicHealthCenter.phcName = "Viau Public Health Center" AND Person.isDeleted = 0

# (2)
SELECT firstName as employeeFirstName, lastName as employeeLastName, PublicHealthCenter.phcName, WorksAt.startDateTime as workedDateTime
FROM Person
INNER JOIN WorksAt ON Person.id = WorksAt.phwId
INNER JOIN PublicHealthCenter ON PublicHealthCenter.phcId = WorksAt.phcId
WHERE PublicHealthCenter.phcName = 'Viau Public Health Center' and WorksAt.startDateTime <= '2021-01-10' and WorksAt.startDateTime >= '2020-12-27' AND Person.isDeleted = 0
GROUP BY firstName, lastName;


# 17.
# (1)
SELECT region as RegionName, 
SUM(case when listOfPositives.testResult = 'positive' then 1 else 0 end) as PositiveCases, 
SUM(case when listOfPositives.testResult = 'negative' then 1 else 0 end) as NegativeCases 
FROM (
SELECT DISTINCT Address.region, Diagnosis.personId, testResult FROM Diagnosis 
INNER JOIN LivesAt ON Diagnosis.personId = LivesAt.personId 
INNER JOIN Address ON Address.addressId = LivesAt.addressId
where testResultDate >= '2020-12-15' AND testResultDate <= '2021-02-04'
) as listOfPositives
GROUP BY region;

# (2)
SELECT * 
FROM Region 
WHERE alertDate BETWEEN '2020-12-15' AND '2021-02-04' AND isDeleted=0
ORDER BY alertDate;







SET FOREIGN_KEY_CHECKS=0;
DROP TABLE Alert;
DROP TABLE Region;
DROP TABLE Address;
DROP TABLE Person;
DROP TABLE LivesAt;
DROP TABLE IsParentOf;
DROP TABLE GroupZone;
DROP TABLE PublicHealthWorker;
DROP TABLE PublicHealthCenter;
DROP TABLE WorksAt;
DROP TABLE Diagnosis;
DROP TABLE HealthRecommendations;
DROP TABLE Messages;
DROP TABLE Symptoms;
DROP TABLE SymptomsHistory;
SET FOREIGN_KEY_CHECKS=1;

