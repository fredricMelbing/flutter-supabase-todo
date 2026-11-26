-- Local development seed data. Runs after migrations on `supabase db reset`.
-- Never runs against cloud projects (db push skips it by default).
do $$
declare
  -- Must match _emailDomain in AuthService
  v_email_domain constant text := 'todo.local';
  v_seed record;
  v_email text;
  v_user_id uuid;
begin
  for v_seed in
    select * from (values
      ('admin', 'qwerty', true),
      ('kalle', 'qwerty', false),
      ('lisa',  'qwerty',  false)
    ) as t(username, password, is_admin)
  loop
    v_email := v_seed.username || '@' || v_email_domain;

    -- 1. Create the auth user; the generated id is captured with RETURNING
    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
      created_at, updated_at,
      -- These must be empty strings, not NULL, or sign-in fails
      confirmation_token, recovery_token, email_change, email_change_token_new
    ) values (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      v_email,
      extensions.crypt(v_seed.password, extensions.gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      now(), now(),
      '', '', '', ''
    )
    returning id into v_user_id;

    -- 2. Email identity – Supabase Auth needs this row to allow password sign-in
    insert into auth.identities (
      id, user_id, provider_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(),
      v_user_id,
      v_user_id::text,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      now(), now(), now()
    );

    -- 3. The on_auth_user_created trigger has created the profile – set admin flag
    update public.profiles
    set is_admin = v_seed.is_admin
    where id = v_user_id;
  end loop;
end;
$$;