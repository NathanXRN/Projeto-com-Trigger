-- Crição da Tabela Funcionario 
CREATE TABLE Funcionario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    salario DECIMAL(10, 2),
    dtcontratacao DATE
);

-- Criação da Tabela Funcionario_Auditoria
CREATE TABLE Funcionario_Auditoria (
    id INT,
    salario_antigo DECIMAL(10, 2),
    novo_salario DECIMAL(10, 2),
    data_de_modificacao_do_salario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id) REFERENCES Funcionario(id)
);

-- Inserção de dados na Tabela Funcionario 
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Maria', 5000.00, '2021-06-01');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('João', 4500.00, '2021-07-15');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Ana', 4000.00, '2022-01-10');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Pedro', 5500.00, '2022-03-20');
INSERT INTO Funcionario (nome, salario, dtcontratacao) VALUES ('Lucas', 4700.00, '2022-05-25');

-- Criação do Trigger 
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

-- Realizando a atualizção no salário para acionar o trigger
UPDATE Funcionario SET salario = 10000.00 WHERE nome = 'Ana';