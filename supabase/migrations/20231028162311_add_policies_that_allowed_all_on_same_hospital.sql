alter table "public"."Partogramme" disable row level security;

create policy "Users can only fetch data from the same hospital"
on "public"."Partogramme"
as permissive
for all
to public
using (("hospitalId" IN ( SELECT "userInfo"."hospitalId"
   FROM "userInfo"
  WHERE (auth.uid() = "userInfo"."profileId"))));



