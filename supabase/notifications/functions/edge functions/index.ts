import { serve } from "std/server"
import { createClient } from "supabase"
import admin from "firebase-admin"

// Firebase init
const firebaseConfig = JSON.parse(Deno.env.get("FIREBASE_CONFIG") ?? "{}")

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(firebaseConfig),
  })
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
)

serve(async (req) => {
  const { record } = await req.json()

  // Get tokens
  const { data: tokens, error } = await supabase
    .from("notification_tokens")
    .select("token")
    .eq("user_id", record.notified_id)

  if (error || !tokens || tokens.length === 0) {
    return new Response("No tokens found", { status: 200 })
  }

  const tokenList = tokens.map((t) => t.token)

  const message = {
    notification: {
      title: record.type.replaceAll("_", " ").toUpperCase(),
      body: "New notitfication",
    },
    data: {
      id: record.id.toString(),
      type: record.type,
      meta_data: JSON.stringify(record.meta_data),
      notifier: JSON.stringify(record.notifier),
    },
    tokens: tokenList,
  }

  try {
    const response = await admin.messaging().sendEachForMulticast(message)

    // Remove invalid tokens
    const invalidTokens: string[] = []

    response.responses.forEach((res, idx) => {
      if (!res.success) {
        const err = res.error?.code

        if (
          err === "messaging/invalid-registration-token" ||
          err === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(tokenList[idx])
        }
      }
    })

    if (invalidTokens.length > 0) {
      await supabase
        .from("notification_tokens")
        .delete()
        .in("token", invalidTokens)
    }

    return new Response(JSON.stringify(response), { status: 200 })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})