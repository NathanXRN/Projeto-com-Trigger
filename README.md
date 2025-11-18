# Projeto-com-Trigger

1. **Tabela Funcionario:**

    * Armazena os dados dos funcionários, incluindo ID, nome, salário e data de contratação.

2. **Tabela Funcionario_Auditoria:

    * Armazena o histórico de alterações dos salários dos funcionários, incluindo o salário antigo, o novo salário e a data de modificação.

```sql
-- Criação da Tabela Funcionario
CREATE TABLE Funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    salario DECIMAL(10, 2),
    dtcontratacao DATE
);

-- Criação da tabela Funcionario_Auditoria
CREATE TABLE Funcionario_Auditoria (
    id INT,
    salario_antigo DECIMAL(10, 2),
    novo_salario DECIMAL(10, 2),
    data_de_modificacao_do_salario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES Funcionario(id)
);

-- Inserção de dados na tabela Funcionario
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Maria', 5000.00, '2021-06-01');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('João', 4500.00, '2021-07-15');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Ana', 4000.00, '2022-01-10');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Pedro', 5500.00, '2022-03-20');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Lucas', 4700.00, '2022-05-25');

```

**Criação do Trigger**

O trigger será disparado assim que uma atualização no salário for realizada na tabela Funcionario. Registrará os detalhes da modificação na tabela Funcionario_Auditoria

```sql
-- Criação do Trigger para auditoria de alterações de salário.
CREATE OR REPLACE FUNCTION registrar_auditoria_salario() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Funcionario_Auditoria (id, salario_antigo, novo_salario)
    VALUES (OLD.id, OLD.salario, NEW.salario);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_salario_modificado
AFTER UPDATE OF salario ON Funcionario
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_salario();

-- Atualizar o salário 
UPDATE Funcionario SET salario = 10000.00 WHERE nome = 'Ana';
```

**Projeto ESTOQUE**

```sql
-- Criação da tabela Produto
CREATE TABLE Produto (
    cod_prod INT PRIMARY KEY,
    descricao VARCHAR(50) UNIQUE,
    qtde_disponivel INT NOT NULL DEFAULT 0
);

-- Criação da tabela RegistroVendas
CREATE TABLE RegistroVendas (
    cod_venda SERIAL PRIMARY KEY,
    cod_prod INT,
    qtde_vendida INT,
    FOREIGN KEY (cod_prod) REFERENCES Produto(cod_prod) ON DELETE CASCADE
);

-- Inserir produtos 
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
```