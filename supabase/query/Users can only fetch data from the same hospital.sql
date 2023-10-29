create policy "Users can only fetch data from the same hospital"
  on public."Partogramme"
  for update using (
    "hospitalId" in (
      select "hospitalId" from public."userInfo"
      where auth.uid() = "profileId"
    )
  );