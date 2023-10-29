create policy "Enable access based on their ID"
on "public"."Partogramme"
as permissive
for all
to authenticated
using ((auth.uid() = "nurseId"))
with check ((auth.uid() = "nurseId"));



