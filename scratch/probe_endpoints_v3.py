import requests

base = "http://187.127.139.208:8081/api/v1"
endpoints = [
    "/accounts/registration/",
    "/accounts/register/",
    "/auth/registration/",
    "/auth/register/",
    "/core/registration/",
    "/profiles/registration/",
    "/registration/",
]

for ep in endpoints:
    url = base + ep
    try:
        r = requests.options(url, timeout=2)
        print(f"{url} -> {r.status_code} {r.headers.get('Allow', '')}")
    except Exception as e:
        print(f"{url} -> Error: {e}")
