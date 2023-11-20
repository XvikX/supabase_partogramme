import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import { corsHeaders } from "../_shared/cors.ts";

console.log(`Function "get-user" up and running!`);

Deno.serve(async (req: Request) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
      /* { global: { headers: { Authorization: req.headers.get('Authorization')! } } } */
    );
    const { userId, hospitalId, email } = await req.json();
    console.log("userId : " + userId);
    console.log("hospitalId : " + hospitalId);
    console.log("email : " + email);

    const { data, error } = await supabaseClient.rpc("get_claim", {
      uid: userId,
      claim: "userrole",
    });
    if (error) throw error;
    console.log(data);
    if (data === "ADMIN") {
      const options = {
        data: {
          hospitalId: hospitalId,
        },
      };
      const { data, error } = await supabaseClient.auth.admin.inviteUserByEmail(
        email,
        options
      );
      console.log("Error :" + JSON.stringify(error));
      console.log("User data :" + JSON.stringify(data));
    }

    return new Response(JSON.stringify({ data }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
