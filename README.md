# COVID-19-Database-System

<details open="open">
  <summary>Table of Contents</summary>
  <ul>
    <li>
      <a href="#about-the-project">About the Project</a>
      <ol>
        <li><a href="#development">Development</a></li>
        <li><a href="#built-with">Built With</a></li>
        <li>
          <a href="#tables-in-covid19_phcs-database">Tables in covid19_phcs Database</a>
          <ul>
            <li><a href="#alert">Alert</a></li>
            <li><a href="#region">Region</a></li>
            <li><a href="#address">Address</a></li>
            <li><a href="#person">Person</a></li>
            <li><a href="#livesAt">LivesAt</a></li>

          </ul>
        </li>
      </ol>
    </li>
    <li>
      <a href="#sample-output">Sample Output</a>
    </li>
  </ul>
</details>  
  
  
## About the Project
Worked collaboratively in a team of three developers via Github to develop a database system called COVID-19 Public Health Care
System (covid19_phcs). A graphic user interface was also provided to make it easier for users to interact with the system.
The goal of the application was to help the public health administration monitor and control the spread of COVID-19.

The application must maintain personal information about the population involved in the
pandemic whether infected or not, information about Public Health workers involved in
the PCR tests (Polymerase Chain Reaction tests), information about Public Health
facilities where the PCR tests are performed, and the diagnostic results. 

### Development
This web application portion of the project was developed in Microsoft's Visual Studio Code. 
The database portion was built in DBeaver.

### Built With  
* MySQL
* PHP 
* JavaScript (jQuery)
* HTML


### Tables in the covid19_phcs database

#### Alert
The Alert table describes the four alert states: green, yellow, orange, red.

#### Region
The Region table maintains an alert history of alerts for a given region (e.g., Montreal, Monteregie, Laurentides, etc.).

#### Address
The Address table holds information such as house number, street name, city, etc. It also has field for the corresponding region. This way, 
if the alert state for a region changes, all individuals with addresses belonging in that region can be notified.

#### Person
The Person table holds personal information for an individual such as first name, last name, medicare number, date of birth, email, etc.

#### LivesAt
The LivesAt table represents the relationship between a Person and their Address.

#### IsParentOf













