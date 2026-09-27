/*==============================================================*/
/* SAS ASSIGNMENT - STUDENT DATA PROCESSING                     */
/*==============================================================*/


/*--------------------------------------------------------------*/
/* Requirement 1: Sort CLASS and CLASSFIT and merge datasets    */
/*--------------------------------------------------------------*/

proc sort data=sashelp.class out=class_sorted;
    by Name;
run;

proc sort data=sashelp.classfit out=classfit_sorted;
    by Name;
run;

data student_master;
    merge class_sorted
          classfit_sorted(keep=Name predict);
    by Name;
run;


/*--------------------------------------------------------------*/
/* Requirements 2, 3 and 4: BMI, Age Group, BMI Status          */
/*--------------------------------------------------------------*/

data student_master;
    set student_master;

    length Age_Group $12 BMI_Status $12;

    /* Calculate BMI */
    BMI = round((Weight / (Height * Height)) * 703, 0.1);

    /* Create Age Group */
    if Age < 13 then
        Age_Group = "Child";
    else if Age >= 13 and Age <= 14 then
        Age_Group = "Teen";
    else if Age > 14 then
        Age_Group = "Senior Teen";

    /* Create BMI Status */
    if BMI < 18 then
        BMI_Status = "Underweight";
    else if BMI >= 18 and BMI <= 25 then
        BMI_Status = "Healthy";
    else if BMI > 25 then
        BMI_Status = "Overweight";
run;


/*--------------------------------------------------------------*/
/* Requirement 5: Create Student_ID                             */
/* Requirement 6: Create Upper_Name, Initial, Name_Length       */
/*--------------------------------------------------------------*/

data student_master;
    set student_master;

    /* Student ID = Sex + Age + first 3 letters of Name */
    Student_ID = cats(Sex, Age, substr(upcase(Name), 1, 3));

    /* Convert Name to uppercase */
    Upper_Name = upcase(Name);

    /* First letter of Name */
    Initial = substr(upcase(Name), 1, 1);

    /* Number of characters in Name */
    Name_Length = length(strip(Name));
run;


/*--------------------------------------------------------------*/
/* Requirements 7 and 8: Weight Difference and Final Weight     */
/*--------------------------------------------------------------*/

data student_master;
    set student_master;

    /* Difference between Actual Weight and Predicted Weight */
   if not missing(Predict) then
    Weight_Diff = round(Weight - Predict, 0.1);

    Residual = Weight_Diff;

    /* Final Weight */
    if not missing(Predict) then
        Final_Weight = Predict;
    else
        Final_Weight = Weight;
run;


/*--------------------------------------------------------------*/
/* Requirement 9: Create OVERWEIGHT_STUDENTS                    */
/*--------------------------------------------------------------*/

data overweight_students;
    set student_master;

    if BMI > 20 and Age > 13;
run;


/*--------------------------------------------------------------*/
/* Requirement 10: Create WEIGHT_CHECK                          */
/*--------------------------------------------------------------*/

data weight_check;
    set student_master;

    if abs(Weight_Diff) > 5;
run;


/*--------------------------------------------------------------*/
/* Requirement 11: Check Student_ID and Missing Values           */
/*--------------------------------------------------------------*/

/* Check Student_ID */
proc freq data=student_master;
    tables Student_ID / missing;
run;

/* Check for missing BMI values */
proc means data=student_master n nmiss;
    var BMI;
run;

/* Check Age Group and BMI Status */
proc freq data=student_master;
    tables Age_Group BMI_Status / missing;
run;


/*--------------------------------------------------------------*/
/* Requirement 12: Rename Variables                             */
/*--------------------------------------------------------------*/

data student_final;
    set student_master;

    rename
    Height      = Height_In
    Weight      = Weight_Lb
    Predict     = Predicted_Weight
    Residual    = Prediction_Error;
run;


/*--------------------------------------------------------------*/
/* Requirement 13: Add Labels and Formats                       */
/*--------------------------------------------------------------*/

data student_final;
    set student_final;

    label
        Student_ID         = "Student ID"
        Name               = "Student Name"
        Sex                = "Sex"
        Age                = "Age"
        Height_In          = "Height (inches)"
        Weight_Lb          = "Weight (lb)"
        Predicted_Weight   = "Predicted Weight"
        Prediction_Error   = "Prediction Error"
        Final_Weight       = "Final Weight"
        BMI                = "Body Mass Index"
        Age_Group          = "Age Group"
        BMI_Status         = "BMI Status"
        Weight_Diff        = "Weight Difference"
        Upper_Name         = "Uppercase Name"
        Initial            = "Name Initial"
        Name_Length        = "Name Length";

    format
        Height_In          6.1
        Weight_Lb          6.1
        Predicted_Weight   8.1
        Prediction_Error   6.1
        Final_Weight       8.1
        BMI                5.1
        Weight_Diff        8.1;
run;


/*--------------------------------------------------------------*/
/* Requirement 14: Arrange Variables in Required Order          */
/*--------------------------------------------------------------*/

data student_final;
    retain
        Student_ID
        Name
        Sex
        Age
        Age_Group
        Height_In
        Weight_Lb
        Predicted_Weight
        Prediction_Error
        Final_Weight
        BMI
        BMI_Status
        Weight_Diff
        Upper_Name
        Initial
        Name_Length;

    set student_final;
run;

/*--------------------------------------------------------------*/
/* Requirement 15: Sort Final Dataset by Sex and Age            */
/*--------------------------------------------------------------*/

proc sort data=student_final;
    by Name;
run;

/*==============================================================*/
/* FINAL VALIDATION                                              */
/*==============================================================*/

/* Check final dataset structure */
proc contents data=student_final;
run;


/* Display final dataset */
proc print data=student_final;
run;


/* Display OVERWEIGHT_STUDENTS */
proc print data=overweight_students;
run;


/* Display WEIGHT_CHECK */
proc print data=weight_check;
run;
