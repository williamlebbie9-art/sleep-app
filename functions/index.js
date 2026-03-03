const {setGlobalOptions} = require("firebase-functions/v2");
const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

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

const INITIAL_COMMISSION_USD = 1.0;
const BASE_RENEWAL_RATE = 0.20;
const BONUS_RENEWAL_RATE = 0.05;
const BONUS_REFERRAL_THRESHOLD = 500;
const COMMISSION_CONFIRM_DELAY_DAYS = 10;

/**
 * @param {string | undefined} header
 * @return {string}
 */
function extractBearerToken(header) {
  if (!header) return "";
  const raw = String(header).trim();
  if (raw.toLowerCase().startsWith("bearer ")) {
    return raw.substring(7).trim();
  }
  return raw;
}

/**
 * @param {object} payload
 * @return {object}
 */
function getWebhookEvent(payload) {
  if (payload && payload.event && typeof payload.event === "object") {
    return payload.event;
  }
  return payload || {};
}

/**
 * @param {object} event
 * @return {string}
 */
function getEventId(event) {
  if (event.id) return String(event.id);
  if (event.event_timestamp_ms && event.app_user_id && event.type) {
    return `${event.type}_${event.app_user_id}_${event.event_timestamp_ms}`;
  }
  if (event.type && event.app_user_id && event.transaction_id) {
    return `${event.type}_${event.app_user_id}_${event.transaction_id}`;
  }
  return "";
}

/**
 * @param {unknown} value
 * @return {number | null}
 */
function toNumber(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  return null;
}

/**
 * @param {number} amount
 * @return {number}
 */
function roundUsd(amount) {
  return Math.round(amount * 100) / 100;
}

/**
 * @param {object} event
 * @return {number | null}
 */
function getEventGrossUsd(event) {
  const directUsd = toNumber(event.price_in_usd);
  if (directUsd !== null) {
    return directUsd;
  }

  const proceedsUsd = toNumber(event.proceeds_in_usd);
  if (proceedsUsd !== null) {
    return proceedsUsd;
  }

  const fallback = toNumber(event.price);
  if (fallback !== null) {
    return fallback;
  }

  return null;
}

/**
 * @param {number} referredPaidUsersCount
 * @return {number}
 */
function getRecurringRate(referredPaidUsersCount) {
  if (referredPaidUsersCount >= BONUS_REFERRAL_THRESHOLD) {
    return BASE_RENEWAL_RATE + BONUS_RENEWAL_RATE;
  }
  return BASE_RENEWAL_RATE;
}

/**
 * @param {string} creatorUid
 * @param {string} appUserId
 * @return {string}
 */
function buildReferralEdgeId(creatorUid, appUserId) {
  return `${creatorUid}__${appUserId}`;
}

/**
 * @param {object} event
 * @param {number} referredPaidUsersCount
 * @return {?Object}
 */
function buildCommissionRule(event, referredPaidUsersCount) {
  const eventType = String(event.type || "").trim();

  if (eventType === "INITIAL_PURCHASE") {
    return {
      amountUsd: INITIAL_COMMISSION_USD,
      reason: "initial_purchase_fixed_1usd",
      recurringRate: null,
      baseRevenueUsd: null,
    };
  }

  if (eventType === "RENEWAL") {
    const grossUsd = getEventGrossUsd(event);
    if (grossUsd === null || grossUsd <= 0) {
      return null;
    }

    const recurringRate = getRecurringRate(referredPaidUsersCount);
    const amountUsd = roundUsd(grossUsd * recurringRate);

    return {
      amountUsd: amountUsd,
      reason: recurringRate > BASE_RENEWAL_RATE ?
        "renewal_25_percent" : "renewal_20_percent",
      recurringRate: recurringRate,
      baseRevenueUsd: grossUsd,
    };
  }

  if (eventType === "REFUND") {
    return {
      amountUsd: -INITIAL_COMMISSION_USD,
      reason: "refund_adjustment",
      recurringRate: null,
      baseRevenueUsd: null,
    };
  }

  return null;
}

exports.revenueCatWebhook = onRequest(
    {
      region: "us-central1",
      timeoutSeconds: 60,
      memory: "256MiB",
      secrets: ["REVENUECAT_WEBHOOK_SECRET"],
      cors: false,
    },
    async (request, response) => {
      if (request.method !== "POST") {
        response.status(405).json({error: "Method not allowed"});
        return;
      }

      const expectedSecret = process.env.REVENUECAT_WEBHOOK_SECRET;
      if (!expectedSecret) {
        logger.error("Missing REVENUECAT_WEBHOOK_SECRET");
        response.status(500).json({error: "Webhook secret is not configured"});
        return;
      }

      const authToken = extractBearerToken(request.get("authorization"));
      const altToken = String(request.get("x-webhook-secret") || "").trim();
      const providedSecret = authToken || altToken;
      if (!providedSecret || providedSecret !== expectedSecret) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }

      const event = getWebhookEvent(request.body || {});
      const eventType = String(event.type || "").trim();
      const appUserId = String(event.app_user_id || "").trim();
      const eventId = getEventId(event);
      const nowMs = Date.now();
      const confirmAfterMs =
        nowMs + (COMMISSION_CONFIRM_DELAY_DAYS * 24 * 60 * 60 * 1000);

      if (!eventType || !appUserId || !eventId) {
        response.status(400).json({error: "Invalid RevenueCat payload"});
        return;
      }

      if (
        eventType !== "INITIAL_PURCHASE" &&
        eventType !== "RENEWAL" &&
        eventType !== "REFUND"
      ) {
        response.status(200).json({
          ok: true,
          ignored: true,
          reason: "event_type",
        });
        return;
      }

      const commissionRef = db.collection("commissions").doc(eventId);
      const userRef = db.collection("users").doc(appUserId);

      try {
        const result = await db.runTransaction(async (tx) => {
          const existingCommission = await tx.get(commissionRef);
          if (existingCommission.exists) {
            return {duplicate: true};
          }

          const userSnapshot = await tx.get(userRef);
          if (!userSnapshot.exists) {
            return {ignored: true, reason: "user_not_found"};
          }

          const userData = userSnapshot.data() || {};
          const creatorUid = String(userData.referredByCreatorUid || "").trim();
          const creatorCode =
            String(userData.referredByCreatorCode || "").trim();

          if (!creatorUid || !creatorCode) {
            return {ignored: true, reason: "no_referral"};
          }

          const creatorRef = db.collection("creators").doc(creatorUid);
          const creatorSnapshot = await tx.get(creatorRef);
          const creatorData = creatorSnapshot.data() || {};
          const referredPaidUsersCount = Number(
              creatorData.referredPaidUsersCount || 0,
          );

          const commissionRule = buildCommissionRule(
              event,
              referredPaidUsersCount,
          );
          if (!commissionRule) {
            return {ignored: true, reason: "missing_revenue_amount"};
          }

          const amount = commissionRule.amountUsd;
          if (!Number.isFinite(amount) || amount === 0) {
            return {ignored: true, reason: "zero_commission"};
          }

          const now = admin.firestore.FieldValue.serverTimestamp();

          let referralEdgeCreated = false;
          if (eventType === "INITIAL_PURCHASE") {
            const edgeId = buildReferralEdgeId(creatorUid, appUserId);
            const edgeRef = db.collection("creator_referrals").doc(edgeId);
            const edgeSnap = await tx.get(edgeRef);
            if (!edgeSnap.exists) {
              referralEdgeCreated = true;
              tx.set(edgeRef, {
                id: edgeId,
                creatorUid: creatorUid,
                appUserId: appUserId,
                creatorCode: creatorCode,
                eventId: eventId,
                createdAt: now,
              });
            }
          }

          tx.set(commissionRef, {
            id: eventId,
            eventType: eventType,
            appUserId: appUserId,
            creatorUid: creatorUid,
            creatorCode: creatorCode,
            amountUsd: amount,
            currency: "USD",
            status: "pending",
            reason: commissionRule.reason,
            recurringRate: commissionRule.recurringRate,
            baseRevenueUsd: commissionRule.baseRevenueUsd,
            source: "revenuecat_webhook",
            productId: event.product_id || null,
            entitlementIds: Array.isArray(event.entitlement_ids) ?
              event.entitlement_ids : [],
            transactionId: event.transaction_id || null,
            originalTransactionId: event.original_transaction_id || null,
            purchasedAtMs: event.purchased_at_ms || null,
            eventTimestampMs: event.event_timestamp_ms || null,
            confirmAfterMs: confirmAfterMs,
            createdAt: now,
            updatedAt: now,
          });

          const creatorPatch = {
            uid: creatorUid,
            code: creatorCode,
            pendingBalanceUsd: admin.firestore.FieldValue.increment(amount),
            pendingCommissionsCount: admin.firestore.FieldValue.increment(1),
            updatedAt: now,
          };

          if (referralEdgeCreated) {
            creatorPatch.referredPaidUsersCount =
              admin.firestore.FieldValue.increment(1);
          }

          tx.set(creatorRef, creatorPatch, {merge: true});

          return {
            ok: true,
            creatorUid: creatorUid,
            amountUsd: amount,
            status: "pending",
            confirmAfterMs: confirmAfterMs,
            referredPaidUsersCountDelta: referralEdgeCreated ? 1 : 0,
          };
        });

        response.status(200).json({ok: true, result: result});
      } catch (error) {
        logger.error("revenueCatWebhook failed", error);
        response.status(500).json({error: "Unexpected server error"});
      }
    },
);

exports.confirmPendingCommissions = onSchedule(
    {
      region: "us-central1",
      schedule: "every 60 minutes",
      timeoutSeconds: 300,
      memory: "256MiB",
    },
    async () => {
      const nowMs = Date.now();
      const pendingQuery = await db.collection("commissions")
          .where("confirmAfterMs", "<=", nowMs)
          .limit(300)
          .get();

      if (pendingQuery.empty) {
        logger.info("confirmPendingCommissions: nothing to confirm");
        return;
      }

      let confirmedCount = 0;

      for (const commissionDoc of pendingQuery.docs) {
        const commissionRef = commissionDoc.ref;

        await db.runTransaction(async (tx) => {
          const fresh = await tx.get(commissionRef);
          if (!fresh.exists) return;

          const data = fresh.data() || {};
          if (String(data.status || "") !== "pending") {
            return;
          }

          const confirmAfterMs = Number(data.confirmAfterMs || 0);
          if (confirmAfterMs > nowMs) {
            return;
          }

          const creatorUid = String(data.creatorUid || "").trim();
          const amountUsd = Number(data.amountUsd || 0);
          if (!creatorUid || !Number.isFinite(amountUsd)) {
            return;
          }

          const creatorRef = db.collection("creators").doc(creatorUid);
          const now = admin.firestore.FieldValue.serverTimestamp();

          tx.update(commissionRef, {
            status: "approved",
            approvedAt: now,
            updatedAt: now,
          });

          tx.set(creatorRef, {
            availableBalanceUsd: admin.firestore.FieldValue.increment(
                amountUsd,
            ),
            pendingBalanceUsd: admin.firestore.FieldValue.increment(
                -amountUsd,
            ),
            pendingCommissionsCount: admin.firestore.FieldValue.increment(-1),
            lifetimeCommissionUsd: admin.firestore.FieldValue.increment(
                amountUsd,
            ),
            updatedAt: now,
          }, {merge: true});

          confirmedCount += 1;
        });
      }

      logger.info("confirmPendingCommissions complete", {
        candidates: pendingQuery.size,
        confirmed: confirmedCount,
      });
    },
);
