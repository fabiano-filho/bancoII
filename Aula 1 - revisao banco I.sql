-- Tipos de dados
-- Decimal e Numeric
CREATE TABLE MinhaTabela  
(  
	 MeuDecimal DECIMAL(5,2)  
	,MeuNumeric NUMERIC(10,5)
);  
  
INSERT INTO MinhaTabela VALUES (123.45, 12345.12);  

SELECT MeuDecimal, MeuNumeric  
FROM MinhaTabela

-- Float e Real
CREATE TABLE MinhaTabela2  
(  
	 MeuFloat	FLOAT  
	,MeuReal	REAL
 );  
  
INSERT INTO MinhaTabela2 VALUES (123.45, 12345.678);  

SELECT MeuFloat, MeuReal  
FROM MinhaTabela2;

-- Money e SmallMoney
CREATE TABLE MinhaTabela3  
(  
	 MeuMoney		MONEY  
	,MeuSmallMoney	SMALLMONEY
 );  
 
  
INSERT INTO MinhaTabela3 VALUES (123, 12345);  

SELECT MeuMoney, MeuSmallMoney  
FROM MinhaTabela3;

-- date, time, datetime, datetime2, smalldatetime
DECLARE @date 			date = getdate()
DECLARE @time 			time = getdate()
DECLARE @datetime 		datetime = getdate()
DECLARE @datetime2 		datetime2(4)= getdate()
DECLARE @smalldatetime 	smalldatetime = getdate()

SELECT	@datetime 		as datetime, 
		@datetime2 		as datetime2,
		@smalldatetime 	as smalldatetime,
		@date 		as date, 
		@time 		as time

-- char e varchar
DECLARE @char char(5),@varchar varchar(5)
SET @char='GUT'
SET @varchar='GUTIERREZ'
SELECT @char,@varchar

-- geography
DECLARE @g geography; 
SET @g = geography::Point(47.65100, -122.34900, 4326)
SELECT @g.ToString()


CREATE DATABASE ESCOLA -- Cria o banco de dados

-- Criando tabelas e seus respectivos atributos
CREATE TABLE Alunos 
(
	 codigo CHAR(7) NOT NULL,
	 nome VARCHAR(30) NOT NULL,
	 dtNasc DATE,
	 endereco VARCHAR(30),
	 PRIMARY KEY (codigo)
)

CREATE TABLE Disciplinas 
(
	codigo CHAR(7) NOT NULL,
	nome VARCHAR(20) NOT NULL,
	anoCurso CHAR(4),
	depto INT,
	PRIMARY KEY (codigo)
)

CREATE TABLE Inscricoes 
(
	Inscr INT IDENTITY (20210001,1),
	Aluno CHAR(7) NOT NULL,
	Disc CHAR(7) NOT NULL,
	AnoLet CHAR(4),
	PRIMARY KEY (Inscr),
	FOREIGN KEY (Aluno) 	REFERENCES 	ALUNOS(Codigo),
	FOREIGN KEY (Disc) 	REFERENCES 	DISCIPLINAS(Codigo)
)

-- Inserindo dados na Tabela Alunos
INSERT into Alunos (codigo, nome, dtNasc, endereco) values (113503, 'Maria da Dores','1995/12/30', 'Av. Alte Barroso 1500') 
INSERT into Alunos (codigo, nome, dtNasc, endereco) values (213509, 'Paula Soares  ','2020/04/01','Av. Alte Barroso 1500');
INSERT into Alunos (codigo, nome, dtNasc, endereco) values (213555, 'Maria da Dores','2020/04/02','Av. Alte Barroso 1500');
INSERT into Alunos (codigo, nome, dtNasc, endereco) values (213506, 'Dione Gomes   ','2020/04/03','Av. Alte Barroso 1500');
INSERT into Alunos (codigo, nome, dtNasc, endereco) values (213507, 'Jose Maria    ','2020/04/04','Av. Alte Barroso 1500');

-- Inserindo dados na Tabela Disciplinas
INSERT into disciplinas (codigo, nome, anocurso, depto) values ('1','QGIS','2020',1)
INSERT into disciplinas (codigo, nome, anocurso, depto) values ('2','PHP','2020',1)

-- Inserindo dados na Tabela Inscri��es
INSERT INTO Inscricoes (aluno, Disc,anolet) Values ('213506','1','2020');     
INSERT INTO Inscricoes (aluno, Disc,anolet) Values ('213507','1','2020');     
INSERT INTO Inscricoes (aluno, Disc,anolet) Values ('213509','1','2020'); 

-- realizando update
Select * from Alunos
UPDATE Alunos 
SET nome = 'Maria das Dores'
WHERE codigo='113503'
Select * from Alunos

-- realizando delete de um registro
Select * from Alunos
DELETE from Alunos
WHERE codigo = '213555'
Select * from Alunos

-- Copiando elementos de uma tabela para outra tabela

SELECT codigo, nome INTO CALUNOS 
from Alunos

ALTER TABLE CALUNOS
ADD CAD_EMAIL VARCHAR(20)

UPDATE CALUNOS
SET CAD_EMAIL = LOWER(TRIM(SUBSTRING(nome, 1, 5))) + '@gmail.com'

Select * from CAlunos