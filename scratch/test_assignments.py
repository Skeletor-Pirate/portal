import sys
import json
import requests

def test_assignments():
    res = requests.post("http://187.127.139.208:8081/api/v1/auth/token/", json={
        "email": "teacher1@example.com",
        "password": "password123"
    })
    if res.status_code != 200:
        print("Login failed:", res.text)
        return
    token = res.json()["access"]
    print("Token:", token[:20] + "...")

    res_a = requests.get("http://187.127.139.208:8081/api/v1/operations/assignments/", headers={"Authorization": f"Bearer {token}"})
    print("Assignments:", res_a.status_code)
    try:
        print(json.dumps(res_a.json(), indent=2)[:500])
    except:
        print(res_a.text)

    res_s = requests.get("http://187.127.139.208:8081/api/v1/operations/submissions/", headers={"Authorization": f"Bearer {token}"})
    print("Submissions:", res_s.status_code)
    try:
        print(json.dumps(res_s.json(), indent=2)[:500])
    except:
        print(res_s.text)

if __name__ == '__main__':
    test_assignments()
