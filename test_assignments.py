import requests

BASE_URL = "http://187.127.139.208:8081"

def check_endpoint(path):
    url = f"{BASE_URL}{path}"
    try:
        r = requests.get(url, timeout=5)
        print(f"{path}: {r.status_code}")
    except Exception as e:
        print(f"{path}: ERROR {e}")

check_endpoint("/api/v1/assignments/")
check_endpoint("/api/v1/operations/assignments/")
check_endpoint("/api/v1/academics/assignments/")
check_endpoint("/api/v1/teacher-assignments/")
