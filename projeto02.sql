-- Criação da Tabela Produto 
CREATE TABLE Produto (
    cod_prod INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE,
    qtde_disponivel INT NOT NULL DEFAULT 0
);

-- Criação da Tabela RegistoVendas
CREATE TABLE RegistroVendas (
    cod_venda SERIAL PRIMARY KEY,
    cod_prod INT,
    qtde_vendida INT,
    FOREIGN KEY (cod_prod) REFERENCES Produto(cod_prod) ON DELETE CASCADE
);

-- Inserção de Produtos 
INSERT INTO Produto VALUES (1, 'Basica', 10);
INSERT INTO Produto VALUES (2, 'Dados', 5);
INSERT INTO Produto VALUES (3, 'Verao', 15);

-- Criação do Trigger 
CREATE OR REPLACE FUNCTION func_verifica_estoque()
RETURNS TRIGGER AS $$ 
DECLARE 
	qtde_atual INTEGER;
BEGIN
	SELECT qtd_disponivel  INTO qtde_atual
	FROM Produto WHERE cod_prod = NEW.cod_prod;
	IF qtde_atual < NEW.qtde_vendida THEN 
		RAISE EXCEPTION 'Quantidade indisponivel em estoque';
	ELSE
		UPDATE Produto SET qtd_disponivel = qtd_disponivel - NEW.qtde_vendida 
		WHERE cod_prod = NEW.cod_prod;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verifica_estoque
BEFORE INSERT ON registrovendas
FOR EACH ROW 
EXECUTE FUNCTION func_verifica_estoque();

-- Venda de 5 unidades de Basico 
INSERT INTO RegistroVendas (cod_prod, qtde_vendida) VALUES (1, 5);