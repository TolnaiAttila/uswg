# USWG - Ubuntu Server WebGUI
## Követelmények:
1. A telepítéshez sudo jogosultság szükséges.
1. Szükséges operációs rendszer: Ubuntu 20.04 LTS.
1. Internet elérés is szükséges a csomagok telepítéséhez.
1. Ajánlott a használni kívánt szolgáltatásokhoz (kivéve az adapter és UFW) tartozó csomagokat eltávolítani.
## Telepítés

0. Lépjen bele a telepítő mappába.
    ```bash
    cd /utvonal/a/mappaba
    ```
0. Indítsa el a telepítés első fázisát.
    ```bash
    sudo ./installer1.sh
    ```
0. Adja meg a létrehozott "uswguser" jelszavát.
0. Miután lefutott az "installer1.sh" a jelenlegi felhasználói fiókból ki kell jelentkezni.
    ```bash
    sudo pkill -SIGKILL -u felhasznalo
    ```
    A "felhasznalo" helyére a jelenleg bejelentkezett felhasználó nevét helyettesítse be.
    Ha nem tudja ki a felhasználó kérdezze le.
    ```bash
    whoami
    ```
0. Jelentkezzen be az "uswguser" felhasználóval és a hozzá tartozó jelszóval.
0. Lépjen bele az "uswguser" home mappájába.
    ```bash
    cd /home/uswguser
    ```
0. Indítsa el a telepítés második fázisát.
    ```bash
    sudo ./installer2.sh
    ```
0. A telepítés során adja meg a webes kezelőfelület elérhetőségét. Pl.: 192.168.1.2
0. A telepítés során a webes kezelőfelülethez adjon hozzá egy felhasználót (név, jelszó).
0. Ha lefutott a második szkript is, akkor indítsa újra a rendszert.
    ```bash
    sudo reboot
    ```
0. Lépj vissza a saját fiókjába.
0. A telepítés sikerességét tesztelni tudja a következő parancsokkal:
    ```bash
    systemctl status uswg
    ```
    ```bash
    systemctl status nginx
    ```
    Illetve a böngészőbe, ha beírja az elérési címet, amit megadott.