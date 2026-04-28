const crypto = require("crypto");
const https = require("https");

const endpoint = process.env.COSMOS_ENDPOINT.replace(/\/$/, "");
const key = process.env.COSMOS_KEY;
const database = process.env.COSMOS_DATABASE;
const container = process.env.COSMOS_CONTAINER;

module.exports = async function (context, req) {
  const id = req.params.id || "health";

  if (req.method === "GET" && id === "health") {
    context.res = json(200, { ok: true });
    return;
  }

  if (req.method === "GET") {
    const result = await cosmos("GET", "docs", docLink(id));
    context.res = result.statusCode === 200
      ? json(200, JSON.parse(result.body))
      : json(404, { message: "Not found" });
    return;
  }

  if (req.method === "POST") {
    const item = { ...(req.body || {}), id, pk: "item", updatedAt: new Date().toISOString() };
    await cosmos("POST", "docs", collLink(), JSON.stringify(item), {
      "x-ms-documentdb-is-upsert": "true",
      "x-ms-documentdb-partitionkey": JSON.stringify(["item"])
    });
    context.res = json(201, item);
    return;
  }

  await cosmos("DELETE", "docs", docLink(id), "", {
    "x-ms-documentdb-partitionkey": JSON.stringify(["item"])
  });
  context.res = { status: 204 };
};

function collLink() {
  return `dbs/${database}/colls/${container}`;
}

function docLink(id) {
  return `${collLink()}/docs/${id}`;
}

function json(status, body) {
  return {
    status,
    headers: { "content-type": "application/json" },
    body
  };
}

function cosmos(method, resourceType, resourceLink, body = "", extraHeaders = {}) {
  const date = new Date().toUTCString();
  const auth = authHeader(method, resourceType, resourceLink, date);
  const path = `/${resourceLink}`;

  const options = {
    method,
    hostname: new URL(endpoint).hostname,
    path,
    headers: {
      authorization: auth,
      "x-ms-date": date,
      "x-ms-version": "2018-12-31",
      "content-type": "application/json",
      ...extraHeaders
    }
  };

  return new Promise((resolve, reject) => {
    const request = https.request(options, (response) => {
      let data = "";
      response.on("data", (chunk) => data += chunk);
      response.on("end", () => resolve({ statusCode: response.statusCode, body: data }));
    });
    request.on("error", reject);
    if (body) request.write(body);
    request.end();
  });
}

function authHeader(method, resourceType, resourceLink, date) {
  const payload = `${method.toLowerCase()}\n${resourceType.toLowerCase()}\n${resourceLink}\n${date.toLowerCase()}\n\n`;
  const signature = crypto.createHmac("sha256", Buffer.from(key, "base64")).update(payload).digest("base64");
  return encodeURIComponent(`type=master&ver=1.0&sig=${signature}`);
}
