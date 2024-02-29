# USWG - Ubuntu Server WebGUI
## Telepítés
0. A telepítéshez sudo jogosultság szükséges.
0. Lépj bele a telepítő mappába.
    ```bash
    cd /utvonal/a/mappaba
    ```
0. Indítsd el a telepítés első fázisát.
    ```bash
    sudo ./installer1.sh
    ```
0. Add meg a létrehozott "uswguser" jelszavát.
0. Miután lefutott az "installer1.sh" a jelenlegi felhasználói fiókból ki kell jelentkezned.
    ```bash
    sudo pkill -SIGKILL -u felhasznalo
    ```
    A "felhasznalo" helyére a jelenleg bejelentkezett felhasználó nevét helyettesítsd be.
    Ha nem tudod ki a felhasználó kérdezd le.
    ```bash
    whoami
    ```
0. Jelentkezz be az "uswguser" felhasználóval és a hozzá tartozó jelszóval.
0. Lépj bele az "uswguser" home mappájába.
    ```bash
    cd /home/uswguser
    ```
0. Indítsd el a telepítés második fázisát
    ```bash
    sudo ./installer2.sh
    ```
0. A telepítés során a webes kezelőfelülethez adj hozzá egy felhasználót (név, jelszó).
0. A telepítés sikerességét tesztelni tudod a következő parancsokkal:
    ```bash
    systemctl status uswg
    ```
    ```bash
    systemctl status nginx
    ```
    Illetve a böngészőbe ha beírod az elérési címet, amit megadtál.
0. Ha sikeres volt a telepítés jelentkezz ki az "uswguser" felhasználóval.
    ```bash
    sudo pkill -SIGKILL -u uswguser
    ```
0. Lépj vissza a saját fiókodba.