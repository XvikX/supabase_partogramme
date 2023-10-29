-- POLICY: Users can only fetch data from the same hospital

-- DROP POLICY IF EXISTS "Users can only fetch data from the same hospital" ON public."Partogramme";

CREATE POLICY "Users can only fetch data from the same hospital"
    ON public."Partogramme"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (("hospitalId" IN ( SELECT "hospitalId"
   FROM public."userInfo"
  WHERE (auth.uid() = "profileId"))));