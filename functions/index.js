const {setGlobalOptions} = require("firebase-functions/v2");
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

setGlobalOptions({maxInstances: 10});

/**
 * Converts app chat history to Gemini API content items.
 * @param {Array<object>} history Incoming chat history.
 * @return {Array<object>} Gemini content array.
 */
function buildHistoryItems(history) {
  return history
      .filter((item) => item && item.text && item.role)
      .slice(-12)
      .map((item) => {
        const role = item.role === "assistant" ? "model" : "user";
        const text = String(item.text).slice(0, 1000);
        return {role: role, parts: [{text: text}]};
      });
}

exports.sleepCoachChat = onRequest(
    {
      region: "us-central1",
      timeoutSeconds: 60,
      memory: "256MiB",
      secrets: ["GEMINI_API_KEY"],
      cors: true,
    },
    async (request, response) => {
      if (request.method !== "POST") {
        response.status(405).json({error: "Method not allowed"});
        return;
      }

      const body = request.body || {};
      const message = String(body.message || "").trim();
      const history = Array.isArray(body.history) ? body.history : [];

      if (!message) {
        response.status(400).json({error: "message is required"});
        return;
      }

      const key = process.env.GEMINI_API_KEY;
      if (!key) {
        logger.error("Missing GEMINI_API_KEY secret");
        response.status(500).json({error: "Server is not configured"});
        return;
      }

      const prefix =
        "You are SleepLock AI Sleep Coach. Be warm and practical. " +
        "Give wellness guidance only, not medical diagnosis. " +
        "For severe symptoms suggest professional care.";

      const contents = [
        {role: "user", parts: [{text: prefix}]},
      ].concat(buildHistoryItems(history)).concat([
        {role: "user", parts: [{text: message}]},
      ]);

      try {
        const providerResponse = await fetch(
            "https://generativelanguage.googleapis.com/v1beta/" +
            "models/gemini-2.0-flash:generateContent",
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "x-goog-api-key": key,
              },
              body: JSON.stringify({
                contents: contents,
                generationConfig: {
                  temperature: 0.7,
                  topP: 0.9,
                  maxOutputTokens: 500,
                },
              }),
            },
        );

        const data = await providerResponse.json();
        if (!providerResponse.ok) {
          logger.error("Gemini request failed", data);
          response.status(502).json({error: "AI provider error"});
          return;
        }

        const candidates = data && data.candidates ? data.candidates : [];
        const content = candidates[0] && candidates[0].content;
        const parts = content && content.parts ? content.parts : [];
        const text = parts[0] && parts[0].text;

        if (!text) {
          response.status(502).json({error: "Empty AI response"});
          return;
        }

        response.status(200).json({reply: String(text).trim()});
      } catch (error) {
        logger.error("sleepCoachChat failed", error);
        response.status(500).json({error: "Unexpected server error"});
      }
    },
);
