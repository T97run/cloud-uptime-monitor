import json, time, urllib.request, os
import boto3

S3_BUCKET = os.environ["DATA_BUCKET"]
URLS = [u.strip() for u in os.environ.get("URLS", "https://example.com,https://httpbin.org/get").split(",") if u.strip()]

def _ping(url: str):
    start = time.time()
    try:
        with urllib.request.urlopen(url, timeout=5) as r:
            status = r.getcode()
        ok = 200 <= status < 400
        ms = int((time.time() - start) * 1000)
        return {"url": url, "ok": ok, "ms": ms, "error": None}
    except Exception as e:
        return {"url": url, "ok": False, "ms": None, "error": str(e)}

def handler(event, context):
    results = [_ping(u) for u in URLS]
    payload = {"timestamp": int(time.time()), "results": results}
    s3 = boto3.client("s3")
    s3.put_object(Bucket=S3_BUCKET, Key="status.json", Body=json.dumps(payload).encode("utf-8"))
    return {"ok": True, "count": len(results)}