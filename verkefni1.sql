//SQL Verkefni1 - Eysteinn Orri Sigurðsson


A Hluti

courseList()
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`courseList`()
BEGIN
		SELECT courseName FROM Courses ORDER BY courseName;
END

Single_Course()
CREATE PROCEDURE Single_Course(IN courseNumber char(10))
	BEGIN
		SELECT * 
		FROM Courses 
		WHERE courseName = courseNumber;
	END  
-
CALL Single_Course('EÐL103');

New_Course()
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`New_Course`(IN courseNumber char(10), courseName varchar(75), courseCredits tinyint(4), OUT numberofrows int)
BEGIN
		INSERT INTO Courses (courseNumber, courseName,courseCredits) VALUES (courseNumber, courseName, courseCredits) SELECT ROW_COUNT();
END

Update_Course()
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`Update_Course`(IN courseNumber_in char(10), IN courseName_in varchar(75), IN courseCredits tinyint(4), OUT numberofrows int)
BEGIN 
		Update Courses 
		SET courseName = courseName_in,
		    courseCredits = courseCredits_in,
		WHERE courseNumber = courseNumber_in,
		SELECT ROW_COUNT();
END

Delete_Course() - þarft að laga
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`Delete_Course`(courseNumber_in char(10))
BEGIN 
	IF (SELECT COUNT(courseNumber) FROM TrackCourses WHERE courseNumber = courseNumber_in) = 0 AND
	   (SELECT COUNT(courseNumber) FROM Restrictors WHERE courseNumber = courseNumber_in) = 0 AND
	   (SELECT COUNT(courseName) FROM TrackCourses WHERE restrictorID = courseNumber_in) = 0 THEN			
		DELETE FROM Courses 		
		WHERE courseName = courseName_in
		END IF
		SELECT ROW_COUNT();
END

ELSE
	BEGIN
		RETURN NULL
END

6: NumberOfCourses()
The function returns the total number of courses in the database

CREATE FUNCTION NumberOfCourses()
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN(select count(courseName) from courses)
END

select NumberOfCourses();

7: TotalTrackCredits() - þarf að laga
The function returns the total credits that can be taken on a specific track
You need to supply the track ID as a parameter
CREATE FUNCTION TotalTrackCredits(trackID_in int(11))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN (SELECT SUM(courseCredits) FROM Courses NATURAL JOIN TrackCourses WHERE trackID = trackID_in);
END
-
SELECT TotalTrackCredits(9);

8: MaxCredits()
The function returns the number of credits of the course(s) with the most credits.
Please note that more than one course can share the most awarded credits but it should
NOT affect the results.
CREATE FUNCTION MaxCredits()
RETURNS INTEGER 
DETERMINISTIC
BEGIN
	RETURN (SELECT MAX(courseCredits) FROM Courses)
END
-
SELECT MaxCredits();

9: MostNumberOfTracks() - þarf eitthvað að skoða
What is the maximum number of tracks that a single Division has. Just return the number(We’ll use this one later in the
course)
CREATE FUNCTION MostNumberOfTracks() 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE MostNumberOfTracks INTEGER;
	SET MostNumberOfTracks = (SELECT MAX(count) FROM
 		(SELECT COUNT(Divisions.divisionName) AS count
 			FROM Tracks
 			INNER JOIN Divisions ON Tracks.divisionID = Divisions.divisionID
 			GROUP BY Divisions.divisionName
 			ORDER BY count DESC 
 			) AS x;
RETURN MostNumberOfTracks;
END
-
SELECT MostNumberOfTracks();


B Hluti

1:
Write a stored procedure TrackOverview()
TrackOverview() displays the name of the track(trackName), number of courses supplied by that track and if possible
how high a percentage that course number is of the total number of courses in the database. This is a good place to use
the AfangaFjoldi() / NumberOfCourses() from first part of this assignment.

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`TrackOverview_2`()
BEGIN
	SELECT Tracks.trackName,
	COUNT(TrackCourses.courseNumber) AS CourseCount
	FROM Tracks
	INNER JOIN TrackCourses ON Tracks.TrackID = TrackCourses.TrackID
	WHERE Tracks.TrackID = trackID_in;
END
CALL TrackOverview(4);

2:
Write a stored procedure TrackTotalCredits()
TrackTotalCredits() displays track names, division names that the track belongs to and the total number of courses for
that track. It would be a good idea to order the results by the total number of courses. The track containing the highest
number of courses would be on top and in the case of more than one sharing that number a alphabetical order of track
names would be used as well.

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`TotalTrackCredits`()
BEGIN
	SELECT TrackName, divisionName, COUNT(TrackCourses.trackID) AS CourseCount
	FROM TrackCourses
	INNER JOIN Tracks ON TrackCourses.trackID = Tracks.trackID
	INNER JOIN Divisions ON Tracks.divisionID = Divisions.divisionID
	GROUP BY Tracks.trackName ORDER BY NumberOfCourses DESC;
END

3:
Write a stored procedure CourseRestrictorList()
CourseRestrictorList() displays all course names that are in the database along with their respective restirctors and the
type of restrictor(s). If courses are not associated with any restrictors theyr are displayed wthout these information.
Order the results in a way you deem to be helpful for the end user.
NOTE: If a course has more than one restrictor it is listed more than once.

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`CourseRestrictorList`()
BEGIN
	SELECT Courses.courseNumber,
	Restrictors.restrictorID,
	Restrictors.restrictorType
	FROM Restrictors
	RIGHT OUTER JOIN Courses on Restrictors.courseNumber = Courses.courseNumber
	ORDER BY Courses.courseNumber;
END
CALL CourseRestrictorList();


4:
Write a stored procedure RestrictorList()
RestrictorList() displays information about all the courses that are restrictors along with the courses they restrict. You
could perhaps look at this as a invertet part3 of this assignment.
NOTE: You are given a free play as to the design of this procedure but it has to display a clear results that are profiting
to the ProgressTracker system.
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProgressTracker_V1`.`RestrictorList`()
BEGIN
	SELECT restrictorID, courseNumber FROM Restrictors 
	ORDER BY restrictorID;
END
CALL RestrictorList();












