
# MySQL code for creating tables and triggers and populating tables


-- CREATING RELATIONS (DDL)

CREATE TABLE Alert (
	alertState tinyint AUTO_INCREMENT,
	alertColor enum('green', 'yellow', 'orange', 'red'),
	alertGuidelines tinytext,
	alertDescription enum('Level-1: Vigilance', 'Level-2: Early Warning', 'Level-3: Moderate Alert', 'Level-4: Maximum Alert'),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (alertState)
);


CREATE TABLE Region (
	region varchar(50),
	alertState tinyint DEFAULT 1,
	alertDate date DEFAULT (CURRENT_DATE),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (region, alertState, alertDate),
	FOREIGN KEY (alertState) REFERENCES Alert(alertState) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Address (
	addressId int AUTO_INCREMENT,
	address varchar(50),	# House number and street name
	city varchar(50),
	province varchar(30),
	postalCode varchar(10),
	region varchar(50),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (addressId),
	FOREIGN KEY (region) REFERENCES Region(region) ON DELETE CASCADE ON UPDATE CASCADE
);




CREATE TABLE Person (
	id int AUTO_INCREMENT,
	firstName varchar(30),
	lastName varchar(30),
	dateOfBirth date,
	medicareNumber varchar(14) UNIQUE,
	phoneNumber varchar(15),	
 	citizenship varchar(30),
	email varchar(255),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (id)
);


CREATE TABLE LivesAt (
	personId int,
	addressId int,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (personId, addressId),
	FOREIGN KEY (personId) REFERENCES Person(id) ON DELETE CASCADE ON UPDATE CASCADE,	
	FOREIGN KEY (addressId) REFERENCES Address(addressId) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IsParentOf (
	parentId int,
	childId int,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (parentId, childId),
	FOREIGN KEY (parentId) REFERENCES Person(id) ON DELETE CASCADE,
	FOREIGN KEY (childId) REFERENCES Person(id) ON DELETE CASCADE,	
	CHECK (parentId <> childId)
);


CREATE TABLE PublicHealthWorker (
	phwId int,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (phwId),
	FOREIGN KEY (phwId) REFERENCES Person(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PublicHealthCenter (
	phcId int AUTO_INCREMENT,
	phcName varchar(50),
	phcAddress varchar(255),
	phcPhoneNumber varchar(15),	
	webAddress varchar(255),	
	phcType enum('hospital', 'clinic', 'special installment'),
	methodOfTesting enum('appointment', 'walk-in', 'both'),
	drivethru tinyint,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (phcId)
);


CREATE TABLE WorksAt (
	phwId int,
	phcId int,
	startDateTime datetime,
	endDateTime datetime,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (phwId, phcId, startDateTime),
	FOREIGN KEY (phwId) REFERENCES PublicHealthWorker(phwId) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (phcId) REFERENCES PublicHealthCenter(phcId) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Diagnosis (
	personId int,
	testDate date,
	phcId int,
	phwId int,
	testResult enum('positive', 'negative'), 
	testResultDate date DEFAULT (CURRENT_DATE),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (personId, testResultDate),
	FOREIGN KEY (personId) REFERENCES Person(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (phwId) REFERENCES PublicHealthWorker(phwId) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (phcId) REFERENCES PublicHealthCenter(phcId) ON DELETE SET NULL ON UPDATE CASCADE
);



CREATE TABLE Messages (
	msgId int AUTO_INCREMENT,
	msgDate date DEFAULT (CURRENT_DATE),
	msgTime time DEFAULT (CURRENT_TIME),
	region varchar(50),
	personFirstName varchar(30),
	personLastName varchar(30),
	email varchar(255),
	oldAlertState tinyint,
	newAlertState tinyint,
	guidelines tinytext,
	msgDescription text,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (msgId),
	FOREIGN KEY (region) REFERENCES Region(region) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (oldAlertState) REFERENCES Alert(alertState) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (newAlertState) REFERENCES Alert(alertState) ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE HealthRecommendations (
	recId int AUTO_INCREMENT,
	recommendation text,
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (recId)
);


CREATE TABLE Symptoms (
	symptom varchar(100), 
	symptomType enum('main', 'other', 'non-listed'),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (symptom)
);

CREATE TABLE SymptomsHistory (
	shId int AUTO_INCREMENT,
	personId int, 
    dateTimeOfSymptom datetime DEFAULT (CURRENT_TIMESTAMP),
    testResultDate date NOT NULL,
    temperature decimal(3, 1),
    symptoms varchar(100),
	isDeleted tinyint NOT NULL DEFAULT 0,
	PRIMARY KEY (shId),
    FOREIGN KEY(personId, testResultDate) REFERENCES Diagnosis(personId, testResultDate) ON DELETE CASCADE
);




-- POPULATING TABLES (DML)

# ALERT
INSERT INTO Alert (alertColor, alertGuidelines, alertDescription) VALUES ('green', 'Basic Measures', 'Level-1: Vigilance');
INSERT INTO Alert (alertColor, alertGuidelines, alertDescription) VALUES ('yellow', 'Strengthened Basic Measures', 'Level-2: Early Warning');
INSERT INTO Alert (alertColor, alertGuidelines, alertDescription) VALUES ('orange', 'Intermediate Measures', 'Level-3: Moderate Alert');
INSERT INTO Alert (alertColor, alertGuidelines, alertDescription) VALUES ('red', 'Maximum Measures', 'Level-4: Maximum Alert');

# REGION
INSERT INTO Region (region, alertDate) VALUES ('Montreal', '2020-12-21');
INSERT INTO Region (region, alertDate) VALUES ('Monteregie', '2021-01-14');

# ADDRESS
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('1111 Dagenais St', 'Dorval', 'Quebec', '1P1 H3H', 'Montreal');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('2222 Maple St', 'Montreal-Nord', 'Quebec', 'H4C 3E5', 'Montreal');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('95 Robert St', 'Brossard', 'Quebec', 'J4X 1E2', 'Monteregie');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('888 Saint-Urbain St', 'Outremont', 'Quebec', 'H2Z 1Y6', 'Montreal');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('836 Rue Constantin', 'Longueuil', 'Quebec', 'J4K 4R7', 'Monteregie');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('435 Ardwell Ave', 'Mount-Royal', 'Quebec', 'H3P 1T8', 'Montreal');
INSERT INTO Address (address, city, province, postalCode, region) VALUES ('7800 Berri St', 'Outremont', 'Quebec', 'H2R 2G9', 'Montreal');



# PERSON
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('John', 'Doe', '1963-10-08', 'DOEJ 6311 0811', '5141231111', 'Canadian', 'john.doe@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Jane', 'Doe', '1967-05-25', 'DOEJ 6711 2511', '5141241111', 'Canadian', 'jane.doe@gmail.com');

# Assumption: Macdonald family has no landline phone and kids do not own cell phones.
# Assumption: 6 year olds do not have email addresses.
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Roger', 'Macdonald', '1981-01-01', 'MACR 8122 0122', '5143212222', 'Canadian', 'roger.macdonald@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Roxanne', 'Mills', '1982-02-02', 'MILR 8222 0222', '5144212222', 'Canadian', 'roxanne.mills@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Riley', 'Macdonald', '2010-03-03', 'MACR 1022 0322', '', 'Canadian', 'riley.macdonald@gmail.com');	
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Randall', 'Macdonald', '2015-04-04', 'MACR 1522 0422', '', 'Canadian', '');

# Assumption: Rice family has no landline phone and young kids do not own cell phones.
# Assumption: 6 year olds do not have email addresses.
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Lukas', 'Rice', '1985-05-05', 'RICL 8533 0533', '5149253333', 'Canadian', 'lukas.rice@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Luna', 'Rice', '1984-06-06', 'RICL 8433 0633', '5149263333', 'Canadian', 'luna.rice@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Lily', 'Rice', '1957-07-07', 'RICL 5733 0733', '5149273333', 'Canadian', 'lily.rice@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Lincoln', 'Rice', '2014-08-08', 'RICL 1433 0833', '', 'Canadian', '');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Laney', 'Rice', '2014-08-08', 'RICL 1433 0838', '', 'Canadian', '');

INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Wukong', 'Sun', '1999-09-09', 'SUNW 9944 0944', '5149504444', 'Chinese', 'sun.wukong@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Seng', 'Tang', '1970-10-10', 'TANS 7044 1044', '5141504444', 'Chinese', 'tang.seng@gmail.com');

INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Matthias', 'Cederberg', '2000-11-11', 'CEDM 0055 1155', '5141115555', 'Canadian', 'matthias.cederberg@gmail.com');
INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Michael', 'Cabot', '2000-12-12', 'CABM 0055 1255', '5141215555', 'Canadian', 'michael.cabot@gmail.com');

INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Alya', 'Alphonse', '1956-03-28', 'ALPA 5666 0366', '5145286666', 'Canadian', 'alya.alphonse@gmail.com');

INSERT INTO Person (firstName, lastName, dateOfBirth, medicareNumber, phoneNumber, citizenship, email) VALUES ('Thomas', 'Bondevik', '1992-05-31', 'BONT 9277 0577', '5144507777', 'Canadian', 'thomas.bondevik@gmail.com');



# LIVESAT
INSERT INTO LivesAt (personId, addressId) VALUES (1, 1);
INSERT INTO LivesAt (personId, addressId) VALUES (2, 1);
INSERT INTO LivesAt (personId, addressId) VALUES (3, 2);
INSERT INTO LivesAt (personId, addressId) VALUES (4, 2);
INSERT INTO LivesAt (personId, addressId) VALUES (5, 2);
INSERT INTO LivesAt (personId, addressId) VALUES (6, 2);
INSERT INTO LivesAt (personId, addressId) VALUES (7, 3);
INSERT INTO LivesAt (personId, addressId) VALUES (8, 3);
INSERT INTO LivesAt (personId, addressId) VALUES (9, 3);
INSERT INTO LivesAt (personId, addressId) VALUES (10, 3);
INSERT INTO LivesAt (personId, addressId) VALUES (11, 3);
INSERT INTO LivesAt (personId, addressId) VALUES (12, 4);
INSERT INTO LivesAt (personId, addressId) VALUES (13, 4);
INSERT INTO LivesAt (personId, addressId) VALUES (14, 5);
INSERT INTO LivesAt (personId, addressId) VALUES (15, 5);
INSERT INTO LivesAt (personId, addressId) VALUES (16, 6);
INSERT INTO LivesAt (personId, addressId) VALUES (17, 7);



# IS PARENT OF
INSERT INTO IsParentOf (parentId, childId) VALUES (3, 5);
INSERT INTO IsParentOf (parentId, childId) VALUES (3, 6);
INSERT INTO IsParentOf (parentId, childId) VALUES (4, 5);
INSERT INTO IsParentOf (parentId, childId) VALUES (4, 6);
INSERT INTO IsParentOf (parentId, childId) VALUES (7, 10);
INSERT INTO IsParentOf (parentId, childId) VALUES (7, 11);
INSERT INTO IsParentOf (parentId, childId) VALUES (8, 10);
INSERT INTO IsParentOf (parentId, childId) VALUES (8, 11);
INSERT INTO IsParentOf (parentId, childId) VALUES (9, 7);
INSERT INTO IsParentOf (parentId, childId) VALUES (13, 12);
INSERT INTO IsParentOf (parentId, childId) VALUES (16, 17);


# PUBLIC HEALTH WORKER
INSERT INTO PublicHealthWorker (phwId) VALUES (2);
INSERT INTO PublicHealthWorker (phwId) VALUES (3);
INSERT INTO PublicHealthWorker (phwId) VALUES (8);
INSERT INTO PublicHealthWorker (phwId) VALUES (9);
INSERT INTO PublicHealthWorker (phwId) VALUES (12);
INSERT INTO PublicHealthWorker (phwId) VALUES (13);
INSERT INTO PublicHealthWorker (phwId) VALUES (14);
INSERT INTO PublicHealthWorker (phwId) VALUES (15);
INSERT INTO PublicHealthWorker (phwId) VALUES (16);
INSERT INTO PublicHealthWorker (phwId) VALUES (17);


# PUBLIC HEALTH CENTER
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Viau Public Health Center', '4750 Rue Jarry E, Saint-Leonard, Quebec', '5143267203', 'viau.publichealthcenter@gmail.com', 'special installment', 'walk-in', 0);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Lakeshore General Hospital', '160 Ave Stillview Suite 1297, Pointe-Claire, Quebec', '5146302225', 'info@fondationlakeshore.ca', 'hospital', 'both', 1);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Jewish General Hospital', '3755 Chemin de la Cote-Sainte-Catherine, Montreal, Quebec', '5143408222', 'jgh@gmail.com', 'hospital', 'both', 1);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Royal Victoria Hospital', '1001 Decarie Blvd, Montreal, Quebec', '5149341934', '', 'hospital', 'both', 0);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Sainte-Anne\'s Hospital', '305 Boul des Anciens-Combattants, Sainte-Anne-de-Bellevue, Quebec', '5144573440', 'informations.comtl@ssss.gouv.qc.ca.', 'hospital', 'appointment', 0);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Centre de Sante Medicentre Pincourt', '88 5e Ave, Pincourt, Quebec', '5144251000', '', 'clinic', 'both', 1);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Polyclinique Medicale Vaudreuil Inc.', '600 Boulevard Harwood, Vaudreuil-Dorion, Quebec', '4504559301', '', 'clinic', 'both', 1);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Clinique Mediplex', '15610 Boul Gouin O, Sainte-Genevieve, Quebec', '5146754554', 'info@cliniquemediplex.com', 'clinic', 'both', 0);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Statcare Emergency Clinic', '175 Ave Stillview Suite 104, Pointe-Claire, Quebec', '5146949282', '', 'clinic', 'appointment', 1);
INSERT INTO PublicHealthCenter (phcName, phcAddress, phcPhoneNumber, webAddress, phcType, methodOfTesting, drivethru) VALUES ('Clinique Globuline', '168 Avenue Saint-Charles Vaudreuil-Dorion, Quebec', '4504248444', 'info@clinique-globuline.com', 'clinic', 'walk-in', 0);


# WORKS AT
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (3, 1, '2020-12-12 08:00:00', '2020-12-12 17:00:00');	# Roger Macdonald works at Viau Public Health Center
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (8, 1, '2020-12-19 09:00:00', '2020-12-19 18:00:00');	# Viau Public Health Center
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (14, 10, '2020-12-20 08:00:00', '2020-12-20 17:00:00');	# Clinique Globuline
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (3, 1, '2021-01-08 08:00:00', '2021-01-08 17:00:00');	# Viau Public Health Center
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (2, 2, '2021-01-07 06:00:00', '2021-01-07 14:00:00');	# Lakeshore General Hospital
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (13, 7, '2021-01-10 01:00:00', '2021-01-10 12:00:00');	# Polyclinique Medicale Vaudreuil Inc.
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (12, 2, '2021-01-10 08:00:00', '2021-01-10 19:00:00');	# Lakeshore General Hospital
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (9, 3, '2021-01-13 00:00:00', '2021-01-13 08:00:00');	# Jewish General Hospital
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (15, 4, '2021-01-15 22:00:00', '2021-01-16 16:00:00');	# Royal Victoria Hospital
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (16, 5, '2021-01-18 06:00:00', '2021-01-18 14:00:00');	# Sainte-Anne's Hospital
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (17, 9, '2021-01-20 20:00:00', '2021-01-21 08:00:00');	# Statcare Emergency Clinic
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (13, 6, '2021-01-22 10:00:00', '2021-01-22 18:00:00');	# Centre de Sante Medicentre Pincourt
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (14, 8, '2021-01-24 08:00:00', '2021-01-24 17:00:00');	# Clinique Mediplex
INSERT INTO WorksAt (phwId, phcId, startDateTime, endDateTime) VALUES (3, 1, '2021-01-24 08:00:00', '2021-01-24 17:00:00');	# Viau Public Health Center


# DIAGNOSIS
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (1, '2020-12-12', 1, 3, 'negative', '2020-12-15');	# John Doe is getting a disgnosis done by Roger Macdonald at Viau Public Health Center
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (2, '2020-12-19', 1, 8, 'negative', '2020-12-22');	# Viau Public Health Center
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (9, '2020-12-20', 10, 14, 'negative', '2020-12-23');	# Clinique Globuline
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (3, '2021-05-07', 2, 2, 'positive', '2021-05-10');	# Lakeshore General Hospital
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (4, '2021-01-07', 2, 2, 'positive', '2021-01-10');	# Lakeshore General Hospital
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (5, '2021-01-07', 2, 2, 'negative', '2021-01-10');	# Lakeshore General Hospital
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (6, '2021-01-07', 2, 2, 'negative', '2021-01-10');	# Lakeshore General Hospital
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (14, '2021-01-08', 1, 3, 'positive', '2021-01-10');	# Viau Public Health Center
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (8, '2021-01-24', 8, 14, 'positive', '2021-01-27');	# Clinique Mediplex
INSERT INTO Diagnosis (personId, testDate, phcId, phwId, testResult, testResultDate) VALUES (9, '2021-01-24', 8, 14, 'negative', '2021-01-27');	# Clinique Mediplex


# HEALTH RECOMMENDATIONS
INSERT INTO HealthRecommendations (recommendation) VALUES ('Do not go to school, work, a childcare center or any other public space.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Do not use public transport.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('If the sick person lives alone and has no help to get essentials such as food or medication, use phone/online grocery and pharmacy home delivery services.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Do not receive visitors at home.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('If the sick person lives with other people who are not infected by COVID-19:
	o remain alone in one room of the house as often as possible and close to the door.
	o eat and sleep alone in one room of the house.
	o if possible, use a bathroom reserved for the sick person sole use. Otherwise, disinfect the bathroom after every use.
	o avoid as much as possible contact with other people in the home. If this is impossible, wear a mask. If a mask is not available, stay at least two meters away from other people');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Open a window to air out the sick person\'s room and home often (weather permitting).');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Do not go to a medical clinic unless you have first obtained an appointment and have notified the clinic that you have COVID-19. If you need to go to the emergency room (eg, if you have difficulty breathing), contact 911 and tell the person that you are sick with COVID-19.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Wear a mask when someone is in the same room as you.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Wear a mask if you must leave your home to seek medical care, you must first notify the medical clinic (or 911, if it is an emergency) that you have COVID-19.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('If you need to cough, sneeze, or blow your nose: 
	o If you have a disposable tissue use it to cough, sneeze or blow your nose then discard the tissue in the garbage, and then wash your hands with soap and water.
	o If you do not have disposable tissues, cough, or sneeze in the crook of your arm.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Wash your hands:
	o Wash your hands often with soap under warm running water for at least 20 seconds.
	o Use an alcohol-based hand rub if soap and water are not available.
	o Wash your hands before eating and whenever your hands look dirty.
	o After using the toilet, put the lid down before flushing and then wash your hands.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Do not share plates, utensils, glasses, towels, bed sheets or clothes with others.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Watch your symptoms and take your temperature every day:
	o Take your temperature every day at the same hour.
	o If you are taking medication for fever wait at least four hours before taking your temperature.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('Directives in case of severe symptoms:
	o If your symptoms worsen call 514-644-4545 or call your doctor.
	o If you have difficulty breathing, or shortness of breath or chest pain call 911 and inform them you may be infected by COVID-19.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('If someone close or caregiver helps you with your daily activities, then before helping you, the person must wash his/her hand, wear a mask and put-on disposable gloves. After helping you, the person must take off the gloves and put them in a garbage bin with a lid, wash his/her hands, take off the mask and put it in a garbage bin with a lid, and wash his/her hands again.');
INSERT INTO HealthRecommendations (recommendation) VALUES ('For help with psychosocial matters, contact 811.');



# SYMPTOMS
INSERT INTO Symptoms (symptom, symptomType) VALUES ('fever (temperature exceeding 38.1 degrees Celsius or 100.6 degrees Fahrenheit)', 'main');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('cough', 'main');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('shortness of breath or difficulty breathing', 'main');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('loss of taste and smell', 'main');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('nausea', 'other');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('stomach aches', 'other');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('vomiting', 'other');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('muscle pain', 'other');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('diarrhea', 'other');
INSERT INTO Symptoms (symptom, symptomType) VALUES ('sore throat', 'other');








-- TRIGGERS

CREATE TRIGGER sendAlertMsg 
AFTER INSERT ON Region
FOR EACH ROW
INSERT INTO Messages (region, personFirstName, personLastName, email, oldAlertState, newAlertState, guidelines, msgDescription)
SELECT DISTINCT a.region, p.firstName, p.lastName, p.email, (SELECT r.alertState FROM Region r WHERE r.alertState IS NOT NULL AND r.region = NEW.region AND r.alertDate = (SELECT r.alertDate FROM Region r WHERE r.region = NEW.region ORDER BY alertDate DESC LIMIT 1, 1)), NEW.alertState, al.alertGuidelines, al.alertDescription FROM Address a
INNER JOIN LivesAt la ON la.addressId = a.addressId 
INNER JOIN Person p ON p.id = la.personId
INNER JOIN Region r ON r.region = NEW.region AND r.region = a.region
INNER JOIN Alert al ON al.alertState = NEW.alertState;


DELIMITER //
CREATE TRIGGER sendTestResult
AFTER INSERT ON Diagnosis
FOR EACH ROW
BEGIN
	INSERT INTO Messages (region, personFirstName, personLastName, email, msgDescription)
	SELECT DISTINCT a.region, p.firstName, p.lastName, p.email, IF(NEW.testResult = 'negative', 'COVID-19 Test result negative', 'COVID-19 Test result positive') AS 'Test Result' FROM Diagnosis d
	INNER JOIN Person p ON p.id = d.personId AND p.id = NEW.personId
	INNER JOIN LivesAt la ON p.id = la.personId
	INNER JOIN Address a ON a.addressId = la.addressId 
	INNER JOIN Region r ON r.region = a.region;
	SET SESSION group_concat_max_len = 999999999;

	UPDATE Messages SET Messages.msgDescription = CONCAT(Messages.msgDescription, '\nPlease follow the following instructions to prevent the spread of COVID-19 to people around you:\n', (SELECT GROUP_CONCAT(recommendation SEPARATOR '\n') FROM HealthRecommendations))
	WHERE Messages.msgDescription = 'COVID-19 Test result positive';
END;
DELIMITER ;

