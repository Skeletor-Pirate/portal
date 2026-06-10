import requests

base = "http://187.127.139.208:8081/api/v1"
endpoints = [
    "/accounts/users/",
    "/accounts/user/",
    "/users/",
    "/user/",
    "/auth/users/",
    "/auth/user/",
    "/auth/register/",
    "/auth/signup/",
    "/accounts/registers/",
    "/accounts/signup/",
    "/core/users/",
    "/core/user/",
    "/school/users/",
    "/tenant/users/",
]

for ep in endpoints:
    url = base + ep
    try:
        r = requests.options(url, timeout=2)
        print(f"{url} -> {r.status_code} {r.headers.get('Allow', '')}")
    except Exception as e:
        print(f"{url} -> Error: {e}")
