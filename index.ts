import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req: Request) => {

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  // Get the session or user object
  const { data } = await supabaseClient.auth.getUser()
  const user = data.user
    console.log("User : "+ JSON.stringify(user))
  return new Response(JSON.stringify({ user }), {
    headers: { 'Content-Type': 'application/json' },
    status: 200,
  })
    // const supabaseClient = createClient(
    //     Deno.env.get('SUPABASE_URL') ?? '',
    //     Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    //     { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    //   )
    
    //   // Get the session or user object
    //   const { data } = await supabaseClient.auth.getUser()
    //   const user = data
    //   console.log("User : "+ JSON.stringify(user))

    // const supabaseClient = createClient(
    //     Deno.env.get('SUPABASE_URL') ?? '',
    //     Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    //     { global: { headers: { Authorization: authHeader } } }
    //   )

    // // Get the session or user object
    // const { data: userData } = await supabaseClient.auth.getUser()
    // if (!userData) {
    //     return new Response("Not Authorized", {
    //         status  : 401,
    //          headers: { 'Content-Type': 'application/json' } })
    // }

    // console.log(userData)
    // const {role, status, statusText} = await supabaseClient.rpc('get_claim', { uid: userData.user.id, claim: 'userrole' })
    // if (role !== 'admin') {
    //     return new Response(JSON.stringify(role), {
    //         status  : 401,
    //          headers: { 'Content-Type': 'application/json' } })
    // } 
    // const {data: hospitalData} = await supabaseClient.from('Profile').select('hospitalId').eq('id', userData.user.id)
    // let hospitalId = hospitalData.hospitalId
    // const {data: result, error} = await supabaseClient.auth.admin.inviteUserByEmail(email, { data: { HospitalId: hospitalId } })
    // .catch((error) => {
    //     return new Response(JSON.stringify(error), { headers: { 'Content-Type': 'application/json' } })
    // }
    // )
      
    // return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } })
  })