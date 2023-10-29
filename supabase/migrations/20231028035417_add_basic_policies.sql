drop policy "allowed_authentificated_user" on "public"."Partogramme";

alter table "public"."Partogramme" alter column "hospitalId" set not null;

alter table "public"."Partogramme" alter column "refDoctorId" set not null;

alter table "public"."Partogramme" enable row level security;

alter table "public"."userInfo" alter column "hospitalId" set not null;

alter table "public"."Partogramme" add constraint "Partogramme_hospitalId_fkey" FOREIGN KEY ("hospitalId") REFERENCES hospital(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."Partogramme" validate constraint "Partogramme_hospitalId_fkey";

alter table "public"."userInfo" add constraint "userInfo_hospitalId_fkey" FOREIGN KEY ("hospitalId") REFERENCES hospital(id) ON UPDATE CASCADE ON DELETE RESTRICT not valid;

alter table "public"."userInfo" validate constraint "userInfo_hospitalId_fkey";

set check_function_bodies = off;

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

create policy "Enable insert for users based on user_id"
on "public"."Partogramme"
as permissive
for all
to public
using ((auth.uid() = "nurseId"))
with check ((auth.uid() = "nurseId"));


create policy "allowed acess to every data to doctor"
on "public"."Partogramme"
as permissive
for select
to public
using ((get_my_claim('userrole'::text) = '"doctor"'::jsonb));



