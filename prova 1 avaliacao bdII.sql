-- 1 QUESTÃO 
UPDATE CARGO
SET valor_inscricao = 50
WHERE grau = 1

UPDATE CARGO
SET valor_inscricao = 60
WHERE grau = 2

UPDATE CARGO
SET valor_inscricao = 80
WHERE grau = 3

UPDATE CARGO
SET valor_inscricao = 100
WHERE grau = 4

UPDATE INSCRITOS
SET data_nasc = '01-01-1950'
WHERE data_nasc < '1950-12-31'

UPDATE INSCRITOS
SET data_nasc = '01-01-2002'
WHERE data_nasc >= '2000-01-01'



-- 2 QUESTÃO

CREATE PROCEDURE SP_ANIVERSARIO (@mes_nasc as VARCHAR(2))
AS
BEGIN
	SELECT	NOME,
			DATEPART(MONTH, DATA_NASC)	AS MES,
			DATEPART(DAY, DATA_NASC)	AS DIA,
			DATEPART(YEAR, DATA_NASC)	AS ANO
	FROM INSCRITOS
	WHERE NOME LIKE '%MARIA%' AND @mes_nasc in (4, 5, 6) AND
	DATA_NASC LIKE ('%%-%' + @mes_nasc + '-%%')
	ORDER BY 2, 3, 1
END

EXEC SP_ANIVERSARIO '10'


-- 3 QUESTÃO

CREATE PROCEDURE SP_INSCRITOS ( @cod_cargo as int)
AS
BEGIN
	SELECT	C.descricao AS CARGO,
			I.num_inscricao AS NUM_INSCRICAO,
			I.data_insc AS DATA_INSCRICAO,
			I.NOME AS CANDIDATO,
			I.bairro AS BAIRRO,
			I.cidade AS CIDADE,
			I.sexo AS SEXO,
			I.email AS EMAIL
	FROM INSCRITOS AS I, CARGO AS C
	WHERE C.codcargo = I.cod_cargo1 AND C.codcargo = @cod_cargo
	ORDER BY 1, 3, 4	
END

EXEC SP_INSCRITOS 1


-- 4 QUESTÃO

CREATE PROCEDURE SP_QIDE_INSCR_POR_CARGO ( @cod_cargo as int)
AS
BEGIN
	SELECT	C.descricao AS CARGO,
			COUNT(*)	AS QTDE_INSCRITOS
	FROM INSCRITOS AS I,
	CARGO AS C
	WHERE  C.codcargo = I.cod_cargo1 AND C.codcargo = @cod_cargo
	GROUP BY C.codcargo, C.descricao
END

EXEC SP_QIDE_INSCR_POR_CARGO 2


-- 5 QUESTÃO

CREATE PROCEDURE SP_QIDE_POR_ESCOLARIDADE ( @cod_cargo as int)
AS
BEGIN
	SELECT	C.descricao AS CARGO,
			COUNT(*)	AS QTDE_INSCRITOS
	FROM INSCRITOS AS I, CARGO AS C, ESCOLARIDADE AS E
	WHERE  C.codcargo = I.cod_cargo1 AND C.grau = E.id AND C.grau = @cod_cargo
	GROUP BY C.codcargo, C.descricao
END

EXEC SP_QIDE_POR_ESCOLARIDADE 2

