
file = open('constellationship.fab.txt', 'r')

out = open('links.csv', 'w')

out.write("con;links\n")

for l in file.readlines():
  l = l.strip()
  if len(l) > 1:
    tok = l.split(' ')
    con = tok[0]
    out.write(con + ";" + ",".join(tok[3:]) + "\n")
