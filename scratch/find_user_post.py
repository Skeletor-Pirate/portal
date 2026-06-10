import re

content = open('schema.yaml').read()
# Find all paths and their content
paths = re.findall(r'  (/\S+):([\s\S]+?)(?=\n  /\S+:|\ncomponents:|$)', content)

for path, body in paths:
    if 'post:' in body:
        if 'User' in body:
            print(f"Path: {path}")
            # Find the operationId if any
            op = re.search(r'operationId: (\S+)', body)
            if op: print(f"  Op: {op.group(1)}")
