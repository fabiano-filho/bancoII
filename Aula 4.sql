-- Exercício da aula 03
-- adicionando descricao do cargo na procedure
-- comando para excluir uma procedure: DROP PROCEDURE nome_procedure
-- para alterar uma procedure use: ALTER PROCEDURE nome_procedure

USE CONC2022
GO
ALTER PROCEDURE SP_Lista_Candidatos_Cargo
@cargo int AS    
DECLARE @total int, @desc_cargo char(30)
Begin
   SELECT	cg.descricao		as Cargo,
			cd.num_inscricao	as Inscricao, 
			cd.nome				as Nome,
			cd.num_cpf			as CPF,
			cd.data_nasc		as Nasc,
			cd.fone				as Fone
   FROM   inscritos cd, cargo cg 
   WHERE  cd.cod_cargo1 = cg.codcargo and cd.cod_cargo1 = @cargo
   ORDER BY 2
   --------------------
   SET @total = (
		SELECT count(num_inscricao)
		FROM   inscritos cd, cargo cg
		WHERE  cd.cod_cargo1=cg.codcargo and cd.cod_cargo1=@cargo
	)
	SET @desc_cargo = (
		SELECT cg.descricao
		FROM CARGO as cg
		WHERE cg.codcargo = @cargo
	)
	PRINT 'Total de inscritos para o cargo '+ RTRIM(@desc_cargo) + 'é ' + CAST(@total AS CHAR(10))
End

EXEC SP_Lista_Candidatos_Cargo 4

-- Exercício 1 aula 04 - versao 2
USE SERRA
GO
ALTER PROCEDURE SP_Lista_Produtos_da_Seção
@secao smallint, @taxa int
AS  
Begin
  SELECT	P.PRO_SECAO, 
			S.SEC_DESCRICAO, 
			P.PRO_CODIGO, 		
			P.PRO_NOME, 
			P.PRO_PRECO_VAREJO,
			-- atualiza o preco com base na taxa passada e arredonda para duas casas decimais: 
			ROUND(P.pro_preco_varejo + (P.pro_preco_varejo * @taxa / 100), 2) AS PRECO_ATUALIZADO
  FROM  Produtos P, Secao AS S
  WHERE  P.pro_secao = S.sec_codigo and P.pro_secao = @secao and P.pro_preco_varejo > 0
 ORDER BY  4
End     

EXEC SP_Lista_Produtos_da_Seção 33, 10


-------------------------------------------------------
-- Excluindo uma stored procedure

Use SERRA
Go
CREATE procedure SP_BuscaCliente2 (@Nome varchar(100) )
AS
	 SELECT distinct c.cad_nome 
	 FROM 	Cadastros c
	 WHERE c.cad_nome like @Nome + '%'

EXEC SP_BuscaCliente2 'Paulo'
-- comando para apagar procedure
DROP PROC SP_BuscaCliente2 


-- Exercício 2 aula 04

USE CONC2022
GO
ALTER PROCEDURE SP_Lista_Candidatos_Idade 
@idade_menor int, @idade_maior int
AS
BEGIN
	SELECT	I.num_inscricao AS NUM_INSCRICAO,
			I.nome			AS NOME,
			I.data_nasc		AS DATA_NASCIMENTO,
			(DATEPART(YEAR, GETDATE()) - DATEPART(YEAR, I.data_nasc)) AS IDADE
	FROM INSCRITOS I
	WHERE DATEDIFF(YEAR, I.data_nasc, GETDATE()) BETWEEN @idade_menor and @idade_maior
	ORDER BY 3 DESC
END

EXEC SP_Lista_Candidatos_Idade 20, 25

-- Exercício 3 aula 04
USE CONC2022
GO 
ALTER PROCEDURE SP_Arrecadacao_Por_Cargo 
AS
BEGIN
	SELECT	C.descricao								AS NOME_CARGO,
			C.valor_inscricao						AS VALOR_INSC,
			COUNT(I.data_pag)						AS QTD_INSCRICOES,
			COUNT(I.data_pag) * C.valor_inscricao	AS TOTAL

	FROM CARGO AS C, INSCRITOS AS I
	WHERE C.codcargo = I.cod_cargo1 and data_pag IS NOT NULL
	GROUP BY C.descricao, C.valor_inscricao
	ORDER BY 1
END

EXEC SP_Arrecadacao_Por_Cargo

-- Exercício 4 aula 04

USE CONC2022 --versao 2 
GO 
ALTER PROCEDURE SP_Arrecadacao_Por_Cargo 
AS
DECLARE @total_arrecadado NUMERIC(10,2)
BEGIN
	SELECT	C.descricao								AS NOME_CARGO,
			C.valor_inscricao						AS VALOR_INSC,
			COUNT(I.data_pag)						AS QTD_INSCRICOES,
			COUNT(I.data_pag) * C.valor_inscricao	AS TOTAL

	FROM CARGO AS C, INSCRITOS AS I
	WHERE C.codcargo = I.cod_cargo1 and data_pag IS NOT NULL
	GROUP BY C.descricao, C.valor_inscricao
	ORDER BY 1
	-------------
	SET @total_arrecadado = (
		SELECT SUM(valor_inscricao) as total_arrecadado
		FROM inscritos i INNER JOIN cargo c ON cod_cargo1 = codcargo
		WHERE data_pag IS NOT NULL
	)
	PRINT 'O total arrecado foi: ' + CAST(@total_arrecadado AS CHAR(10))
END

EXEC SP_Arrecadacao_Por_Cargo

-- Exercício 5 aula 04

USE CONC2022
GO
ALTER PROC SP_Lista_PNE
@cargo smallint
AS 
BEGIN
	SELECT	C.descricao			AS CARGO,
			I.num_inscricao		AS INSCRICAO,
			I.nome				AS NOME,
			I.ci				AS RG,
			I.pne				AS PNE

	FROM INSCRITOS I, CARGO C
	WHERE I.cod_cargo1 = C.codcargo AND I.cod_cargo1 = @cargo AND I.pne LIKE 'SIM'
	ORDER BY 1, 3
END

EXEC SP_Lista_PNE 4