WITH credentials(mail, pass, uuid) AS (
  -- PUT YOUR EMAILS AND PASSWORDS HERE.
  SELECT * FROM (VALUES 
                        ('doc@email.io', 'doc', '108f618b-5a0b-4f9f-ac40-3642cb0e7fbb'), 
                        ('nurse1@email.io', 'nurse1', 'f0319ed1-5f6a-4461-90c3-ae78a7a4a14a'),
                        ('nurse2@email.io', 'nurse2', 'e64f4caa-e8b3-4f6a-a2ab-b731d7ce91fc')
                        ) AS users
),
create_user AS (
  INSERT INTO auth.users (id, instance_id, ROLE, aud, email, raw_app_meta_data, raw_user_meta_data, is_super_admin, encrypted_password, created_at, updated_at, last_sign_in_at, email_confirmed_at, confirmation_sent_at, confirmation_token, recovery_token, email_change_token_new, email_change)
    SELECT CAST(uuid as uuid), '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', mail, '{"provider":"email","providers":["email"]}', '{}', FALSE, crypt(pass, gen_salt('bf')), NOW(), NOW(), NOW(), NOW(), NOW(), '', '', '', '' FROM credentials
  RETURNING id
)
INSERT INTO auth.identities (id, provider, user_id, identity_data, last_sign_in_at, created_at, updated_at)
  SELECT id, 'email', id, json_build_object('sub', id), NOW(), NOW(), NOW() FROM create_user;

-- set user roles
SELECT set_claim('108f618b-5a0b-4f9f-ac40-3642cb0e7fbb', 'userrole', '"doctor"');

INSERT INTO public.hospital (id, name, "isDeleted", city)
  SELECT gen_random_uuid (), 'CHUM', 'false', 'Montréal';

INSERT INTO public.hospital (id, name, "isDeleted", city)
  SELECT gen_random_uuid (), 'Hôpital Saint-Anne', 'false', 'Montréal';

grant usage on schema public to postgres, anon, authenticated, service_role;

grant all privileges on all tables in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all functions in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all sequences in schema public to postgres, anon, authenticated, service_role;

alter default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;
