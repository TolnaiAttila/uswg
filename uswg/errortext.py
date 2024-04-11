def error(x):
    if x == 151 :
        text = "A szükséges fájl nem található!"
        return text
    elif x == 153 :
        text = "Hálózati hiba!"
        return text
    elif x == 154 :
        text = "A szükséges elem már létezik!"
        return text
    elif x == 155 :
        text = "Hibás érték!"
        return text
    elif x == 161 :
        text = "Hibás opció!"
        return text
    elif x == 162 :
        text = "Sérült a szükséges fájl struktúrája!"
        return text
    elif x == 163 :
        text = "A két jelszó nem azonos!"
        return text
    elif x == 164 :
        text = "Hiba történ egy vagy több szkript futásában!"
        return text
    elif x == 165 :
        text = "A megadott érték már szerepel a listában!"
        return text
    elif x == 166 :
        text = "A megadott érték még használatban van!"
        return text
    else:
        return "Ismeretlen hiba! Ez hatalmas probléma!"