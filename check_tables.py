import os
import psycopg2

db_url = 'postgresql://neondb_owner:npg_V2Bnuz5xFpYe@ep-nameless-bird-a1pl9bnj-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require'

conn = psycopg2.connect(db_url)
cur = conn.cursor()

cur.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
""")
tables = cur.fetchall()

for table in tables:
    if 'chapter' in table[0].lower() or 'syllabus' in table[0].lower():
        print("FOUND MATCH:", table[0])
    
print("All tables:")
for table in tables:
    if not table[0].startswith('django') and not table[0].startswith('auth'):
        print(table[0])

cur.close()
conn.close()
