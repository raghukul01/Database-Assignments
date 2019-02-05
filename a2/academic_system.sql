CREATE TABLE student(
    rollno INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(20) NOT NULL -- assuming that email has max 8 character username (eg raghukul@iitk.ac.in)
    -- I have not kept email unique since old student mail ID are used for 
    -- assignment to new student, after they graduate.
);

CREATE TABLE faculty(
    fid INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(20) NOT NULL,
    officeaddr VARCHAR(100), -- office might not be known for some faculty
    -- Next 3 attributes represent the date of joining
    year INTEGER,
    month INTEGER,
    day INTEGER,
    CHECK (day >= 1 AND day <= 31),
    CHECK (month >= 1 AND day <= 12),
    CHECK (year >= 1959) -- faculty must join after the establishment of IITK :P
);

CREATE TABLE faculty_contact(
    fid INTEGER,
    phonenumber INTEGER NOT NULL,
    PRIMARY KEY (fid, phonenumber),
    FOREIGN KEY (fid) REFERENCES faculty(fid)
);

CREATE TABLE department(
    deptid INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    website VARCHAR(100) -- assuming that some department might not have a website :(
);

CREATE TABLE faculty_department(
    fid INTEGER NOT NULL,
    deptid INTEGER NOT NULL,
    por VARCHAR(10), -- NULL value means that this faculty does not hold a POR in academic committee 
                     -- of this department
    PRIMARY KEY (fid),
    FOREIGN KEY (fid) REFERENCES faculty(fid),
    FOREIGN KEY (deptid) REFERENCES department(deptid)
);

CREATE TABLE course(
    courseid VARCHAR(10) PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    credits INTEGER NOT NULL,
    about VARCHAR(200), -- despcription might not be available
    deptid INTEGER, -- represents the department which offers this course.
    CHECK (credits > 0),
    FOREIGN KEY (deptid) REFERENCES department(deptid)
);

CREATE TABLE program(
    progid INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL -- this is like BTech in CSE, or Minor in Algorithms
);

CREATE TABLE pre_requisites(
    courseid VARCHAR(10),
    prereqid VARCHAR(10),
    PRIMARY KEY (courseid, prereqid),
    FOREIGN KEY (courseid) REFERENCES course(courseid),
    FOREIGN KEY (prereqid) REFERENCES course(courseid)
);

-- this table represents the different type in which this course can be taken
-- for example ESO207 can be taken as DC by CSE student, and OE by an EE student.
CREATE TABLE course_type(
    courseid VARCHAR(10),
    ctype VARCHAR(10),
    PRIMARY KEY (courseid, ctype),
    FOREIGN KEY (courseid) REFERENCES course(courseid)
);

-- represents that in a given program you should take course with courseid in given semester, with ctype
CREATE TABLE template(
    progid INTEGER,
    courseid VARCHAR(10),
    semester INTEGER NOT NULL,
    ctype VARCHAR(10) NOT NULL,
    PRIMARY KEY (progid, courseid),
    FOREIGN KEY (progid) REFERENCES program(progid),
    FOREIGN KEY (courseid) REFERENCES course(courseid)
);

-- represents the programs offered by this department like cse offers minors in algorithms
CREATE TABLE program_offered(
    deptid INTEGER,
    progid INTEGER,
    PRIMARY KEY (deptid, progid),   
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (progid) REFERENCES program(progid)
);

CREATE TABLE offering(
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER NOT NULL,
    sem INTEGER NOT NULL, -- 1 represents odd, 2 represents even
    venue VARCHAR(10) NOT NULL, -- lecture hall
    timing VARCHAR(100) NOT NULL,
    PRIMARY KEY (courseid, fid, year, sem), -- fid is also in the key since
                                            -- same course might be offered
                                            -- in same semester, by diff profs. 
    FOREIGN KEY (courseid) REFERENCES course(courseid),
    FOREIGN KEY (fid) REFERENCES faculty(fid),
    CHECK (year > 1959), -- offering year should be greater that iitk foundation year :P
    CHECK (sem < 3 AND sem > 0) -- since it can be either 1 or 2
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

-- represents the courses done / currently doing
CREATE TABLE course_undertaken(
    rollno INTEGER,
    courseid VARCHAR(10),
    fid INTEGER,
    year INTEGER,
    sem INTEGER,
    ctype VARCHAR(10),
    nature VARCHAR(10) NOT NULL, -- fresh/repeat
    grade VARCHAR(1), -- NULL value for grade means that course is ongoing
    quantity INTEGER NOT NULL, -- this is just to incorporate thesis courses
                               -- for rest of the courses it is 1
    progid INTEGER, -- for which prgram is he doing this course
                    -- a person might do ESC207 in order to get 2 minor degrees.
    PRIMARY KEY (rollno, courseid, fid, year, sem, progid),
    FOREIGN KEY (courseid, fid, year, sem) REFERENCES offering(courseid, fid, year, sem),
            -- since this course must have been offered
    FOREIGN KEY (courseid, ctype) REFERENCES course_type(courseid, ctype),
    FOREIGN KEY (progid) REFERENCES program(progid),
    FOREIGN KEY (rollno) REFERENCES student(rollno),
    CHECK (nature='fresh' OR nature='repeat')
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
    PRIMARY KEY (rollno, deptid, progid),
    FOREIGN KEY (rollno) REFERENCES student(rollno),
    FOREIGN KEY (deptid) REFERENCES department(deptid),
    FOREIGN KEY (progid) REFERENCES program(progid)
);