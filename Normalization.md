Normalization is a process in database design that organizes data to reduce redundancy and improve data integrity. The term "normalized" refers to the structured and orderly arrangement of data according to a set of rules and standards known as normal forms. Each normal form progressively addresses specific types of redundancy and dependency issues, leading to a more efficient and consistent database structure.


## Example Workflow: Normalizing a Table with R

```r
# Raw data that is not in 1NF
raw_data <- data.frame(
  student_id = c(1, 2, 3),
  student_name = c("Alice", "Bob", "Charlie"),
  courses = c("Math, Science, History", "Math, English", "Science, History"),
  grades = c("A, B, C", "A, B", "A, C")
)

print(raw_data)
```

In this example, the courses and grades columns contain repeating groups (multiple values in a single cell), which means the data is not in 1NF. Each column should contain only atomic values (single values).
To transform this data into 1NF, we should split the repeating groups into separate rows:

```r
# Transforming data to 1NF
library(tidyr)
library(dplyr)

# Separate the courses and grades columns into multiple rows
normalized_data <- raw_data %>%
  separate_rows(courses, grades, sep = ", ") %>%
  arrange(student_id)

print(normalized_data)
```

## Remove Partial Dependencies:

A table is in 2NF if it is in 1NF and all non-key attributes are fully
functionally dependent on the primary key. We need to create separate tables for entities where partial dependencies exist. In this case, we can create a students table, a courses table, and an enrollments table.

```r
# Students Table
students <- data.frame(
  student_id = c(1, 2, 3),
  student_name = c("Alice", "Bob", "Charlie")
)

# Courses Table
courses <- data.frame(
  course_id = c(1, 2, 3, 4),
  course_name = c("Math", "Science", "History", "English")
)

# Enrollments Table (to link students to courses and grades)
enrollments <- data.frame(
  student_id = c(1, 1, 1, 2, 2, 3, 3),
  course_id = c(1, 2, 3, 1, 4, 2, 3),
  grade = c("A", "B", "C", "A", "B", "A", "C")
)
```

## Third Normal Form (3NF)
Remove Transitive Dependencies: A table is in 3NF if it is in 2NF and all the attributes are functionally dependent only on the primary key. Our current tables do not have transitive dependencies, so they are already in 3NF.

Consider the following table that contains student, course, and instructor information for 3NF Example.

```r
# Raw data with transitive dependencies
students_courses <- data.frame(
  student_id = c(1, 2, 3),
  student_name = c("Alice", "Bob", "Charlie"),
  course_id = c(101, 102, 103),
  course_name = c("Math", "Science", "History"),
  instructor_name = c("Dr. Smith", "Dr. Jones", "Dr. Brown"),
  instructor_office = c("Room 101", "Room 102", "Room 103")
)

print(students_courses)
```

In the students_courses table:
The primary key is student_id.
The instructor_office depends on instructor_name, which in turn depends on course_id.
This means we have a transitive dependency:
course_id → instructor_name → instructor_office
To remove the transitive dependencies, we need to create separate tables
for instructors and courses.

```r
# Instructors Table
instructors <- data.frame(
  instructor_id = c(1, 2, 3),
  instructor_name = c("Dr. Smith", "Dr. Jones", "Dr. Brown"),
  instructor_office = c("Room 101", "Room 102", "Room 103")
)

# Courses Table
courses <- data.frame(
  course_id = c(101, 102, 103),
  course_name = c("Math", "Science", "History"),
  instructor_id = c(1, 2, 3) # Foreign key referencing instructors table
)

# Students Table
students <- data.frame(
  student_id = c(1, 2, 3),
  student_name = c("Alice", "Bob", "Charlie")
)

# Enrollments Table
enrollments <- data.frame(
  student_id = c(1, 2, 3),
  course_id = c(101, 102, 103) # Foreign key referencing courses table
)

# => Third Normal Form (3NF) achieved
```

Create database views that join the normalized tables and present the combined data as a virtual table. Views can simplify query writing for users while keeping the underlying data normalized.

## Proper indexing can significantly improve the performance of your queries, especially for time-trend data.

```
CREATE INDEX idx_year ON annual_data(year);
```

The choice between a single large table with indexing and separate tables for each year depends on the specific requirements and constraints of your application. Consider factors such as data volume, query patterns, and database capabilities to make an informed decision.

## Partitioning

 Partitioning is a suitable approach for managing time series data. Partitioning can significantly improve query performance, simplify maintenance tasks, and provide better data management. Here’s a detailed guide on how to implement partitioning for your time series data in PostgreSQL:

```
-- Step 1: Create the Main Table with Partitioning
CREATE TABLE time_series_data (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    value DECIMAL(10, 2)
) PARTITION BY RANGE (timestamp);

-- Step 2: Create Partitions for Specific Time Ranges
CREATE TABLE time_series_data_2022 PARTITION OF time_series_data
    FOR VALUES FROM ('2022-01-01 00:00:00') TO ('2023-01-01 00:00:00');

CREATE TABLE time_series_data_2023 PARTITION OF time_series_data
    FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2024-01-01 00:00:00');

CREATE TABLE time_series_data_2024 PARTITION OF time_series_data
    FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2025-01-01 00:00:00');

-- Step 3: Insert Data into the Main Table
INSERT INTO time_series_data (timestamp, value) VALUES
('2022-05-15 10:00:00', 100.00),
('2023-06-15 12:00:00', 200.00),
('2024-07-15 14:00:00', 150.00),
('2022-08-20 09:30:00', 110.00),
('2023-09-25 16:45:00', 210.00),
('2024-10-30 18:20:00', 160.00);

-- Step 4: Query the Data

-- Query to get data for the year 2024
SELECT * FROM time_series_data WHERE timestamp BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

-- Query to get data for a range of years
SELECT * FROM time_series_data WHERE timestamp BETWEEN '2022-01-01 00:00:00' AND '2024-12-31 23:59:59';
```
