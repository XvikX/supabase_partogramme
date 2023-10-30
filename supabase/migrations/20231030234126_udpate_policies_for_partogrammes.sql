drop policy "Enable access based on their ID" on "public"."Partogramme";

drop policy "Enable insert for users based on user_id" on "public"."Partogramme";

drop policy "read access" on "public"."Profile";

drop policy "Users can only fetch data from the same hospital" on "public"."Partogramme";

create policy "Allowed access to their data"
on "public"."Partogramme"
as permissive
for all
to authenticated
using ((auth.uid() = "nurseId"))
with check ((auth.uid() = "nurseId"));


create policy "allowed user to add data"
on "public"."Partogramme"
as permissive
for insert
to authenticated
with check (true);


create policy "Users can only fetch data from the same hospital"
on "public"."Partogramme"
as restrictive
for select
to authenticated
using (("hospitalId" IN ( SELECT "userInfo"."hospitalId"
   FROM "userInfo"
  WHERE (auth.uid() = "userInfo"."profileId"))));



