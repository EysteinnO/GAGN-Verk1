--1.
--Design extensions to the ProgressTracker database so that it becomes possible to register students
--and they can choose a track(within a division).

CREATE TABLE IF NOT EXISTS Students
(
	studentID INT NOT NULL AUTO_INCREMENT,
	studentName varchar(75),
	studentKT varchar(10),
	trackID INT NOT NULL,
	CONSTRAINT studentTrack FOREIGN KEY(trackID) REFERENCES Tracks(trackID),
	CONSTRAINT student_Primary PRIMARY KEY(studentID)
);

INSERT INTO Students(studentName, studentKT, trackID)
VALUES
('Gunnar Gunnarsson', '1234567890', 6),
('Björgúlfur Hermannson', '1234567891', 6),
('Jóhannes Kristmundarson', '1234567892', 9),
('Magnús Kristjánsson', '1234567893', 6),
('Sigurður Björnsson', '1234567894', 6),
('Páll Tómasarson', '1234567895', 9);

CREATE PROCEDURE ProgressTracker_V1.AddStudent(studentName_in varchar(75), studentKT_in varchar(10), trackID_in INT)
BEGIN
	INSERT INTO Students (studentName, studentKT, trackID)
	VALUES (studentName_in, studentKT_in, trackID_in);
END
--
CALL AddStudent('Helga Kristjánsdóttir','1234567894' 9);

-- 2:
-- Create a trigger for the insert operation on the table Restrictors. The trigger
-- prevents the case of the courseNumber and restrictorID being the
-- same(a course cannot be a restrictor on it self). If this is the case then
-- the trigger prevents the insert by throwing and error and writes a error message.
-- Example of an insert operation that the trigger stops:
-- insert into Restrictors values('GSF2B3U','GSF2B3U',1);

CREATE TRIGGER IdenticalRestrictor
BEFORE INSERT ON `Restrictors`
FOR EACH ROW
BEGIN
  IF (new.courseNumber = new.restrictorID) THEN
    signal sqlstate '45000' set message_text = "A course cannot be a restrictor on it self";
  END IF;
END

-- 3:
-- Write an identical trigger for the update operation on the table Restrictors

CREATE TRIGGER IdenticalRestrictorUpdate
BEFORE UPDATE ON `Restrictors`
FOR EACH ROW
BEGIN
  IF (new.courseNumber = new.restrictorID) THEN
    signal sqlstate '45000' set message_text = "A course cannot be a restrictor on it self";
  END IF;
END

--4:
-- Write a stored procedure that sums up the course credits that a student has finished arranged by the
-- divisions offering these courses.
-- NOTE
-- The general courses(physics, mathematics, sociology, etc.) actually belong to the General Study
-- Division(Tæknimenntaskólinn NTT13). This in fact means that if the student has completed four,
-- three credit courses of general studies(say math and physics) and five, three credit courses at the
-- computer division(Tölvubraut TBR16) the results would look something like this:
-- NTT13 12
-- TBR16 15
-- Only courses that are graded >= 5 or are graded ‘passed’ should be chosen.
DROP TABLE IF EXISTS `StudentCourseSum`;
CREATE TABLE `StudentCourses` (
  studentID INT NOT NULL,
  trackID INT NOT NULL,
  courseNumber CHAR(10),
  grade FLOAT,
  semester CHAR(10),
  CONSTRAINT FK_studentID_StudentCourses FOREIGN KEY(studentID) REFERENCES Students(studentID),
  CONSTRAINT FK_trackID_StudentCourses FOREIGN KEY(trackID) REFERENCES Tracks(trackID),
  CONSTRAINT FK_courseNumber_StudentCourses FOREIGN KEY(courseNumber) REFERENCES Courses(courseNumber)
);

INSERT INTO `StudentCourses`(studentID, trackID, courseNumber, grade, semester)
VALUES
(1, 9, 'STÆ103', 8.14, '2018V'),
(2, 9, 'GSF2A3U', 7.4, '2018V'),
(3, 6, 'EÐL103', 8.2, '2018V'),
(3, 2, 'STÆ103', 5.6, '2018V'),
(3, 6, 'STÆ203', 3.6, '2018H'),
(3, 6, 'FOR3L3U', 7.5, '2018V'),
(4, 6, 'FOR3D3U', 9.5, '2018V'),
(5, 9, 'STÆ203', 7, '2018V'),
(6, 2, 'STÆ603', 3.3, '2018V');

DELIMITER //
DROP PROCEDURE IF EXISTS `StudentCourseCreditSum` //
CREATE PROCEDURE `StudentCourseCreditSum` (
  `param_studentID` INT
)
BEGIN
	SELECT `Tracks`.trackName, SUM(`Courses`.courseCredits) AS `Credits`
	FROM  `StudentCourses`
	INNER JOIN `Students` ON `StudentCourses`.studentID = `Students`.studentID
	INNER JOIN `Tracks` ON `StudentCourses`.trackID = `Tracks`.trackID
	INNER JOIN `Courses` ON `StudentCourses`.courseNumber = `Courses`.courseNumber
	WHERE `StudentCourses`.studentID = `param_studentID`
    AND `StudentCourses`.grade >= 5
	GROUP BY `Tracks`.trackName;
END //
DELIMITER ;

CALL `StudentCourseCreditSum`(3);

-- 5: Sleppti
-- Write a cursor that selects all the mandatory courses for a student and puts them into the table that
-- stores the student courses.
-- Put this cursor in a stored procedure that can be called “AddMandatoryCourses” and is run when a
-- student selects courses for the first time. The selection process could be implemented in another
-- stored procedure, perhaps called NewStudentCourses.
-- In that one a check is performed to see if the student has chosen courses before and if that is then
-- the AddMandatoryCOurses has already been run and is NOT run again.




