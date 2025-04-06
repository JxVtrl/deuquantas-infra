-- Script para criar dados de teste
DO $$
DECLARE
    i INTEGER;
    usuario_id UUID;
    senha_hash TEXT := '$2b$10$xVh3M0mgLVnNWYFqWghEu.vEo6QC.2r4pUAZOYAWy8WYqrbDe1uOi'; -- hash da senha 'Teste@123'
BEGIN
    -- Criar 10 clientes
    FOR i IN 1..10 LOOP
        -- Inserir usuário
        INSERT INTO usuarios (id, email, password, name, "is_admin", "is_ativo", "data_criacao", "data_atualizacao")
        VALUES (
            gen_random_uuid(),
            'cliente' || i || '@teste.com',
            senha_hash,
            'Cliente Teste ' || i,
            false,
            true,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        ) RETURNING id INTO usuario_id;

        -- Inserir cliente
        INSERT INTO clientes (
            "id", "num_cpf", "num_celular", "data_nascimento", "endereco", "numero",
            "complemento", "bairro", "cidade", "estado", "cep", "is_ativo","usuario_id"
        ) VALUES (
            gen_random_uuid(),
            LPAD(i::text, 11, '0'),
            '1199999999' || i,
            '1990-01-01',
            'Rua Teste ' || i,
            i::text,
            'Apto ' || i,
            'Centro',
            'São Paulo',
            'SP',
            '01234567',
            true,
            usuario_id
        );
    END LOOP;

    -- Criar 10 estabelecimentos
    FOR i IN 1..10 LOOP
        -- Inserir usuário
        INSERT INTO usuarios (id, email, password, name, "is_admin", "is_ativo", "data_criacao", "data_atualizacao")
        VALUES (
            gen_random_uuid(),
            'estabelecimento' || i || '@teste.com',
            senha_hash,
            'Estabelecimento Teste ' || i,
            false,
            true,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        ) RETURNING id INTO usuario_id;

        -- Inserir estabelecimento
        INSERT INTO estabelecimentos (
            "num_cnpj", "email", "num_celular", "nome_estab", "razao_social",
            "endereco", "numero", "complemento", "bairro", "cidade", "estado", "cep",
            "is_ativo", "data_criacao", "data_atualizacao", "usuario_id"
        ) VALUES (
            LPAD(i::text, 14, '0'),
            'estabelecimento' || i || '@teste.com',
            '1199999999' || i,
            'Estabelecimento Teste ' || i,
            'Razão Social Teste ' || i,
            'Rua Teste ' || i,
            i::text,
            'Sala ' || i,
            'Centro',
            'São Paulo',
            'SP',
            '01234567',
            true,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            usuario_id
        );
    END LOOP;
END $$; 