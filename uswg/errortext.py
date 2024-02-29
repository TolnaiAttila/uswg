def error(x):
    if x == 1 :
        text = "A szükséges fájl nem található!"
        return text
    elif x == 3 :
        text = "Hálózati hiba!"
        return text
    elif x == 4 :
        text = "A szükséges elem már létezik!"
        return text
    elif x == 5 :
        text = "Hibás érték!"
        return text
    elif x == 10 :
        text = "Hibás opció!"
        return text
    elif x == 11 :
        text = "Sérült a szükséges fájl struktúrája!"
        return text
