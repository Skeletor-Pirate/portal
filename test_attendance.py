import sys
import json
import requests

def test_login():
    res = requests.post("http://127.0.0.1:8000/api/v1/auth/token/", json={
        "email": "teacher1@example.com",
        "password": "password123"
    })
    if res.status_code != 200:
        print("Login failed:", res.text)
        return None
    return res.json()["access"]

def test_attendance(token):
    # First get a profile context
    res = requests.get("http://127.0.0.1:8000/api/v1/auth/me/", headers={"Authorization": f"Bearer {token}"})
    print("Me:", res.status_code, res.text)

    res = requests.get("http://127.0.0.1:8000/api/v1/academics/teacher-assignments/", headers={"Authorization": f"Bearer {token}"})
    print("Assignments:", res.status_code, res.text)
    
    if res.status_code == 200 and res.json().get('results'):
        a = res.json()['results'][0]
        # Get enrollments
        res_e = requests.get(f"http://127.0.0.1:8000/api/v1/academics/enrollments/", headers={"Authorization": f"Bearer {token}"})
        print("Enrollments:", res_e.status_code)
        enrolls = [e for e in res_e.json().get('results', []) if e['section'] == a['section']]

        if not enrolls:
            print("No enrollments found for section")
            return

        records = [{
            "student_id": e["student"],
            "status": "Present",
            "remarks": ""
        } for e in enrolls]

        payload = {
            "academic_year_id": a["academic_year"],
            "class_level_id": a["class_level"],
            "section_id": a["section"],
            "date": "2026-06-09",
            "records": records
        }
        res_post = requests.post("http://127.0.0.1:8000/api/v1/operations/attendance/bulk-record/", headers={"Authorization": f"Bearer {token}"}, json=payload)
        print("POST Attendance:", res_post.status_code, res_post.text)

if __name__ == '__main__':
    t = test_login()
    if t:
        test_attendance(t)
