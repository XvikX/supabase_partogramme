create type "public"."LiquidState" as enum ('NONE', 'INTACT', 'CLAIR', 'MECONIAL', 'SANG', 'PUREE_DE_POIS');

create type "public"."PartogrammeState" as enum ('ADMITTED', 'IN_PROGRESS', 'TRANSFERRED', 'WORK_FINISHED');

create type "public"."Role" as enum ('NURSE', 'DOCTOR');

create table "public"."BabyDescent" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."BabyHeartFrequency" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."Comment" (
    "id" uuid not null,
    "value" text not null,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean not null default false,
    "partogrammeId" uuid not null
);


create table "public"."Dilation" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherContractionDuration" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean not null default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherContractionsFrequency" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherDiastolicBloodPressure" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherHeartFrequency" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherSystolicBloodPressure" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."MotherTemperature" (
    "id" uuid not null,
    "value" double precision not null default 0,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."Partogramme" (
    "id" uuid not null,
    "noFile" bigint not null,
    "patientLastName" text,
    "patientFirstName" text,
    "admissionDateTime" timestamp(6) with time zone not null,
    "workStartDateTime" timestamp(6) with time zone,
    "commentary" text not null,
    "state" "PartogrammeState" not null default 'ADMITTED'::"PartogrammeState",
    "isDeleted" boolean default false,
    "nurseId" uuid not null,
    "hospitalId" uuid not null,
    "refDoctorId" uuid not null
);


alter table "public"."Partogramme" enable row level security;

create table "public"."Profile" (
    "id" uuid not null,
    "email" text,
    "isDeleted" boolean default false
);


alter table "public"."Profile" enable row level security;

create table "public"."_prisma_migrations" (
    "id" character varying(36) not null,
    "checksum" character varying(64) not null,
    "finished_at" timestamp with time zone,
    "migration_name" character varying(255) not null,
    "logs" text,
    "rolled_back_at" timestamp with time zone,
    "started_at" timestamp with time zone not null default now(),
    "applied_steps_count" integer not null default 0
);


create table "public"."amnioticLiquid" (
    "id" uuid not null,
    "value" "LiquidState" not null default 'INTACT'::"LiquidState",
    "Rank" numeric,
    "created_at" timestamp(6) with time zone not null,
    "isDeleted" boolean default false,
    "partogrammeId" uuid not null
);


create table "public"."hospital" (
    "id" uuid not null,
    "name" text not null,
    "isDeleted" boolean default false,
    "city" text not null
);


create table "public"."userInfo" (
    "id" uuid not null,
    "lastName" text not null,
    "firstName" text not null,
    "role" "Role" not null default 'NURSE'::"Role",
    "isDeleted" boolean default false,
    "profileId" uuid not null,
    "hospitalId" uuid not null,
    "refDoctorId" uuid not null
);


CREATE UNIQUE INDEX "BabyDescent_pkey" ON public."BabyDescent" USING btree (id);

CREATE UNIQUE INDEX "BabyHeartFrequency_pkey" ON public."BabyHeartFrequency" USING btree (id);

CREATE UNIQUE INDEX "Comment_pkey" ON public."Comment" USING btree (id);

CREATE UNIQUE INDEX "Dilation_pkey" ON public."Dilation" USING btree (id);

CREATE UNIQUE INDEX "MotherContractionDuration_pkey" ON public."MotherContractionDuration" USING btree (id);

CREATE UNIQUE INDEX "MotherContractionsFrequency_pkey" ON public."MotherContractionsFrequency" USING btree (id);

CREATE UNIQUE INDEX "MotherDiastolicBloodPressure_pkey" ON public."MotherDiastolicBloodPressure" USING btree (id);

CREATE UNIQUE INDEX "MotherHeartFrequency_pkey" ON public."MotherHeartFrequency" USING btree (id);

CREATE UNIQUE INDEX "MotherSystolicBloodPressure_pkey" ON public."MotherSystolicBloodPressure" USING btree (id);

CREATE UNIQUE INDEX "MotherTemperature_pkey" ON public."MotherTemperature" USING btree (id);

CREATE UNIQUE INDEX "Partogramme_pkey" ON public."Partogramme" USING btree (id);

CREATE UNIQUE INDEX "Profile_pkey" ON public."Profile" USING btree (id);

CREATE UNIQUE INDEX _prisma_migrations_pkey ON public._prisma_migrations USING btree (id);

CREATE UNIQUE INDEX "amnioticLiquid_pkey" ON public."amnioticLiquid" USING btree (id);

CREATE UNIQUE INDEX hospital_pkey ON public.hospital USING btree (id);

CREATE UNIQUE INDEX "userInfo_pkey" ON public."userInfo" USING btree (id);

alter table "public"."BabyDescent" add constraint "BabyDescent_pkey" PRIMARY KEY using index "BabyDescent_pkey";

alter table "public"."BabyHeartFrequency" add constraint "BabyHeartFrequency_pkey" PRIMARY KEY using index "BabyHeartFrequency_pkey";

alter table "public"."Comment" add constraint "Comment_pkey" PRIMARY KEY using index "Comment_pkey";

alter table "public"."Dilation" add constraint "Dilation_pkey" PRIMARY KEY using index "Dilation_pkey";

alter table "public"."MotherContractionDuration" add constraint "MotherContractionDuration_pkey" PRIMARY KEY using index "MotherContractionDuration_pkey";

alter table "public"."MotherContractionsFrequency" add constraint "MotherContractionsFrequency_pkey" PRIMARY KEY using index "MotherContractionsFrequency_pkey";

alter table "public"."MotherDiastolicBloodPressure" add constraint "MotherDiastolicBloodPressure_pkey" PRIMARY KEY using index "MotherDiastolicBloodPressure_pkey";

alter table "public"."MotherHeartFrequency" add constraint "MotherHeartFrequency_pkey" PRIMARY KEY using index "MotherHeartFrequency_pkey";

alter table "public"."MotherSystolicBloodPressure" add constraint "MotherSystolicBloodPressure_pkey" PRIMARY KEY using index "MotherSystolicBloodPressure_pkey";

alter table "public"."MotherTemperature" add constraint "MotherTemperature_pkey" PRIMARY KEY using index "MotherTemperature_pkey";

alter table "public"."Partogramme" add constraint "Partogramme_pkey" PRIMARY KEY using index "Partogramme_pkey";

alter table "public"."Profile" add constraint "Profile_pkey" PRIMARY KEY using index "Profile_pkey";

alter table "public"."_prisma_migrations" add constraint "_prisma_migrations_pkey" PRIMARY KEY using index "_prisma_migrations_pkey";

alter table "public"."amnioticLiquid" add constraint "amnioticLiquid_pkey" PRIMARY KEY using index "amnioticLiquid_pkey";

alter table "public"."hospital" add constraint "hospital_pkey" PRIMARY KEY using index "hospital_pkey";

alter table "public"."userInfo" add constraint "userInfo_pkey" PRIMARY KEY using index "userInfo_pkey";

alter table "public"."BabyDescent" add constraint "BabyDescent_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."BabyDescent" validate constraint "BabyDescent_partogrammeId_fkey";

alter table "public"."BabyHeartFrequency" add constraint "BabyHeartFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."BabyHeartFrequency" validate constraint "BabyHeartFrequency_partogrammeId_fkey";

alter table "public"."Comment" add constraint "Comment_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."Comment" validate constraint "Comment_partogrammeId_fkey";

alter table "public"."Dilation" add constraint "Dilation_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."Dilation" validate constraint "Dilation_partogrammeId_fkey";

alter table "public"."MotherContractionDuration" add constraint "MotherContractionDuration_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherContractionDuration" validate constraint "MotherContractionDuration_partogrammeId_fkey";

alter table "public"."MotherContractionsFrequency" add constraint "MotherContractionsFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherContractionsFrequency" validate constraint "MotherContractionsFrequency_partogrammeId_fkey";

alter table "public"."MotherDiastolicBloodPressure" add constraint "MotherDiastolicBloodPressure_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherDiastolicBloodPressure" validate constraint "MotherDiastolicBloodPressure_partogrammeId_fkey";

alter table "public"."MotherHeartFrequency" add constraint "MotherHeartFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherHeartFrequency" validate constraint "MotherHeartFrequency_partogrammeId_fkey";

alter table "public"."MotherSystolicBloodPressure" add constraint "MotherSystolicBloodPressure_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherSystolicBloodPressure" validate constraint "MotherSystolicBloodPressure_partogrammeId_fkey";

alter table "public"."MotherTemperature" add constraint "MotherTemperature_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."MotherTemperature" validate constraint "MotherTemperature_partogrammeId_fkey";

alter table "public"."Partogramme" add constraint "Partogramme_hospitalId_fkey" FOREIGN KEY ("hospitalId") REFERENCES hospital(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."Partogramme" validate constraint "Partogramme_hospitalId_fkey";

alter table "public"."Partogramme" add constraint "Partogramme_nurseId_fkey" FOREIGN KEY ("nurseId") REFERENCES "Profile"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."Partogramme" validate constraint "Partogramme_nurseId_fkey";

alter table "public"."amnioticLiquid" add constraint "amnioticLiquid_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "Partogramme"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."amnioticLiquid" validate constraint "amnioticLiquid_partogrammeId_fkey";

alter table "public"."userInfo" add constraint "userInfo_hospitalId_fkey" FOREIGN KEY ("hospitalId") REFERENCES hospital(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."userInfo" validate constraint "userInfo_hospitalId_fkey";

alter table "public"."userInfo" add constraint "userInfo_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "Profile"(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."userInfo" validate constraint "userInfo_profileId_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_claim(uid uuid, claim text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data - claim where id = uid;
        return 'OK';
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claim(uid uuid, claim text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select coalesce(raw_app_meta_data->claim, null) from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claims(uid uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select raw_app_meta_data from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_every_doctor()
 RETURNS SETOF "Profile"
 LANGUAGE plpgsql
AS $function$
begin
  return query SELECT * FROM public."Profile" where get_claim(id, 'userrole') = '"doctor"';
end;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claim(claim text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claims()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata', '{}'::jsonb)::jsonb
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public."Profile" (id, email)
  values (new.id, new.email);
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_claims_admin()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
  BEGIN
    IF session_user = 'authenticator' THEN
      --------------------------------------------
      -- To disallow any authenticated app users
      -- from editing claims, delete the following
      -- block of code and replace it with:
      -- RETURN FALSE;
      --------------------------------------------
      IF extract(epoch from now()) > coalesce((current_setting('request.jwt.claims', true)::jsonb)->>'exp', '0')::numeric THEN
        return false; -- jwt expired
      END IF;
      If current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role' THEN
        RETURN true; -- service role users have admin rights
      END IF;
      IF coalesce((current_setting('request.jwt.claims', true)::jsonb)->'app_metadata'->'claims_admin', 'false')::bool THEN
        return true; -- user has claims_admin set to true
      ELSE
        return false; -- user does NOT have claims_admin set to true
      END IF;
      --------------------------------------------
      -- End of block 
      --------------------------------------------
    ELSE -- not a user session, probably being called from a trigger or something
      return true;
    END IF;
  END;
$function$
;

CREATE OR REPLACE FUNCTION public.restrict_role_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN
  IF NEW.role <> OLD.role THEN
    RAISE EXCEPTION 'changing "role" is not allowed';
  END IF;

  RETURN NEW;
END;$function$
;

CREATE OR REPLACE FUNCTION public.set_claim(uid uuid, claim text, value jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data || 
            json_build_object(claim, value)::jsonb where id = uid;
        return 'OK';
      END IF;
    END;
$function$
;

create policy "Enable insert for users based on user_id"
on "public"."Partogramme"
as permissive
for all
to public
using ((auth.uid() = "nurseId"))
with check ((auth.uid() = "nurseId"));


create policy "Users can only fetch data from the same hospital"
on "public"."Partogramme"
as permissive
for all
to public
using (("hospitalId" IN ( SELECT "userInfo"."hospitalId"
   FROM "userInfo"
  WHERE (auth.uid() = "userInfo"."profileId"))));


create policy "allowed acess to every data to doctor"
on "public"."Partogramme"
as permissive
for select
to public
using ((get_my_claim('userrole'::text) = '"doctor"'::jsonb));


create policy "allowed_authentificated_user"
on "public"."Partogramme"
as permissive
for all
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."Profile"
as permissive
for select
to authenticated
using (true);


create policy "read access"
on "public"."Profile"
as permissive
for select
to authenticated
using (true);


CREATE TRIGGER on_update_user_info BEFORE UPDATE ON public."userInfo" FOR EACH ROW EXECUTE FUNCTION restrict_role_update();


