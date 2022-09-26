-- Procedure para exportar arq de log txt 
USE master

-- Configurando as permissoes do sql server

SP_CONFIGURE 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO

SP_CONFIGURE 'SHOW ADVANCED OPTIONS', 1;
GO
RECONFIGURE;
GO

SP_CONFIGURE 'OLE AUTOMATION PROCEDURES', 1;
GO
RECONFIGURE;
GO

-- Verifica se diretorio ja existe
CREATE PROCEDURE [dbo].SP_Arquivo_Existe (
    @Ds_Arquivo VARCHAR(255),
    @Saida BIT OUTPUT
)
AS BEGIN
 
    DECLARE @Query VARCHAR(8000) = 'IF EXIST "' + @Ds_Arquivo + '" ( echo 1 ) ELSE ( echo 0 )'
 
    DECLARE @Retorno TABLE (
        Linha INT IDENTITY(1, 1),
        Resultado VARCHAR(MAX)
    )
 
    INSERT INTO @Retorno
    EXEC master.dbo.xp_cmdshell 
        @command_string = @Query
 
    SELECT @Saida = Resultado
    FROM @Retorno
    WHERE Linha = 1
 
END
GO

-- Criando SP que cria diretorio
CREATE PROCEDURE [dbo].SP_Cria_Diretorio (
    @Ds_Diretorio VARCHAR(255)
)
AS BEGIN
    
    SET NOCOUNT ON
 
    DECLARE @Query VARCHAR(8000) = 'mkdir "' + @Ds_Diretorio + '"'
 
    DECLARE @Retorno TABLE ( Resultado VARCHAR(MAX) )
 
    INSERT INTO @Retorno
    EXEC master.dbo.xp_cmdshell 
        @command_string = @Query
    
END

-- Criando SP que escreve no arquivo txt

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WriteToFile]

@file	VARCHAR(2000) = 'C:\LOG_DB_FRR\log.txt',
@text	VARCHAR(2000)

AS
BEGIN
	DECLARE @OLE		INT
	DECLARE @FileId		INT

	DECLARE @SAIDA BIT;

	EXEC SP_Arquivo_Existe 
	@Ds_Arquivo = 'C:\LOG_DB_FRR',

	@SAIDA = @SAIDA OUTPUT
	IF @SAIDA = 0 
		EXEC SP_Cria_Diretorio
		@Ds_Diretorio = 'C:\LOG_DB_FRR'

	EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT

	EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileId OUT, @file, 8, 1

	EXECUTE sp_OAMethod @FileId, 'WriteLine', NULL, @text
	
	EXECUTE sp_OADestroy @FileId
	EXECUTE sp_OADestroy @OLE
END
GO

CREATE DATABASE UEPA_BDII;
GO

USE UEPA_BDII;
GO

CREATE TABLE FUNCIONARIOS (
	MATRICULA VARCHAR(4) NOT NULL,
	CPF VARCHAR(15) NOT NULL,
	NOME VARCHAR(40) NOT NULL,
	LOCAL_NASC VARCHAR(20) NOT NULL,
	ESCOLARIDADE CHAR(1) NOT NULL,
	CARGO INT,
	ADMISSAO DATE NOT NULL,
	NASCIMENTO DATE NOT NULL,
	DEPENDENTES INT,
	VALE_TRANSP CHAR(1) NOT NULL,
	PLANO_SAUDE CHAR(1) NOT NULL,
	PRIMARY KEY (MATRICULA)
);
GO

CREATE TRIGGER TG_LOG_INSERT
ON FUNCIONARIOS
	AFTER INSERT
AS
BEGIN
	DECLARE	@MATRICULA	VARCHAR(4),
			@NOME		VARCHAR(40),
			@TEXTO		VARCHAR(MAX)

	-- DECLARANDO O CURSOR
	DECLARE meucursor CURSOR FOR
	-- DEFININDO CONJUNTO DE DADOS
	SELECT MATRICULA, NOME FROM INSERTED ORDER BY 1
	-- ABRINDO CURSOR
	OPEN meucursor
	FETCH NEXT FROM meucursor INTO @MATRICULA, @NOME
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @TEXTO = '[' + CAST(CURRENT_TIMESTAMP AS NVARCHAR(MAX)) + '] ' + @MATRICULA + ' ' + @NOME
		EXEC [dbo].[WriteToFile] @text = @TEXTO
		FETCH NEXT FROM meucursor INTO @MATRICULA, @NOME
	END
	CLOSE meucursor
	DEALLOCATE meucursor
END
GO

INSERT INTO FUNCIONARIOS
(MATRICULA,CPF,NOME,LOCAL_NASC,ESCOLARIDADE,CARGO,ADMISSAO,NASCIMENTO,DEPENDENTES,VALE_TRANSP,PLANO_SAUDE) VALUES
('1002','333.145.271-87','DIONE MARGARETE SOUZA DA SILVA','AFUA','G',3,'2002-08-06','1997-02-21','0','S','S'),
('1005','186.403.622-20','LUCAS DA CRUZ POMPEU','BELEM','M',2,'2004-08-25','1962-09-05','0','N','S'),
('1006','393.467.572-72','ERICKSON REINALDO VIEIRA ISABEL','CAPITAO POCO','G',4,'2005-01-21','1986-07-03','2','N','S'),
('1010','45.317.887.2-91','ANTONIO CARLOS MARQUES DA SILVA','MARABA','S',1,'2005-09-03','1995-06-05','1','S','S'),
('1015','22.760.547.2-72','HELENI BRITO DA SILVA','BRAGANCA','S',1,'2005-06-06','1954-12-14','2','N','S'),
('1020','46.276.254.2-15','ALBERTO SILVA MARQUES','MOJU','M',2,'2006-10-07','1991-10-10','2','N','S'),
('1026','52.260.569.2-34','IVETE CORDEIRO DA SILVA','BELEM','D',6,'2010-06-16','1995-03-25','1','N','N'),
('1038','37.509.195.2-68','ARNALDO BESSA RODRIGUES','BELEM','D',6,'2010-06-12','1972-09-23','1','N','S'),
('1040','03.829.430.2-30','SÉRGIO GAMA MOREIRA','TAILANDIA','M',1,'2010-11-22','1980-07-21','1','N','S'),
('1042','09.740.821.2-00','KLEIBER DE SOUSA','SALVATERRA','M',1,'2010-11-23','1951-11-09','1','N','S'),
('1044','06.716.301.9-92','DIARACY ROFFE FERREIRA DE LEMOS','BELEM','G',5,'2011-09-18','1957-06-23','0','N','N'),
('1045','01.017.507.2-28','CARLOS CLEYSON DAVID DE SOUZA','CASTANHAL','S',1,'2012-08-19','1985-01-15','0','S','S'),
('1050','83.609.695.2-34','ANTONIO MARCOS CARDOSO DA SILVA','BELEM','E',4,'2012-09-17','1982-12-20','3','N','S'),
('1052','65.516.265.2-15','ANTONIA DA SILVA MORAES OLIVEIRA','SANTAR•EM','G',4,'2013-06-19','1980-10-12','2','N','S'),
('1054','24.771.228.2-72','RAFAEL BARROS PRATES','PARAGOMINAS','S',1,'2013-10-10','1944-12-29','1','S','S'),
('1055','97.327.875.2-04','CARLOS BARBOSA IBIAPINO','BELEM','D',5,'2013-10-11','1992-06-16','3','N','N'),
('1060','29.501.210.2-00','ARNALDO MONTEIRO DA SILVA','MOJU','G',4,'2013-12-15','1936-05-17','1','N','S'),
('1065','01.861.833.2-10','MARIA SEMIRAMES DA LUZ','BELEM','G',4,'2015-02-16','1982-09-14','1','S','S'),
('1067','10.831.010.2-15','RAYMUNDO NONNATO MORAES','BELEM','S',1,'2015-02-24','1981-01-22','0','S','S'),
('1068','04.855.159.2-04','ALUIZIO MACIEL FERREIRA','MOJU','D',6,'2015-02-26','1943-09-04','1','N','S')
-------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE CARGOS (
	CARGO INT NOT NULL,
	NOMECARGO VARCHAR(40) NOT NULL,
	SALARIO NUMERIC(10,2) NOT NULL,
	PRIMARY KEY (CARGO)
)
------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO CARGOS (CARGO, NOMECARGO,SALARIO) VALUES
(1, 'AUXILIAR ADMINISTRATIVO', 954),
(2, 'TECNICO ADMINISTRATIVO', 1200),
(3, 'GESTAO.AUXILIAR', 2000),
(4, 'PROF.AUXILIAR', 3000),
(5, 'PROF.ASSISTENTE', 6000),
(6, 'PROF.ADJUNTO', 10000)

CREATE TABLE DSC_INSS (
	COD			INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	SALARIO		MONEY,
	DESCONTO	MONEY
)
GO

CREATE TABLE DSC_IRRF (
	COD			INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	SALARIO		MONEY,
	ALIQUOTA	MONEY,
	VL_DEDUZIR	MONEY,
	DEPENDENTE	MONEY
)
GO

CREATE TABLE DSC_PLANO_SAUDE (
	COD				INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DSC_FUNC		MONEY,
	DSC_DEPENDENTE	MONEY
)
GO

CREATE TABLE DSC_VALE_TRANSP (
	COD			INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	VALE_TRANSP	MONEY
)
GO

INSERT INTO DSC_PLANO_SAUDE VALUES 
( 3.75, 1.15)

INSERT INTO DSC_INSS VALUES 
(1212, 7.5),
(2427.35, 9),
(3641.03, 12),
(7087.22, 14),
(0.0, 992.21)

INSERT INTO DSC_IRRF VALUES 
(1903.98, 0.0, 0.0, 189.59),
(2826.65, 7.5, 142.80, 189.59),
(3751.06, 15, 354.80, 189.59),
(4664.68, 22.5, 636.13, 189.59),
(0, 27.5, 869.36, 189.59)

INSERT INTO DSC_VALE_TRANSP VALUES 
(6)

---------- PROVENTOS

CREATE TABLE PROV_ESCOLARIDADE (
	COD			CHAR(1) PRIMARY KEY,
	DESCRICAO	VARCHAR(100),
	PROV_ESC	MONEY
)
GO

CREATE TABLE PROV_SAL_FAMILIA (
	COD			INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	VALOR		MONEY,
	SAL_MAX		MONEY
)
GO

CREATE TABLE PROVENTOS (
	COD					INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	AUX_ALIMENTACAO		MONEY,
	REPOUSO_REM			NUMERIC(3, 2),
	ANUENIO				MONEY,
	VALE_CULTURA		MONEY,
	COD_SAL_FAMILIA		INT NOT NULL,
	FOREIGN KEY (COD_SAL_FAMILIA)	REFERENCES PROV_SAL_FAMILIA(COD),
)
GO

INSERT INTO PROV_SAL_FAMILIA VALUES
(56.47, 1655.98)

INSERT INTO PROV_ESCOLARIDADE VALUES
('S', 'MÉDIO', 0.0),
('G', 'GRADUADO', 1.18),
('E', 'ESPECIALIZACAO', 1.25),
('M', 'MESTRADO', 1.54),
('D', 'DOUTORADO', 2.04)

INSERT INTO PROVENTOS VALUES
(750.0, 1.01, 125.00, 80.00, 1)

CREATE PROCEDURE SP_CALC_PROVENTOS
	@MATRICULA VARCHAR(10),
	@retorno_salario_provento MONEY OUTPUT,
	@retorno_repouso_rem MONEY OUTPUT,
	@retorno_grat_escolaridade MONEY OUTPUT,
	@retorno_anuenio MONEY OUTPUT,
	@retorno_sal_familia MONEY OUTPUT,
	@retorno_vale_cultura MONEY OUTPUT,
	@retorno_aux_alimentacao MONEY OUTPUT

AS
	BEGIN
		DECLARE @aux_alimentacao	MONEY,
				@repouso_rem		NUMERIC(3, 2),
				@anuenio			MONEY,
				@vale_cult			MONEY,
				@cod_sal_familia	INT,
				@salario_bruto		MONEY,
				@salario_final		MONEY,
				@nome				VARCHAR(100),
				@dependentes		INT,
				@sal_max_prov_fml	MONEY,
				@prov_sal_fml		MONEY,
				@prov_escolaridade	MONEY,
		        @escolaridade_funcionario CHAR(1)
		
		SELECT	@aux_alimentacao	= AUX_ALIMENTACAO, 
				@repouso_rem		= REPOUSO_REM,
				@anuenio			= ANUENIO,
				@vale_cult			= VALE_CULTURA,
				@cod_sal_familia	= COD_SAL_FAMILIA
		FROM PROVENTOS
		
		SELECT	@nome						= F.NOME,
				@escolaridade_funcionario	= F.ESCOLARIDADE,
				@salario_bruto				= C.SALARIO,
				@dependentes				= F.DEPENDENTES
		FROM FUNCIONARIOS F, CARGOS C
		WHERE F.CARGO = C.CARGO AND F.MATRICULA = @MATRICULA 
		
		SELECT	@sal_max_prov_fml	= SAL_MAX,
				@prov_sal_fml		= VALOR
		FROM PROV_SAL_FAMILIA

		SELECT @prov_escolaridade = E.PROV_ESC
		FROM PROV_ESCOLARIDADE E
		WHERE E.COD = @escolaridade_funcionario
		
		DECLARE @ADMISSAO DATE, @DATA_HOJE DATE, @ANO_TRABALHO INT;
		SET @DATA_HOJE = GETDATE()
		SELECT @ADMISSAO = ADMISSAO FROM FUNCIONARIOS
		SELECT @ANO_TRABALHO = DATEDIFF(YEAR, @ADMISSAO, @DATA_HOJE)

		IF @salario_bruto <= @sal_max_prov_fml
		BEGIN
			IF @dependentes >= 1
			BEGIN
				SET @retorno_sal_familia = @dependentes * @prov_sal_fml
				SET @salario_final += @retorno_sal_familia
			END
		END
		ELSE
			SET @retorno_sal_familia = 0.0

		SET @retorno_repouso_rem = (@salario_bruto * @repouso_rem) - @salario_bruto
		
		IF @escolaridade_funcionario = 'S'
		BEGIN
			SET @retorno_grat_escolaridade = 0.0
		END
		ELSE
		BEGIN
			SET @retorno_grat_escolaridade = @prov_escolaridade * @salario_bruto - @salario_bruto
		END

		SET @retorno_anuenio = @anuenio * @ANO_TRABALHO
		SET @retorno_vale_cultura = @vale_cult
		SET @retorno_aux_alimentacao = @aux_alimentacao

		SET @salario_final = @salario_bruto
		SET @salario_final += @retorno_repouso_rem + @retorno_grat_escolaridade + 
						      @retorno_anuenio + @retorno_vale_cultura + @retorno_aux_alimentacao
		SET @retorno_salario_provento = @salario_final	
	END
GO

CREATE PROCEDURE SP_CALC_DESCONTOS  @MATRICULA VARCHAR(10), 
	@VALOR_RETORNO MONEY OUTPUT,
	@retorno_IRRF MONEY OUTPUT,
	@retorno_INSS MONEY OUTPUT,
	@retorno_vale_transp MONEY OUTPUT,
	@retorno_plano_saude MONEY OUTPUT
AS
	BEGIN
		DECLARE @escolaridade				CHAR(1),
				@salario_bruto				MONEY,
				@salario_final_dsc			MONEY,
				@nome						VARCHAR(100),
				@dependentes				INT,
		        @escolaridade_funcionario	CHAR(1),
				@plano_saude				CHAR(1),
				@dsc_plano_saude_func		MONEY,
				@dsc_plano_saude_dep		MONEY,
				@vale_transp				CHAR(1),
				@dsc_transp					MONEY,
				@inss						MONEY
		
		SELECT	@nome					= F.NOME,
				@escolaridade			= F.ESCOLARIDADE,
				@salario_bruto			= C.SALARIO,
				@dependentes			= F.DEPENDENTES,
				@plano_saude			= F.PLANO_SAUDE,
				@vale_transp			= F.VALE_TRANSP
		FROM FUNCIONARIOS F, CARGOS C
		WHERE F.CARGO = C.CARGO AND F.MATRICULA = @MATRICULA 
		
		SELECT	@dsc_plano_saude_func = DSC_FUNC,
				@dsc_plano_saude_dep  = DSC_DEPENDENTE
		FROM DSC_PLANO_SAUDE
		
		SELECT @dsc_transp = VALE_TRANSP
		FROM DSC_VALE_TRANSP

		SET @salario_final_dsc = @salario_bruto

		IF @plano_saude = 'S'
		BEGIN
			DECLARE @desconto_plano_f MONEY, @desconto_plano_d MONEY = 0;
			SET @desconto_plano_f = (@salario_bruto * @dsc_plano_saude_func) / 100
			IF @dependentes >= 1
			BEGIN
				SET @desconto_plano_d = (@salario_bruto * (@dependentes * @dsc_plano_saude_dep)) / 100
			END
			SET @salario_final_dsc = @salario_bruto - (@desconto_plano_d + @desconto_plano_f)
		END

		IF @vale_transp = 'S'
		BEGIN
			SET @salario_final_dsc = @salario_final_dsc - (@salario_bruto * @dsc_transp) / 100
		END
		
		--- inss
		DECLARE @SALARIO_INSS MONEY, @DESCONTO_INSS MONEY, @AUX MONEY, @MAX_SAL_INSS MONEY
		SET @AUX = 1.0
		SET @MAX_SAL_INSS = 0
		-- DECLARANDO O CURSOR
		DECLARE mcursor CURSOR FOR
		-- DEFININDO CONJUNTO DE DADOS
		SELECT SALARIO, DESCONTO FROM DSC_INSS
		-- ABRINDO CURSOR
		OPEN mcursor
		FETCH NEXT FROM mcursor INTO @SALARIO_INSS, @DESCONTO_INSS
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @SALARIO_INSS > @MAX_SAL_INSS
				BEGIN
					SET @MAX_SAL_INSS = @SALARIO_INSS
				END
			IF @salario_bruto BETWEEN @AUX AND @SALARIO_INSS
				BEGIN
					SET @inss = (@salario_bruto * @DESCONTO_INSS) / 100
					print CAST(@INSS AS VARCHAR(MAX)) + ' '  + CAST(@DESCONTO_INSS AS VARCHAR(MAX))
				END
			IF @salario_bruto > @MAX_SAL_INSS
				BEGIN
					SET @inss = (@salario_bruto - @DESCONTO_INSS)
					print CAST(@INSS AS VARCHAR(MAX)) + ' '  + CAST(@DESCONTO_INSS AS VARCHAR(MAX)) + ' '  + CAST(@MAX_SAL_INSS AS VARCHAR(MAX))
				END
			SET @AUX = @SALARIO_INSS
			FETCH NEXT FROM mcursor INTO @SALARIO_INSS, @DESCONTO_INSS
			
		END
		CLOSE mcursor
		DEALLOCATE mcursor
			
		-- IRRF	
		DECLARE @base_irrf	MONEY,		@irrf			MONEY, 
				@aux_irrf	MONEY,		@aliquota		MONEY, 
				@vl_deduzir MONEY,		@tx_dependente	MONEY, 
				@max_sal_irrf MONEY,	@valor_irrf		MONEY
		
		SET @aux_irrf = 1.0
		SET @max_sal_irrf = 0.0
		SET @base_irrf = @salario_bruto - @inss

		-- DECLARANDO O CURSOR
		DECLARE mcursor2 CURSOR FOR
		-- DEFININDO CONJUNTO DE DADOS
		SELECT SALARIO, ALIQUOTA, VL_DEDUZIR, DEPENDENTE FROM DSC_IRRF
		-- ABRINDO CURSOR
		OPEN mcursor2
		FETCH NEXT FROM mcursor2 INTO @irrf, @aliquota, @vl_deduzir, @tx_dependente
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @irrf > @max_sal_irrf
				BEGIN
					SET @max_sal_irrf = @irrf
				END
			IF @base_irrf BETWEEN @aux_irrf AND @irrf  
				BEGIN
					IF @dependentes >= 1
						BEGIN
							SET @base_irrf = @base_irrf - @tx_dependente * @dependentes
						END
					SET @valor_irrf = (@base_irrf * @aliquota / 100) - @vl_deduzir
					print CAST(@irrf AS VARCHAR(MAX)) + ' '  + CAST(@aliquota AS VARCHAR(MAX))
				END
			IF @base_irrf >= @aux_irrf AND (@irrf IS NULL)
				BEGIN
					IF @dependentes >= 1
						BEGIN
							SET @base_irrf = @base_irrf - @tx_dependente * @dependentes
						END
					SET @valor_irrf = (@base_irrf * @aliquota / 100) - @vl_deduzir
					print CAST(@irrf AS VARCHAR(MAX)) + ' '  + CAST(@aliquota AS VARCHAR(MAX))
				END
			SET @aux_irrf = @irrf
			FETCH NEXT FROM mcursor2 INTO @irrf, @aliquota, @vl_deduzir, @tx_dependente
		END
		CLOSE mcursor2
		DEALLOCATE mcursor2

		SET @salario_final_dsc -= @inss

		SET @VALOR_RETORNO = @salario_final_dsc
		SET @retorno_INSS = @inss
		SET @retorno_IRRF = @valor_irrf
		SET @retorno_plano_saude = (@salario_bruto * @dsc_plano_saude_func) / 100
		SET @retorno_vale_transp = (@salario_bruto * @dsc_transp) / 100
	END
GO

CREATE TABLE FOLHA_PAGAMENTO (
	MATRICULA VARCHAR(4) NOT NULL,
	CPF VARCHAR(15) NOT NULL,
	NOME VARCHAR(40) NOT NULL,
	ESCOLARIDADE CHAR(1) NOT NULL,
	CARGO INT,
	ADMISSAO DATE NOT NULL,
	DEPENDENTES INT,
	DATA_PAGAMENTO DATE NOT NULL,
	REPOUSO_REMUNERADO MONEY,
	GRATIFICACAO_ESCOLARIDADE MONEY,
	AUX_ALIMENTACAO MONEY,
	SALARIO_FAMILIA MONEY,
	ANUENIO MONEY,
	VALE_CULTURA MONEY,
	IRRF MONEY,
	INSS MONEY,
	VALE_TRANSP MONEY NOT NULL,
	PLANO_SAUDE MONEY NOT NULL,
	SALARIO_LIQUIDO	MONEY NOT NULL,
	PRIMARY KEY (MATRICULA)
);
GO


CREATE PROCEDURE SP_PRINCIPAL (@MATRICULA VARCHAR(10))
AS
BEGIN
	DECLARE @SALARIO_FINAL MONEY,
			@SALARIO_BRUTO MONEY,
			@matricula_loop VARCHAR(10),
			@retorno_salario_dsc MONEY,
			@retorno_IRRF MONEY,
			@retorno_INSS MONEY,
			@retorno_vale_transp MONEY,
			@retorno_plano_saude MONEY,
			@retorno_salario_provento MONEY,
			@retorno_repouso_rem MONEY,
			@retorno_grat_escolaridade MONEY,
			@retorno_anuenio MONEY,
			@retorno_sal_familia MONEY,
			@retorno_vale_cultura MONEY,
			@retorno_aux_alimentacao MONEY
	
	-- DECLARANDO O CURSOR
	DECLARE cursor_principal CURSOR FOR
	-- DEFININDO CONJUNTO DE DADOS
	SELECT matricula
	FROM FUNCIONARIOS

	-- ABRINDO CURSOR
	OPEN cursor_principal
	FETCH NEXT FROM cursor_principal INTO @matricula_loop
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC SP_CALC_PROVENTOS '1054', @retorno_salario_provento OUTPUT,
			@retorno_repouso_rem OUTPUT,
			@retorno_grat_escolaridade OUTPUT,
			@retorno_anuenio OUTPUT,
			@retorno_sal_familia OUTPUT,
			@retorno_vale_cultura OUTPUT,
			@retorno_aux_alimentacao OUTPUT

		EXEC SP_CALC_DESCONTOS @matricula_loop,
				@retorno_salario_dsc OUTPUT,
				@retorno_IRRF OUTPUT,
				@retorno_INSS OUTPUT,
				@retorno_vale_transp OUTPUT,
				@retorno_plano_saude OUTPUT

		set @SALARIO_FINAL = @retorno_salario_dsc + @retorno_salario_provento

		DECLARE @MATRICULA_FUNC VARCHAR(10), @CPF VARCHAR(11), @NOME VARCHAR(MAX), @ESCOLARIDADE CHAR(1), @CARGO VARCHAR(MAX),
		@ADMISSAO DATE, @DEPENDENTES INT
		SELECT @MATRICULA_FUNC = MATRICULA, @CPF = CPF, @NOME = NOME, @ESCOLARIDADE = ESCOLARIDADE, @CARGO = CARGO, 
		@ADMISSAO = ADMISSAO,  @DEPENDENTES = DEPENDENTES FROM FUNCIONARIOS WHERE FUNCIONARIOS.MATRICULA = @matricula_loop
	
		INSERT INTO FOLHA_PAGAMENTO VALUES 
		(	@MATRICULA_FUNC, @CPF, @NOME, @ESCOLARIDADE, @CARGO, @ADMISSAO, @DEPENDENTES,
			GETDATE(), @retorno_repouso_rem, @retorno_grat_escolaridade, @retorno_aux_alimentacao, 
			@retorno_sal_familia, @retorno_anuenio, @retorno_vale_cultura, @retorno_IRRF, @retorno_INSS,
			@retorno_vale_transp, @retorno_plano_saude, @SALARIO_FINAL

		)
		FETCH NEXT FROM cursor_principal INTO @matricula_loop
	END
	CLOSE cursor_principal
	DEALLOCATE cursor_principal
	SELECT @SALARIO_BRUTO = SALARIO FROM FUNCIONARIOS F, CARGOS C WHERE C.CARGO = F.CARGO AND F.MATRICULA = @MATRICULA
	DECLARE @DATA_HOJE DATE
	SELECT	@CPF = CPF, 
			@NOME = NOME,
			@ESCOLARIDADE = ESCOLARIDADE,
			@CARGO = CARGO,
			@ADMISSAO = ADMISSAO,
			@DATA_HOJE = DATA_PAGAMENTO,
			@retorno_repouso_rem = REPOUSO_REMUNERADO,
			@retorno_grat_escolaridade = GRATIFICACAO_ESCOLARIDADE,
			@retorno_aux_alimentacao = AUX_ALIMENTACAO,
			@retorno_sal_familia = SALARIO_FAMILIA,
			@retorno_anuenio = ANUENIO,
			@retorno_vale_cultura = VALE_CULTURA,
			@retorno_IRRF = IRRF,
			@retorno_INSS = INSS,
			@retorno_vale_transp = VALE_TRANSP,
			@retorno_plano_saude = PLANO_SAUDE,
			@SALARIO_FINAL = SALARIO_LIQUIDO
	FROM FOLHA_PAGAMENTO WHERE MATRICULA = @MATRICULA
	
	DECLARE @TEXTO VARCHAR(MAX)
	SET @TEXTO = '----------------------' + char(13)+ char(10) 
	SET @TEXTO = 'Governo do Estado do Pará ' + char(13)+ char(10) + '
	Secretaria Especial de Estado de Gestão ' + char(13)+ char(10) + '
	Secretaria de Estado de Administração ' + char(13)+ char(10) + '
	Sistema de Gestão Integrada de Recursos Humanos ' + char(13)+ char(10) + '
	' + char(13)+ char(10) + '
	' + char(13)+ char(10) + '
	---------------------------------------------------------------- ' + char(13)+ char(10) + '
	C O M P R O V A N T E D E P A G A M E N T O' + char(13)+ char(10) + '
	---------------------------------------------------------------- ' + char(13)+ char(10) + '
	ID Funcional                                      Mês/Ano' + char(13)+ char(10) + '
	'+ @MATRICULA + '                                    '+ cast(@DATA_HOJE as varchar(max)) + '  ' + char(13)+ char(10) + '
	Nome						CPF			 Cargo             ' + char(13)+ char(10) + '
	'+ @NOME + '           '+ cast(@CPF as varchar(max)) + '		 '+ cast(@cargo as varchar(max)) + '			' + char(13)+ char(10) + '
	' + char(13)+ char(10) + '
	ITEM    DISCRIMINAÇÃO       REFERÊNCIA       PROVENTO        DESCONTO
	1		Sal Bruto	           '+ cast(@SALARIO_BRUTO as varchar(max)) +'
	2		Repouso remunerado		'+ cast(@retorno_repouso_rem as varchar(max)) +'
	3		Escolaridade			'+ cast(@retorno_grat_escolaridade as varchar(max)) +'
	4		Aux. Alimentação		'+ cast(@retorno_aux_alimentacao as varchar(max)) +'
	5		Salário Família			'+ cast(@retorno_sal_familia as varchar(max)) +'
	6		Anuênio			        '+ cast(@retorno_anuenio as varchar(max)) +'
	7		Vale Cultura			'+ cast(@retorno_vale_cultura as varchar(max)) +'
	8		IRPF						 '+ cast(@retorno_IRRF as varchar(max)) +'
	9		Vale Transporte					'+ cast(@retorno_vale_transp as varchar(max)) +'
	10		INSS					       '+ cast(@retorno_INSS as varchar(max)) +'
	11		Plano de Saúde			               '+ cast(@retorno_plano_saude as varchar(max)) +'
	' + char(13)+ char(10) + '
	---------------------------------------------------------------- ' + char(13)+ char(10) + '
	---------------------------------------------------------------- ' + char(13)+ char(10) + '
	Salário Líquido' + char(13)+ char(10) + '           '+ cast(@SALARIO_FINAL as varchar(max))

	EXEC WriteToFile 'C:\LOG_DB_FRR\RELATORIO.txt', @TEXTO
END

exec SP_PRINCIPAL '1002'

DELETE FOLHA_PAGAMENTO
SELECT * FROM FOLHA_PAGAMENTO

