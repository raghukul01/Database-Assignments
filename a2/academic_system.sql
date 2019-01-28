CREATE TABLE student(
    rollno INTEGER PRIMARY KEY ,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(20) NOT NULL
);

CREATE TABLE faculty(
    fid INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(20) NOT NULL,
    officeaddr VARCHAR(100),
    -- Next 3 attributes represent the date of joining
    year INTEGER,
    month INTEGER,
    day INTEGER,
    CHECK (day >= 1 AND day <= 31),
    CHECK (month >= 1 AND day <= 12),
    CHECK (year >= 1959)
);

CREATE TABLE faculty_contact(
    fid INTEGER,
    phonenumber INTEGER NOT NULL,
    FOREIGN KEY (fid) REFERENCES faculty(fid)
);

CREATE TABLE department(
    deptid INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    website VARCHAR(100)
);

CREATE TABLE faculty_department(
    fid INTEGER NOT NULL,
    deptid INTEGER NOT NULL,
    por VARCHAR(10),
    FOREIGN KEY (fid) REFERENCES faculty(fid),
    FOREIGN KEY (deptid) REFERENCES department(deptid)
);

CREATE TABLE course(
    courseid VARCHAR(10) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL,
    about VARCHAR(200),
    deptid INTEGER, -- represents the department which offers this course.
    CHECK (credits > 0),
    FOREIGN KEY (deptid) REFERENCES department(deptid)
);

CREATE TABLE program(
    progid INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE pre_requisites(
    courseid VARCHAR(10),
    prereqid VARCHAR(10),
    FOREIGN KEY (courseid) REFERENCES course(courseid),
    FOREIGN KEY (prereqid) REFERENCES course(courseid)
);

CREATE TABLE course_type(
    courseid VARCHAR(10),
    ctype VARCHAR(10),
    PRIMARY KEY (courseid, ctype),
    FOREIGN KEY (courseid) REFERENCES course(courseid)
);

CREATE TABLE template(
    progid INTEGER,
    courseid VARCHAR(10),
    semester INTEGER,
    ctype VARCHAR(10),
    PRIMARY KEY (progid, courseid),
    FOREIGN KEY (progid) REFERENCES program(progid),
    FOREIGN KEY (courseid) REFERENCES course(courseid)
);

CREATE TABLE program_offered(
    deptid INTEGER,
    progid INTEGER,
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (progid) REFERENCES program(progid)
);

CREATE TABLE offering(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER NOT NULL,
    sem INTEGER NOT NULL, -- 1 represents odd, 2 represents even
    venue VARCHAR(10) NOT NULL,
    timing VARCHAR(100) NOT NULL,
    PRIMARY KEY (courseid, fid, year, sem), -- fid is also in the key since
                                            -- same course might be offered
                                            -- in same semester, by diff profs. 
    FOREIGN KEY (courseid) REFERENCES course(courseid),
    FOREIGN KEY (fid) REFERENCES faculty(fid),
    CHECK (year > 1959), -- offering year should be greater that iitk foundation year :P
    CHECK (sem < 3 AND sem > 0)
);

-- note that tutors can be of 2 type: student or faculty
-- for example in ESC101 we have student tutors
-- while in MSO201 we have faculty tutors.
CREATE TABLE faculty_tutor(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER,
    sem INTEGER,
    tutorid INTEGER, -- this id is an fid
    FOREIGN KEY (courseid, fid, year, sem) REFERENCES offering(courseid, fid, year, sem),
    FOREIGN KEY (tutorid) REFERENCES faculty(fid)
);

CREATE TABLE student_tutor(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER,
    sem INTEGER,
    rollno INTEGER,
    FOREIGN KEY (courseid, fid, year, sem) REFERENCES offering(courseid, fid, year, sem),
    FOREIGN KEY (rollno) REFERENCES student(rollno)
);

CREATE TABLE teaching_assistant(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER,
    sem INTEGER,
    rollno INTEGER, -- since a TA is always a student
    FOREIGN KEY (courseid, fid, year, sem) REFERENCES offering(courseid, fid, year, sem),
    FOREIGN KEY (rollno) REFERENCES student(rollno)
);

CREATE TABLE course_undertaken(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER,
    sem INTEGER,
    ctype VARCHAR(10),
    nature VARCHAR(10) NOT NULL, -- fresh/repeat
    grade VARCHAR(1), -- NULL value for grade means that course is ongoing
    quantity INTEGER NOT NULL, -- this is just to incorporate thesis courses
                               -- for rest of the courses it is 1
    progid INTEGER,
    FOREIGN KEY (courseid, fid, year, sem) REFERENCES offering(courseid, fid, year, sem),
    FOREIGN KEY (courseid, ctype) REFERENCES course_type(courseid, ctype),
    FOREIGN KEY (progid) REFERENCES program(progid)
);

CREATE TABLE faculty_advisor(
    rollno INTEGER,
    fid INTEGER,
    thesistitle VARCHAR(100),
    PRIMARY KEY (rollno, fid),
    FOREIGN KEY (rollno) REFERENCES student(rollno),
    FOREIGN KEY (fid) REFERENCES faculty(fid)
);

CREATE TABLE student_department(
    rollno INTEGER,
    deptid INTEGER,
    progid INTEGER,
    FOREIGN KEY (rollno) REFERENCES student(rollno),
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (progid) REFERENCES program(progid)
);