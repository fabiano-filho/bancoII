USE CONC2021

CREATE TABLE ##TEMP_CARGO (
	codcargo INT PRIMARY KEY,
	descricao VARCHAR(100) NULL,
	valor_inscricao NUMERIC(10, 2) NULL,
	grau NUMERIC(11, 0) NULL
)

-- DECLARANDO VARIÁVEIS
DECLARE @cod INT, @cargo VARCHAR(100), @valor NUMERIC(10, 2), @grau NUMERIC(11, 0)

-- DECLARANDO O CURSOR
DECLARE meucursor CURSOR FOR 
-- DEFININDO CONJUNTO DE DADOS
SELECT	codcargo,
		descricao,
		valor_inscricao,
		grau
FROM CARGO

-- ABRINDO CURSOR
OPEN meucursor

FETCH NEXT FROM meucursor INTO @cod, @cargo, @valor, @grau

WHILE @@FETCH_STATUS = 0
BEGIN 
	INSERT INTO ##TEMP_CARGO VALUES (@cod, @cargo, @valor, @grau)
	FETCH NEXT FROM meucursor INTO @cod, @cargo, @valor, @grau
END

CLOSE meucursor
DEALLOCATE meucursor

SELECT * FROM ##TEMP_CARGO
SELECT * FROM CARGO

DROP PROCEDURE SP_novaTabela

CREATE PROCEDURE SP_novaTabela
AS
BEGIN
	CREATE TABLE ##TEMP (
		codcargo INT PRIMARY KEY,
		descricao VARCHAR(100) NULL,
		valor_inscricao NUMERIC(10, 2) NULL,
		grau NUMERIC(11, 0) NULL
	)
	-- DECLARANDO VARIÁVEIS
	DECLARE @id INT, @nome VARCHAR(100), @value NUMERIC(10, 2), @escolaridade NUMERIC(11, 0)

	-- DECLARANDO O CURSOR
	DECLARE meucursor CURSOR FOR 
	-- DEFININDO CONJUNTO DE DADOS
	SELECT	codcargo,
			descricao,
			valor_inscricao,
			grau
	FROM CARGO

	-- ABRINDO CURSOR
	OPEN meucursor

	FETCH NEXT FROM meucursor INTO @id, @nome, @value, @escolaridade

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		INSERT INTO ##TEMP VALUES (@id, @nome, @value, @escolaridade)
		FETCH NEXT FROM meucursor INTO @id, @nome, @value, @escolaridade
	END
	SELECT * FROM ##TEMP
	DROP TABLE ##TEMP
	CLOSE meucursor
	DEALLOCATE meucursor
END

EXEC SP_novaTabela


USE CONC2022
SELECT * FROM CARGO
-- DECLARANDO VARIÁVEIS
DECLARE @cod_cargo int, @valor_insc MONEY

-- DECLARANDO CURSOR
DECLARE cursor2 CURSOR FOR 
SELECT	codcargo,
		valor_inscricao
FROM CARGO

-- ABRINDO CURSOR
OPEN cursor2

FETCH NEXT FROM cursor2 INTO @cod_cargo, @valor_insc

WHILE @@FETCH_STATUS = 0
BEGIN 
	UPDATE CARGO
	SET valor_inscricao = @valor_insc + ((@valor_insc * 10) / 100)
	WHERE codcargo = @cod_cargo
	FETCH NEXT FROM cursor2 INTO @cod_cargo, @valor_insc
END

CLOSE cursor2
DEALLOCATE cursor2

SELECT * FROM CARGO

