SELECT * FROM public."Partogramme" where (
	("hospitalId" IN ( SELECT "hospitalId"
   FROM public."userInfo"
   WHERE ("profileId" = (Select id FROM public."Profile"))))
)
