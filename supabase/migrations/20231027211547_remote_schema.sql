
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

ALTER SCHEMA "public" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE TYPE "public"."LiquidState" AS ENUM (
    'NONE',
    'INTACT',
    'CLAIR',
    'MECONIAL',
    'SANG',
    'PUREE_DE_POIS'
);

ALTER TYPE "public"."LiquidState" OWNER TO "postgres";

CREATE TYPE "public"."PartogrammeState" AS ENUM (
    'ADMITTED',
    'IN_PROGRESS',
    'TRANSFERRED',
    'WORK_FINISHED'
);

ALTER TYPE "public"."PartogrammeState" OWNER TO "postgres";

CREATE TYPE "public"."Role" AS ENUM (
    'NURSE',
    'DOCTOR'
);

ALTER TYPE "public"."Role" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data - claim where id = uid;
        return 'OK';
      END IF;
    END;
$$;

ALTER FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select coalesce(raw_app_meta_data->claim, null) from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$$;

ALTER FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_claims"("uid" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select raw_app_meta_data from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$$;

ALTER FUNCTION "public"."get_claims"("uid" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."Profile" (
    "id" "uuid" NOT NULL,
    "email" "text",
    "isDeleted" boolean DEFAULT false
);

ALTER TABLE "public"."Profile" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_every_doctor"() RETURNS SETOF "public"."Profile"
    LANGUAGE "plpgsql"
    AS $$
begin
  return query SELECT * FROM public."Profile" where get_claim(id, 'userrole') = '"doctor"';
end;
$$;

ALTER FUNCTION "public"."get_every_doctor"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_my_claim"("claim" "text") RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)
$$;

ALTER FUNCTION "public"."get_my_claim"("claim" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_my_claims"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata', '{}'::jsonb)::jsonb
$$;

ALTER FUNCTION "public"."get_my_claims"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public."Profile" (id)
  values (new.id);
  return new;
end;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."is_claims_admin"() RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."is_claims_admin"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."restrict_role_update"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
  IF NEW.role <> OLD.role THEN
    RAISE EXCEPTION 'changing "role" is not allowed';
  END IF;

  RETURN NEW;
END;$$;

ALTER FUNCTION "public"."restrict_role_update"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
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
$$;

ALTER FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."BabyDescent" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."BabyDescent" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."BabyHeartFrequency" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."BabyHeartFrequency" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Comment" (
    "id" "uuid" NOT NULL,
    "value" "text" NOT NULL,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."Comment" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Dilation" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."Dilation" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherContractionDuration" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherContractionDuration" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherContractionsFrequency" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherContractionsFrequency" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherDiastolicBloodPressure" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherDiastolicBloodPressure" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherHeartFrequency" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherHeartFrequency" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherSystolicBloodPressure" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherSystolicBloodPressure" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."MotherTemperature" (
    "id" "uuid" NOT NULL,
    "value" double precision DEFAULT 0 NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."MotherTemperature" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Partogramme" (
    "id" "uuid" NOT NULL,
    "noFile" bigint NOT NULL,
    "patientLastName" "text",
    "patientFirstName" "text",
    "admissionDateTime" timestamp(6) with time zone NOT NULL,
    "workStartDateTime" timestamp(6) with time zone,
    "commentary" "text" NOT NULL,
    "state" "public"."PartogrammeState" DEFAULT 'ADMITTED'::"public"."PartogrammeState" NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "nurseId" "uuid" NOT NULL,
    "hospitalId" "uuid",
    "refDoctorId" "uuid"
);

ALTER TABLE "public"."Partogramme" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."_prisma_migrations" (
    "id" character varying(36) NOT NULL,
    "checksum" character varying(64) NOT NULL,
    "finished_at" timestamp with time zone,
    "migration_name" character varying(255) NOT NULL,
    "logs" "text",
    "rolled_back_at" timestamp with time zone,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "applied_steps_count" integer DEFAULT 0 NOT NULL
);

ALTER TABLE "public"."_prisma_migrations" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."amnioticLiquid" (
    "id" "uuid" NOT NULL,
    "value" "public"."LiquidState" DEFAULT 'INTACT'::"public"."LiquidState" NOT NULL,
    "Rank" numeric,
    "created_at" timestamp(6) with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "partogrammeId" "uuid" NOT NULL
);

ALTER TABLE "public"."amnioticLiquid" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."hospital" (
    "id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "city" "text" NOT NULL
);

ALTER TABLE "public"."hospital" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."userInfo" (
    "id" "uuid" NOT NULL,
    "lastName" "text" NOT NULL,
    "firstName" "text" NOT NULL,
    "role" "public"."Role" DEFAULT 'NURSE'::"public"."Role" NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "profileId" "uuid" NOT NULL,
    "hospitalId" "uuid",
    "refDoctorId" "uuid" NOT NULL
);

ALTER TABLE "public"."userInfo" OWNER TO "postgres";

ALTER TABLE ONLY "public"."BabyDescent"
    ADD CONSTRAINT "BabyDescent_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."BabyHeartFrequency"
    ADD CONSTRAINT "BabyHeartFrequency_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Comment"
    ADD CONSTRAINT "Comment_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Dilation"
    ADD CONSTRAINT "Dilation_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherContractionDuration"
    ADD CONSTRAINT "MotherContractionDuration_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherContractionsFrequency"
    ADD CONSTRAINT "MotherContractionsFrequency_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherDiastolicBloodPressure"
    ADD CONSTRAINT "MotherDiastolicBloodPressure_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherHeartFrequency"
    ADD CONSTRAINT "MotherHeartFrequency_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherSystolicBloodPressure"
    ADD CONSTRAINT "MotherSystolicBloodPressure_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MotherTemperature"
    ADD CONSTRAINT "MotherTemperature_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Partogramme"
    ADD CONSTRAINT "Partogramme_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Profile"
    ADD CONSTRAINT "Profile_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."_prisma_migrations"
    ADD CONSTRAINT "_prisma_migrations_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."amnioticLiquid"
    ADD CONSTRAINT "amnioticLiquid_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."hospital"
    ADD CONSTRAINT "hospital_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."userInfo"
    ADD CONSTRAINT "userInfo_pkey" PRIMARY KEY ("id");

CREATE OR REPLACE TRIGGER "on_update_user_info" BEFORE UPDATE ON "public"."userInfo" FOR EACH ROW EXECUTE FUNCTION "public"."restrict_role_update"();

ALTER TABLE ONLY "public"."BabyDescent"
    ADD CONSTRAINT "BabyDescent_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."BabyHeartFrequency"
    ADD CONSTRAINT "BabyHeartFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."Comment"
    ADD CONSTRAINT "Comment_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."Dilation"
    ADD CONSTRAINT "Dilation_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherContractionDuration"
    ADD CONSTRAINT "MotherContractionDuration_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherContractionsFrequency"
    ADD CONSTRAINT "MotherContractionsFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherDiastolicBloodPressure"
    ADD CONSTRAINT "MotherDiastolicBloodPressure_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherHeartFrequency"
    ADD CONSTRAINT "MotherHeartFrequency_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherSystolicBloodPressure"
    ADD CONSTRAINT "MotherSystolicBloodPressure_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."MotherTemperature"
    ADD CONSTRAINT "MotherTemperature_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."Partogramme"
    ADD CONSTRAINT "Partogramme_nurseId_fkey" FOREIGN KEY ("nurseId") REFERENCES "public"."Profile"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."amnioticLiquid"
    ADD CONSTRAINT "amnioticLiquid_partogrammeId_fkey" FOREIGN KEY ("partogrammeId") REFERENCES "public"."Partogramme"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY "public"."userInfo"
    ADD CONSTRAINT "userInfo_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "public"."Profile"("id") ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE POLICY "Enable read access for all users" ON "public"."Profile" FOR SELECT TO "authenticated" USING (true);

ALTER TABLE "public"."Profile" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allowed_authentificated_user" ON "public"."Partogramme" TO "authenticated" WITH CHECK (true);

CREATE POLICY "read access" ON "public"."Profile" FOR SELECT TO "authenticated" USING (true);

REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."Profile" TO "anon";
GRANT ALL ON TABLE "public"."Profile" TO "authenticated";
GRANT ALL ON TABLE "public"."Profile" TO "service_role";

GRANT ALL ON FUNCTION "public"."get_every_doctor"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_every_doctor"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_every_doctor"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "service_role";

GRANT ALL ON FUNCTION "public"."restrict_role_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."restrict_role_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."restrict_role_update"() TO "service_role";

GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "service_role";

GRANT ALL ON TABLE "public"."BabyDescent" TO "anon";
GRANT ALL ON TABLE "public"."BabyDescent" TO "authenticated";
GRANT ALL ON TABLE "public"."BabyDescent" TO "service_role";

GRANT ALL ON TABLE "public"."BabyHeartFrequency" TO "anon";
GRANT ALL ON TABLE "public"."BabyHeartFrequency" TO "authenticated";
GRANT ALL ON TABLE "public"."BabyHeartFrequency" TO "service_role";

GRANT ALL ON TABLE "public"."Comment" TO "anon";
GRANT ALL ON TABLE "public"."Comment" TO "authenticated";
GRANT ALL ON TABLE "public"."Comment" TO "service_role";

GRANT ALL ON TABLE "public"."Dilation" TO "anon";
GRANT ALL ON TABLE "public"."Dilation" TO "authenticated";
GRANT ALL ON TABLE "public"."Dilation" TO "service_role";

GRANT ALL ON TABLE "public"."MotherContractionDuration" TO "anon";
GRANT ALL ON TABLE "public"."MotherContractionDuration" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherContractionDuration" TO "service_role";

GRANT ALL ON TABLE "public"."MotherContractionsFrequency" TO "anon";
GRANT ALL ON TABLE "public"."MotherContractionsFrequency" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherContractionsFrequency" TO "service_role";

GRANT ALL ON TABLE "public"."MotherDiastolicBloodPressure" TO "anon";
GRANT ALL ON TABLE "public"."MotherDiastolicBloodPressure" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherDiastolicBloodPressure" TO "service_role";

GRANT ALL ON TABLE "public"."MotherHeartFrequency" TO "anon";
GRANT ALL ON TABLE "public"."MotherHeartFrequency" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherHeartFrequency" TO "service_role";

GRANT ALL ON TABLE "public"."MotherSystolicBloodPressure" TO "anon";
GRANT ALL ON TABLE "public"."MotherSystolicBloodPressure" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherSystolicBloodPressure" TO "service_role";

GRANT ALL ON TABLE "public"."MotherTemperature" TO "anon";
GRANT ALL ON TABLE "public"."MotherTemperature" TO "authenticated";
GRANT ALL ON TABLE "public"."MotherTemperature" TO "service_role";

GRANT ALL ON TABLE "public"."Partogramme" TO "anon";
GRANT ALL ON TABLE "public"."Partogramme" TO "authenticated";
GRANT ALL ON TABLE "public"."Partogramme" TO "service_role";

GRANT ALL ON TABLE "public"."_prisma_migrations" TO "anon";
GRANT ALL ON TABLE "public"."_prisma_migrations" TO "authenticated";
GRANT ALL ON TABLE "public"."_prisma_migrations" TO "service_role";

GRANT ALL ON TABLE "public"."amnioticLiquid" TO "anon";
GRANT ALL ON TABLE "public"."amnioticLiquid" TO "authenticated";
GRANT ALL ON TABLE "public"."amnioticLiquid" TO "service_role";

GRANT ALL ON TABLE "public"."hospital" TO "anon";
GRANT ALL ON TABLE "public"."hospital" TO "authenticated";
GRANT ALL ON TABLE "public"."hospital" TO "service_role";

GRANT ALL ON TABLE "public"."userInfo" TO "anon";
GRANT ALL ON TABLE "public"."userInfo" TO "authenticated";
GRANT ALL ON TABLE "public"."userInfo" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
