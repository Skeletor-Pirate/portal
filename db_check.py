import psycopg2
conn = psycopg2.connect("postgresql://neondb_owner:npg_V2Bnuz5xFpYe@ep-nameless-bird-a1pl9bnj-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require")
cur = conn.cursor()
cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
tables = cur.fetchall()
for t in tables:
    if 'assignment' in t[0].lower():
        print(t[0])
