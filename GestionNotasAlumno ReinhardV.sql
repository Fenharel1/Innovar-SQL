use TNotasAlumno;

create table Tstudent(
	id int identity(1,1) primary key,
	name varchar(50)
);

create table Tcourse(
	id int identity(1,1) primary key,
	name varchar(50)
);

create table Tsubject(
	id int identity(1,1) primary key,
	name varchar(80),
	idCurso int foreign key references Tcourse(id)
);

create table Texam(
	id int identity(1,1) primary key,
	idStudent int foreign key references Tstudent(id),
	idCourse int foreign key references Tcourse(id),
	score float,
	isReview bit
);

create table Tquestion(
	id int identity(1,1) primary key,
	question varchar(200),
	idSubject int foreign key references Tsubject(id)
)

create table Talternative(
	id int identity(1,1) primary key,
	alternative varchar(100),
	isCorrect bit,
	idQuestion int foreign key references Tquestion(id)
)

create table TexamQuestion(
	id int identity(1,1) primary key,
	idExam int foreign key references Texam(id),
	idQuestion int foreign key references Tquestion(id),
	idAnswered int foreign key references Talternative(id),
)

create table Treview(
	id int identity(1,1) primary key,
	idStudent int foreign key references Tstudent(id),
	idSubject int foreign key references Tsubject(id),
)

create table TreviewReminder(
	id int identity(1,1) primary key,
	idReview int foreign key references Treview(id),
	idExamQuestion int foreign key references TexamQuestion(id),
	nextReminder date,
	reminderType varchar(50) check( reminderType in ('2 hours','2 days', '5 days' , '10 days', '1 month', '2 months'))
);

-- TRIGGERS

CREATE TRIGGER tr_TreviewReminder_insert
ON TreviewReminder
FOR INSERT
AS
BEGIN
    DECLARE @idAnswered int, @isCorrect bit, @nextReminder datetime, @reminderType varchar(50)
    
    SELECT @idAnswered = teq.idAnswered, @isCorrect = ta.isCorrect
    FROM inserted i
	INNER JOIN TexamQuestion Teq on Teq.idQuestion = i.idExamQuestion
    JOIN Talternative ta ON Teq.idAnswered = ta.id
    
    IF @isCorrect = 1
    BEGIN
        SET @nextReminder = DATEADD(day, 2, GETDATE())
        SET @reminderType = '2 days'
    END
    ELSE
    BEGIN
        SET @nextReminder = DATEADD(hour, 2, GETDATE())
        SET @reminderType = '2 hours'
    END
    
    UPDATE TreviewReminder
    SET nextReminder = @nextReminder, reminderType = @reminderType
    FROM inserted i
    WHERE i.id = TreviewReminder.id
END




-- INSERTING VALUES INTO TABLES

INSERT INTO Tstudent (name) VALUES 
('John'),
('Mary'),
('Peter');

INSERT INTO Tcourse (name) VALUES 
('Math'),
('English');

INSERT INTO Tsubject (name, idCurso) VALUES 
('Calculus', 1),
('Grammar', 2);

INSERT INTO Texam (idStudent, idCourse, score, isReview) VALUES 
(1, 1, 7.5, 0),
(2, 2, 8.2, 1),
(3, 1, 6.9, 0);

INSERT INTO Tquestion (question, idSubject) VALUES 
('What is the derivative of x^2?', 1),
('What is the plural of goose?', 2),
('What is the integral of sin(x)?', 1),
('What is the past tense of swim?', 2),
('What is the limit of 1/x as x approaches infinity?', 1),

('What is the antonym of happy?', 2),
('What is the definition of a limit?', 1),
('What is the synonym of beautiful?', 2),
('What is the derivative of e^x?', 1),
('What is the superlative of good?', 2);

INSERT INTO Talternative (alternative, isCorrect, idQuestion) VALUES 
('2x', 1, 1),
('x^2', 0, 1),
('2', 0, 1),
('geeses', 0, 2),
('geese', 1, 2),
('goosies', 0, 2),
('cos(x) + C', 0, 3),
('-cos(x) + C', 0, 3),
('-sin(x) + C', 1, 3),
('swam', 1, 4),
('swimmed', 0, 4),
('swum', 0, 4),
('0', 1, 5),
('1', 0, 5),
('infinity', 0, 5),
('sad', 1, 6),
('mad', 0, 6),
('angry', 0, 6),
('A value that a function approaches as the input approaches some value', 1, 7),
('The value of a function at a particular point', 0, 7),
('The slope of a tangent line at a particular point', 0, 7),
('Ugly', 1, 8),
('Pretty', 0, 8),
('Attractive', 0, 8),
('e^x', 1, 9),
('e^(x+1)', 0, 9),
('e^(2x)', 0, 9),
('better', 1, 10),
('best', 0, 10),
('gooder', 0, 10);


INSERT INTO TexamQuestion (idExam, idQuestion, idAnswered) VALUES 
(1, 1, 2),
(1, 2, 4),
(1, 3, 8),
(1, 4, 12),
(1, 5, 13),

(2, 6, 16),
(2, 7, 20),
(2, 8, 22),
(2, 9, 25),
(2, 10, 30),

(3, 1, 1),
(3, 2, 4),
(3, 3, 9),
(3, 4, 10),
(3, 5, 13);

INSERT INTO Treview (idStudent, idSubject) values
(1,2)

insert into TreviewReminder (idReview, idExamQuestion) values
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5);

select * from TreviewReminder

-- Testing scripts

select * from Tstudent
select * from Tcourse
select * from Tsubject
select * from Texam
select * from Tquestion
select * from Talternative
select * from TexamQuestion

select te.idStudent, teq.id, teq.idQuestion, ta.isCorrect, tq.idSubject
from Texam Te 
inner join TexamQuestion Teq on Teq.idExam = Te.id 
inner join Talternative Ta on Ta.id = Teq.idAnswered --and ta.isCorrect = 0
inner join Tquestion Tq on Tq.id = Ta.idQuestion
where te.idStudent = 1