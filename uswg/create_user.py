from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash
import uuid
from main import db, Users

loop = True
username = ""
password = ""

print("A felhasználónév min. 4 karakter, max. 50 karakter hosszú lehet!")
print("A jelszó min. 8 karakter, max. 80 karakter hosszú lehet!")

while loop:

    username = input("Addja meg a felhasználónevét: ")
    password = str(input("Adja meg a jelszavát: "))
    password_rep = str(input("Adja meg újra a jelszavát: "))
    
    if len(username) > 3 and len(username) < 51 and len(password) > 7 and len(password) < 81 and password == password_rep:
        loop =False
    else:
        print("Sikertelen!")
        print("A felhasználónév min. 4 karakter, max. 50 karakter hosszú lehet!")
        print("A jelszó min. 8 karakter, max. 80 karakter hosszú lehet!")


hashed_password = generate_password_hash(password, method='pbkdf2', salt_length=16)

new_user = Users(public_id=str(uuid.uuid4()), username=username, password=hashed_password)
db.session.add(new_user)
db.session.commit()