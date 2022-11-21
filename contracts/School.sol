//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import './Administration.sol';


contract School{

    /// Representts a study Program a student can follow
    struct StudyProgram{
    bytes32[] subjects; //list of all subjects a student must learn to graduate
    }

    /// Represents a student
    struct Student{
    //Name of the study program the student is currently following
    bytes32 studyProgram;
    //List of courses the student has participated in 
    bytes32[] courseIds;
    //Maps the subject name with the course Id the student has followed
    mapping(bytes32=>bytes32) coursesFollowed;
    }

    /// Represents any method a student can use to earn points in a class
    struct Assignment {
         //Unique assignment id , used to identify the assignment
        bytes32 assignmentId;
        //Sets the maximum points a student can get after completing the assignment
        uint maxAssignmentPoints; 
        //Sets the amount of points each student received in this assignemnt
        mapping (address => uint) marks; 
    }

    /// Represents a Course a student can follow
    struct Course {
        bytes32 courseID; //unique course id , used to identify it
        bytes32 courseName;  // the name of the subject the course is teaching
        address instructor; // address of the pedagogic staff member teaching the course
        address[] studentList;  // list of student addresses following the class
        mapping (address => bool) courseStudents; // mapping used to verify if a student is part of the course
    }

    /// Represents the grades earned by students during a class
    struct Marks {
        bytes32[] assignmentIds; // list of all assignments given during this course
        mapping(uint=> address) studentEnrolments; //maps the enrolment id with the student id
        mapping (bytes32 => bool) assignmentIdChecker; // mapper used to verify if an assignment is part of the course
        mapping (bytes32 => Assignment) assignments; // mapps the assignment id with the assignment data
        mapping (address=>uint[]) collectedPoints; //gets or sets the points a student has collected through the class
        mapping (address => uint) totalPoints; // gets or sets the student final grade for the course
        mapping (address => uint) finalGrade; //displays the student's final grade after finishing the course
    }

    Administration administration = new Administration();  //Instance of administration contract  
    bytes32[] private courseIDList; //List of all courses the academic system contains
    mapping(bytes32 => bool) courseIds; //Mapper used to verify if a course with the given id exists
    mapping(address=>Student) students; /// Contains all the student data 
    mapping(bytes32 => Course) courses; //maps the course with the course id
    mapping(bytes32 => Marks) courseMarks; //Links a course with the grades the students have earned
    mapping(bytes32=> StudyProgram) studyPrograms; //Maps all the study programs the school offers 

   

    modifier onlyTeachers()
    {

      require(administration.isTeacher(msg.sender), "Requires teacher account.");
      _;
    }

    modifier onlyAdmin()
    {
      require(administration.isAdmin(msg.sender), "Requires administrator account.");
      _;
    }

    // register a new student
    function addStudent(address studentAddress,bytes32 studyProgram) public 
    {
        bytes32[] memory courseIdList;
        Student storage newStudent = students[studentAddress];
        newStudent.studyProgram=studyProgram;
        newStudent.courseIds = courseIdList;
    }
  
    ///add new study program
    function addNewStudyProgram(bytes32 programName ,bytes32[] memory subjects )public  returns(bool)
    {
      if(abi.encode(studyPrograms[programName]).length >0)
      {
        return false ; // A study program with that name exists
      }

      StudyProgram memory studyProgram = StudyProgram(subjects);
      studyPrograms[programName] =studyProgram;
      return true;
    }

      constructor  ()
    
  {
    administration = new Administration();
  }

    //add a new course 
    function addCourse(bytes32 classId, bytes32 courseName, address[] memory studentList)
     public  returns (bool result) {

        //add the course
        courseIds[classId] = true;
        courseIDList.push(classId);

        Course storage newCourse = courses[classId];
        newCourse.courseID=classId;
        newCourse.courseName=courseName;
        newCourse.instructor=msg.sender;

        //enroll list of students into class
        for (uint i = 0; i < studentList.length; i++)
        {   
             //insert the student address to the course enrolment list 
            courses[classId].studentList[i] = studentList[i];
            courses[classId].courseStudents[studentList[i]] = true;

            //add the courseId to student's courses
            students[studentList[i]].courseIds.push(classId); 
            students[studentList[i]].coursesFollowed[courseName]=classId;
        }
        //initialise an instance of Grades for the new Course

        bytes32[] memory assignmentIds;

        //set all student points at the start of the class to zero
        for (uint p = 0; p < courses[classId].studentList.length; p++)
        {
            courseMarks[classId].totalPoints[courses[classId].studentList[p]] = 0;
        }
        
        //create the grades registry for the new course
        Marks storage newCourseMarks = courseMarks[classId];
        newCourseMarks.assignmentIds=assignmentIds;
        result = true;
    }

    ///Record a completed assignment including the student grades
    function addAssignment(bytes32 courseID, bytes32 assignmentName, uint maxMarks,  uint[] memory marksList,
     address[] memory studentsList) public returns (bool added) {
      require (marksList.length == studentsList.length, 
         "Assigment grades should match student number");
      
        courseMarks[courseID].assignmentIdChecker[assignmentName] = true;
        courseMarks[courseID].assignmentIds.push(assignmentName);
        Assignment storage newAssignment = courseMarks[courseID].assignments[assignmentName];
        newAssignment.assignmentId = assignmentName;
        newAssignment.maxAssignmentPoints = maxMarks;

        //add student marks to assignment
        for (uint j = 0; j < studentsList.length; j++) { //trying to replace this
            courseMarks[courseID].assignments[assignmentName].marks[studentsList[j]] = marksList[j];
        }

        //add the new grade from the assignment to the student course grades
        for(uint i = 0; i < courses[courseID].studentList.length; i++){
             //push student grades to their course grades
            courseMarks[courseID].collectedPoints[studentsList[i]]
                .push(courseMarks[courseID].assignments[assignmentName].marks[studentsList[i]]);
            }
        added = true;
    }

    
    //sets the final grade of the course for each student
    function finalCourseGrade(bytes32 courseId) private returns(bool result)
    {
        for (uint i = 0; i < courseMarks[courseId].assignmentIds.length; i++) //loop through each asignment
        {
            bytes32 assignmentId = courseMarks[courseId].assignmentIds[i];
            for (uint j = 0; j < courses[courseId].studentList.length; j++)
            {
                address studentAddress = courses[courseId].studentList[j];
                require (courseMarks[courseId].assignments[assignmentId].marks[studentAddress]
                <= courseMarks[courseId].assignments[assignmentId].maxAssignmentPoints
                , "A student can't get more points than assigned");

                //add assignment points to student grade
                courseMarks[courseId].totalPoints[studentAddress] +=
                 ((courseMarks[courseId].assignments[assignmentId].marks[studentAddress])); 

                //set the student final grade for the course 
              
                if( courseMarks[courseId].totalPoints[studentAddress] > 90) {courseMarks[courseId].finalGrade[studentAddress] = 10;}
                else if( courseMarks[courseId].totalPoints[studentAddress] > 80) 
                {courseMarks[courseId].finalGrade[studentAddress] = 9;}
                else if( courseMarks[courseId].totalPoints[studentAddress] > 70)
                {courseMarks[courseId].finalGrade[studentAddress] = 8;}
                else if( courseMarks[courseId].totalPoints[studentAddress] > 60) 
                {courseMarks[courseId].finalGrade[studentAddress] = 7;}
                else if( courseMarks[courseId].totalPoints[studentAddress] > 50) 
                {courseMarks[courseId].finalGrade[studentAddress] = 6;}
                else if( courseMarks[courseId].totalPoints[studentAddress] > 40) 
                {courseMarks[courseId].finalGrade[studentAddress] = 5;}
                else {courseMarks[courseId].finalGrade[studentAddress] =4;}
            }
           
        }
          result=true;
    }

    ///returns the student's final grade for a specific class 
    function seeClassGrade(bytes32 courseId,address studentId) public view returns(uint grade)
    {
         require((courseIds[courseId]),
            "A course with this id was not found , please try again");
         require((courses[courseId].courseStudents[studentId]),
            "A student with this id was not found in the Course enrolments");
         grade = courseMarks[courseId].finalGrade[studentId];
    }
    
    ///get all student grades
    function getAllStudentGrades(address studentId) public view returns(bytes32[] memory , uint[] memory  )
    {
        bytes32[] memory studentCourseIds = students[studentId].courseIds; //load student with this id in the memory
        uint[] memory grades = new uint[](studentCourseIds.length);
        bytes32[] memory subjects = new bytes32[](studentCourseIds.length);
      
        for(uint i=0;i<studentCourseIds.length;i++)
        {
             grades[i]=courseMarks[studentCourseIds[i]].finalGrade[studentId];
             subjects[i]=courses[studentCourseIds[i]].courseName;
        }

        return (subjects,grades);

    }
   
    ///get all students final grades for a finished course 
    function getClassGrades(bytes32 classId) public view onlyTeachers returns( address[] memory,uint[] memory)
    {
        address[] memory courseParticipants = courses[classId].studentList;  
        uint[] memory grades = new uint[](courseParticipants.length);
        for(uint i = 0 ; i < courseParticipants.length;i++)
        {
          //get the student final grade from the course marks
          grades[i]  = courseMarks[classId].finalGrade[courseParticipants[i]]; 
        }

        return (courseParticipants,grades);
    }

    //check if student can graduate
    //a student can graduate by passing each subject in his study program
    function canGradute(address studentId) public view returns(bool)
    {
        bytes32 studentStudyProgram = students[studentId].studyProgram;   //get student study program
         
            StudyProgram memory studyProgram = studyPrograms[studentStudyProgram];

            //check if the student has followed a class for all the subjects a study program contains
            for(uint i=0; i<studyProgram.subjects.length; i++)
            {
                bytes32 subjectName = studyProgram.subjects[i];
                if(abi.encode(students[studentId].coursesFollowed[subjectName]).length == 0)
                {
                    return false; // student hasnt followed a course with the specified subject name . He cannot graduate
                }

                //student has followed a course with the specified subject id . Check the student final grade
                bytes32 courseId = students[studentId].coursesFollowed[subjectName];
                uint courseGrade = courseMarks[courseId].finalGrade[studentId] ;
                if(courseGrade < 5)
                {
                    //student has a failing grade , he cannot graduate
                    return false;
                }

            }
            return true;
     }
}