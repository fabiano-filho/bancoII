-- AULA 05
-- TABELAS TEMPORÁRIAS
-- OBS1: TABELAS TEMPORÁRIAS PERMANECEM ARMAZENADAS ATÉ QUE A SESSÃO SEJA ENCERRADA
-- UMA TABELA TEMPORÁRIA DEVE COMEÇAR COM O CARACTERE # OU ##
-- # -> ESCOPO DE VISIBILIDADE LOCAL, ## -> ESCOPO DE VISIBILIDADE GLOBAL
-- A VISIBILIDADE GLOBAL PERMITE 
-- FORMAS DE PREENCHER UMA TABELA: SELECT COM INTO E COM INSERT MANUALMENTE
USE CONC2022

-- UTILIZANDO FORMA MANUAL:
CREATE TABLE #TMP_INSCR_1 (
	num_inscricao	INT,
	nome			VARCHAR(60),
	num_cpf			CHAR(14),
	sexo			CHAR(9),
	email			CHAR(50),		
	pne				CHAR(3)	
)

-- UTILIZANDO O SELECT P/ CRIAR E PREENCHER TABELA:
SELECT	num_inscricao,
		nome,
		num_cpf,
		sexo,
		email,
		pne
INTO #TMP_INSCR_2		
FROM INSCRITOS
WHERE pne = 'SIM'


SELECT	num_inscricao,
		nome,
		num_cpf,
		sexo,
		email,
		pne
INTO #TMP_MARIAS_PNE		
FROM INSCRITOS
WHERE nome like 'maria%' and pne = 'SIM'


-- EXERCÍCIO 1
USE CONC2022

SELECT	C.descricao						AS Cargo,
		C.valor_inscricao				AS Valor,
		COUNT(*)						AS Qtde,
		COUNT(*) * C.valor_inscricao	AS SubTotal
INTO #TTT
FROM CARGO AS C, INSCRITOS AS I
WHERE C.codcargo = I.cod_cargo1
GROUP BY C.descricao, C.valor_inscricao
ORDER BY 1, 3
---------------------------------------
DECLARE @FIN money, @FLAG varchar(20)
SELECT @FIN=SUM(Valor * Qtde)
FROM #TTT
---------------------------------------
SELECT * FROM #TTT
SELECT @FIN AS Total_Geral
---------------------------------------
-- CONTROLE DE FLUXO IF ELSE
IF @FIN > 1000000
	SET @FLAG = 'META ATINGIDA'
ELSE
	SET @FLAG = 'DIVULGAR MAIS'
SELECT @FLAG ARRECADACAO

DROP TABLE #TTT

-- EXERCÍCIO 2
USE CONC2022
CREATE PROCEDURE SP_BuscaCargo 
	@query as varchar(20)
AS
DECLARE @QTDE_INSCRITOS INT
BEGIN
	SELECT	*
	FROM CARGO, INSCRITOS
	WHERE codcargo = cod_cargo1 AND descricao LIKE '%'+ @query +'%'

	
	SET @QTDE_INSCRITOS = (
		SELECT COUNT(*)
		FROM CARGO, INSCRITOS
		WHERE codcargo = cod_cargo1 AND 
		descricao LIKE '%'+ @query +'%'
	)
	IF @QTDE_INSCRITOS = 0
			PRINT 'Nenhum inscrito no cargo que contém a string "' + @query + '"'
	ELSE
			PRINT 'Total de inscritos no cargo que contém a string "' + @query + '" é: ' + CAST(@QTDE_INSCRITOS AS VARCHAR)
END

EXEC SP_BuscaCargo 'AG'
DROP PROCEDURE SP_BuscaCargo

-- EXERCÍCIO 3

CREATE PROCEDURE SP_BuscaCargo 
	@query as varchar(20)
AS
DECLARE @QTDE_INSCRITOS INT
BEGIN
	SELECT	*
	FROM CARGO, INSCRITOS
	WHERE codcargo = cod_cargo1 AND descricao LIKE '%'+ @query +'%'

	
	SET @QTDE_INSCRITOS = (
		SELECT COUNT(*)
		FROM CARGO, INSCRITOS
		WHERE codcargo = cod_cargo1 AND 
		descricao LIKE '%'+ @query +'%'
	)
	IF @QTDE_INSCRITOS = 0
			PRINT 'Nenhum inscrito no cargo que contém a string "' + @query + '"'
	ELSE
			PRINT 'Total de inscritos no cargo que contém a string "' + @query + '" é: ' + CAST(@QTDE_INSCRITOS AS VARCHAR)
END


-- Estrutura de repetição WHILE
DECLARE @NUM INT = 1, @SOMA INT = 0
WHILE @NUM <= 3
	BEGIN
		SET @SOMA += @NUM
		SET @NUM += 1
		SELECT	@SOMA AS SOMA,
				@NUM AS NUMERO
	END


-- EXERCÍCIO 4

CREATE PROCEDURE SP_CALC_SOMA 
@N AS INT
AS
BEGIN
	CREATE TABLE #SOMA_NATURAIS (
		Numero int,
		Soma_acumulada int
	)

	DECLARE @NUM INT = 1, @SOMA INT = 0
	WHILE @NUM <= @N
		BEGIN
			SET @SOMA += @NUM
			INSERT INTO #SOMA_NATURAIS VALUES (@NUM, @SOMA)
			SET @NUM += 1
		END
	SELECT * FROM #SOMA_NATURAIS
	DROP TABLE #SOMA_NATURAIS
END

EXEC SP_CALC_SOMA 20