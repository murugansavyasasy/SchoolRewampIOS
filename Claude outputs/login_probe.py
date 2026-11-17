#!/usr/bin/env python3
"""
School Chimes login probe (read-only).

What it does
  1. POST app/api/auth/validate-user   (you type mobile + password; nothing is saved)
  2. If the server asks for OTP: POST app/api/auth/validate-otp (you type the OTP)
  3. For every staff record and every child record returned:
       GET dashboard/api/dashboard/menus        (read-only)
       GET dashboard/api/dashboard/menu-counts  (read-only)
  4. One GET of the staff menus with a deliberately invalid token, to see how the
     server reports a bad/expired token.
  5. Optionally, one validate-user call with a wrong password, to capture the
     invalid-credentials response.

What it never does
  - send messages, notices, homework, voice, device tokens, or call logout
  - write the password, OTP or any access token to disk

Output
  login_probe_result.json next to this script. Tokens, names, phone numbers,
  e-mails, addresses and photo URLs are replaced with placeholders.

Run:  python3 login_probe.py
"""
import getpass
import json
import os
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

BASE = "https://apiv8.schoolchimes.net/"      # India base_url (isBaseUrl = true)
REPORT = "https://reportv8.schoolchimes.net/"  # India reporting_url (isBaseUrl = false)

REDACT_KEYS = {
    "name", "mobile_no", "mobile_number", "email", "address", "father_name",
    "mother_name", "secondary_mobile", "whatsapp_number", "staff_profile",
    "profile", "school_logo", "school_logo_url", "father_occupation",
    "mother_occupation", "blood_group", "dial_numbers", "class_teacher",
    "school_address", "emp_id", "roll_number",
}


def scrub(obj):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            lk = k.lower()
            if "token" in lk and isinstance(v, str):
                out[k] = f"<token redacted, {len(v)} chars>" if v else "<empty>"
            elif lk == "name" and not ("staff_id" in obj or "child_id" in obj):
                out[k] = v  # menu / group / class names stay readable
            elif lk in REDACT_KEYS and isinstance(v, str):
                out[k] = "<redacted>" if v else "<empty>"
            else:
                out[k] = scrub(v)
        return out
    if isinstance(obj, list):
        return [scrub(x) for x in obj]
    return obj


def call(method, url, params=None, token=""):
    headers = {"Accept": "Application/json", "Content-Type": "Application/json",
               "Authorization": token}
    data = None
    if method == "GET" and params:
        url = url + "?" + urllib.parse.urlencode(params)
    elif params is not None:
        data = json.dumps(params).encode()
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=30, context=ssl.create_default_context()) as r:
            code, body = r.status, r.read()
    except urllib.error.HTTPError as e:
        code, body = e.code, e.read()
    except Exception as e:  # network error
        return {"http_status": None, "error": str(e)}
    try:
        parsed = json.loads(body.decode() or "null")
    except ValueError:
        parsed = {"non_json_body_first_300_chars": body.decode(errors="replace")[:300]}
    return {"http_status": code, "ms": int((time.time() - t0) * 1000), "body": parsed}


def path_only(url):
    return url.replace(BASE, "").replace(REPORT, "")


def main():
    result = {"generated": time.strftime("%Y-%m-%d %H:%M:%S"), "steps": []}

    def log(label, method, url, params_shown, resp):
        result["steps"].append({
            "step": label, "method": method, "path": path_only(url),
            "host": "report" if url.startswith(REPORT) else "base",
            "request_fields": params_shown,
            "http_status": resp.get("http_status"), "ms": resp.get("ms"),
            "error": resp.get("error"),
            "response": scrub(resp.get("body")),
        })

    mobile = input("Mobile number: ").strip()
    password = getpass.getpass("Password (hidden): ")
    secure_id = str(uuid.uuid4()).upper()  # a new device id, like a fresh install

    p = {"mobile_number": mobile, "device_type": "Iphone", "secure_id": secure_id,
         "password": password}
    r = call("POST", BASE + "app/api/auth/validate-user", p)
    log("validate-user (mobile + password)", "POST", BASE + "app/api/auth/validate-user",
        ["mobile_number", "device_type", "secure_id", "password"], r)
    body = r.get("body") or {}
    data = (body.get("data") or [{}])[0] if isinstance(body, dict) else {}

    if data.get("otp_sent"):
        otp = getpass.getpass("OTP (hidden): ")
        r2 = call("POST", BASE + "app/api/auth/validate-otp",
                  {"mobile_number": mobile, "otp": otp})
        log("validate-otp", "POST", BASE + "app/api/auth/validate-otp",
            ["mobile_number", "otp"], r2)
        # Same device id again after OTP, as SplashVC would on the next launch
        r3 = call("POST", BASE + "app/api/auth/validate-user", p)
        log("validate-user again after OTP (same secure_id)", "POST",
            BASE + "app/api/auth/validate-user",
            ["mobile_number", "device_type", "secure_id", "password"], r3)
        b3 = r3.get("body") or {}
        d3 = (b3.get("data") or [{}])[0] if isinstance(b3, dict) else {}
        if d3.get("user_details"):
            data = d3

    ud = data.get("user_details") or {}
    records = [("staff", s) for s in (ud.get("staff_details") or [])] + \
              [("parent", c) for c in (ud.get("child_details") or [])]

    for kind, rec in records:
        tok = rec.get("access_token") or ""
        tag = f"{kind} school_id={rec.get('school_id')} " + \
              (f"priority_level={rec.get('priority_level')} role={rec.get('role')}"
               if kind == "staff" else f"child_id={rec.get('child_id')}")
        mp = {"member_type": kind, "mobile_number": mobile, "language_code": "en"}
        rm = call("GET", REPORT + "dashboard/api/dashboard/menus", mp, tok)
        log(f"menus [{tag}]", "GET", REPORT + "dashboard/api/dashboard/menus",
            ["member_type", "mobile_number", "language_code", "Authorization: record token"], rm)
        rc = call("GET", REPORT + "dashboard/api/dashboard/menu-counts",
                  {"member_type": kind}, tok)
        log(f"menu-counts [{tag}]", "GET", REPORT + "dashboard/api/dashboard/menu-counts",
            ["member_type", "Authorization: record token"], rc)

    rb = call("GET", REPORT + "dashboard/api/dashboard/menus",
              {"member_type": "staff", "mobile_number": mobile, "language_code": "en"},
              "invalid-token-for-test")
    log("menus with an invalid token", "GET", REPORT + "dashboard/api/dashboard/menus",
        ["member_type", "mobile_number", "language_code", "Authorization: invalid"], rb)

    if input("Also test a wrong password once? [y/N]: ").strip().lower() == "y":
        bad = dict(p, password=password + "_wrong")
        rw = call("POST", BASE + "app/api/auth/validate-user", bad)
        log("validate-user with a wrong password", "POST",
            BASE + "app/api/auth/validate-user",
            ["mobile_number", "device_type", "secure_id", "password (wrong)"], rw)

    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "login_probe_result.json")
    with open(out, "w") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    print(f"\nSaved redacted results to {out}")
    print(f"{len(records)} record(s) found; {len(result['steps'])} calls logged.")


if __name__ == "__main__":
    main()
