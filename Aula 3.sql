--- SINTAXE PROCEDURE 
USE CONC2022 
GO  
CREATE PROCEDURE SP_HelloWorld AS 
BEGIN 
    SELECT 'Hello, world!' 
END 
 
--- SINTAXE PROCEDURE 
EXEC SP_HelloWorld 
 
---------------------------------------------------------------- 
 
--- SINTAXE PROCEDURE 
USE CONC2022 
GO  
CREATE PROCEDURE SP_Msg AS 
DECLARE     @msg varchar(40) 
BEGIN 
    SELECT  @msg = 'Esta é a mensagem' 
    PRINT   @msg 
END 
 
--- SINTAXE PROCEDURE 
EXEC SP_Msg 
 
---------------------------------------------------------------- 
 
--- STORED PROCEDURE 
USE CONC2022 
GO 
CREATE PROCEDURE SP_BuscaInscrito (@nome AS VARCHAR(155)) AS  
SELECT DISTINCT I.nome 
FROM INSCRITOS AS I 
WHERE I.nome like @nome + '%' 

--- EXECUTANDO PROCEDURE  
EXEC SP_BuscaInscrito @nomeCliente 
 
---------------------------------------------------------------- 
 
--- BUSCANDO NO PROCEDURE COM VARIÁVEL 
USE CONC2022 
GO  
DECLARE @nomeCliente VARCHAR(30) 
SET     @nomeCliente = 'Paulo' 

EXEC SP_BuscaInscrito @nomeCliente 
 
---------------------------------------------------------------- 
 
USE CONC2022 
GO  
DECLARE     @Qtde_Souza INT  
SET         @Qtde_Souza = ( 
                            SELECT COUNT(*) 
                            FROM INSCRITOS 
                            WHERE nome like '%paulo%' 
                        ) 
PRINT   'A quantidade de pessoas com o nome Paulo em ' 
        +Convert(Char(10), GetDate(), 103) 
        +' é ' 
        +CAST(@Qtde_Souza AS CHAR(10)) 
 
-- SAÍDA: A quantidade de pessoas com o nome Souza em 09/06/2022 é 875   
 
---------------------------------------------------------------- 
 
--- SINTAXE PROCEDURE 
USE SERRA2022 
GO  
CREATE PROCEDURE SP_Lista_Produtos_da_Seção (@cod_sec AS VARCHAR(3)) AS 
    BEGIN 
        SELECT  S.SEC_CODIGO        AS ID_SESSION, 
                S.SEC_DESCRICAO     AS DESC_SESSION, 
                P.PRO_CODIGO        AS ID_PROD, 
                P.PRO_NOME          AS NAME_PROD, 
                P.PRO_PRECO_VAREJO  AS VALUE_PROD 

        FROM   SECAO                AS S 
        INNER JOIN  PRODUTOS        AS P 
        ON S.SEC_CODIGO = P.PRO_SECAO 
        WHERE S.SEC_CODIGO like @cod_sec 
        ORDER BY 4 
    END 
GO 
 
--- CHAMANDO PROCEDURE 
EXEC SP_Lista_Produtos_da_Seção @cod_sec= '1' 
 
---------------------------------------------------------------- 
 
USE CONC2022 
GO  
CREATE PROCEDURE SP_Relatório (@codigoCargo AS VARCHAR(3)) AS 
BEGIN 
    SELECT    num_inscricao, 
            nome, 
            num_cpf, 
            data_nasc, 
            fone, 
            cod_cargo1 
    FROM INSCRITOS 
    WHERE cod_cargo1 like @codigoCargo 
 
    DECLARE   @Qtde_Inscritos INT  
    SET       @Qtde_Inscritos = ( 
                                SELECT COUNT(*) 
                                FROM INSCRITOS as I 
                                WHERE I.cod_cargo1 like @codigoCargo 
                            ) 
    PRINT 'A quantidade de inscritos é ' 
    +CAST(@Qtde_Inscritos AS CHAR(10)) 
END 
GO 
 
EXEC SP_Relatório @codigoCargo = '1'

-- credits @JoonMarion