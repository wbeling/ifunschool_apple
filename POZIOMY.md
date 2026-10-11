# Analiza Poziomów Trudności i Plan Reformy Gry (iFunSchool v2)

Niniejszy dokument zawiera kompletną analizę kodu źródłowego dotyczącą 15 gier i 6 poziomów trudności (`GameLevel`), diagnozę problemu braku rosnącej trudności na najwyższych poziomach (w tym na poziomie **Godlike**) oraz propozycję konkretnych zmian.

---

## CZĘŚĆ 1: Diagnoza obecnego stanu (Analiza Kodu)

### 1.1. Globalne parametry poziomów

| Poziom | ID | Czas na pytanie (`maxTime`) | Mnożnik punktów (`scoreMultiplier`) | Liczba pytań | Wymóg odblokowania |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Beginner** | 0 | 20.0 s | 1.000x (15/15) | 15 | 0 gwiazdek |
| **Easy** | 1 | 25.0 s | 1.333x (20/15) | 15 | 0-14 gwiazdek |
| **Medium** | 2 | 30.0 s | 1.667x (25/15) | 15 | 15-29 gwiazdek |
| **Hard** | 3 | 35.0 s | 2.000x (30/15) | 15 | 30-44 gwiazdek |
| **Ultimate** | 4 | 40.0 s | 2.333x (35/15) | 15 | 45-59 gwiazdek |
| **Godlike** | 5 | 45.0 s | 2.667x (40/15) | 15 | Zakup IAP / Odblokowanie |

> **Kluczowy fakt systemowy:**
> Punkty za pytanie liczone są ze wzoru: `questionScore = timeRemaining * scoreMultiplier`.
> Dłuższy czas bazowy (`maxTime`) pozwala na zdobycie znacznie większej liczby punktów na wyższych poziomach.
> **Jednakże:** jeśli trudność samego zadania nie wzrasta, gracz dostaje więcej czasu na proste zadanie, przez co wyższy poziom staje się w praktyce **łatwiejszy** do przejścia bezbłędnie (5 gwiazdek).

---

### 1.2. Zestawienie 15 gier — jak kod faktycznie traktuje poziomy

#### Grupa A: Gry, w których poziom jest CAŁKOWICIE IGNOROWANY w generatorze
* **Gra 5: Kolejność działań (`GameType.order`)**
  * Kod ignoruje parametr `level`. Wszystkie poziomy (0–5) losują identyczne jednocyfrowe działania typu: $a + b \times c$, $b \times c + a$, $a + b \times c + d$.
  * *Wniosek:* Poziom **Godlike jest najłatwiejszy** — ma te same proste pytania co Beginner, ale daje graczowi 45 s zamiast 20 s!
* **Gra 6: Ciągi liczbowe (`GameType.sequences`)**
  * Kod ignoruje parametr `level`. Na każdym poziomie jest 4-elementowy ciąg arytmetyczny z krokiem $2\dots 8$.
  * *Wniosek:* **Godlike jest najłatwiejszy**.
* **Gra 7: Równania (`GameType.equations`)**
  * Kod ignoruje parametr `level`. Zawsze równanie: $y = a;\ x = b \cdot y + c$ z liczbami jednocyfrowymi.
  * *Wniosek:* **Godlike jest najłatwiejszy**.

#### Grupa B: Gry, w których Hard, Ultimate i Godlike są KODOWO IDENTYCZNE
* **Gra 2: Odejmowanie (`GameType.subtraction`)**
  * Beginner, Easy, Medium mają dedykowane zakresy.
  * Hard, Ultimate i Godlike wpadają do wspólnego bloku `default`: odjemnik $50\dots 150$, różnica $20\dots 100$.
  * *Wniosek:* Poziom **Hard jest trudniejszy niż Ultimate i Godlike**, ponieważ daje tylko 35 s na to samo zadanie (Godlike daje 45 s).
* **Gra 3: Mnożenie (`GameType.multiplication`)**
  * Hard, Ultimate i Godlike wpadają w `default`: $20\dots 50 \times 15\dots 30$.
  * *Wniosek:* **Hard jest najtrudniejszy**, Godlike daje najwięcej czasu (45 s).
* **Gra 4: Dzielenie (`GameType.division`)**
  * Hard, Ultimate i Godlike wpadają w `default`: dzielnik $15\dots 40$, iloraz $15\dots 35$.
  * *Wniosek:* **Hard jest najtrudniejszy**.

#### Grupa C: Gry, w których Ultimate i Godlike są KODOWO IDENTYCZNE
* **Gra 1: Dodawanie (`GameType.addition`)**
  * Ultimate i Godlike wpadają w `default`: suma $200\dots 1000$.
* **Gra 8: Pamięciowe dodawanie (`GameType.memoryAdd`)**
  * Ultimate i Godlike wpadają w `default`: dokładnie 7 kroków, tempo 1.2 s/krok.
* **Gra 9: Pamięciowe dodawanie i odejmowanie (`GameType.memoryAddSub`)**
  * Ultimate i Godlike wpadają w `default`: dokładnie 7 kroków.
* **Gra 10: Pamięciowe operacje (+, -, ×) (`GameType.memoryAddSubMult`)**
  * Ultimate i Godlike wpadają w `default`: dokładnie 7 kroków.
* **Gra 11: Pamięć kształtów (`GameType.memoryShapes`)**
  * Ultimate i Godlike wpadają w `default`: dokładnie 15 figur w siatce, 10.0 s na zapamiętanie.
* **Gra 12: Pamięć kolorów (`GameType.memoryColors`)**
  * Ultimate i Godlike wpadają w `default`: dokładnie 15 figur, 10.0 s na zapamiętanie.
* *Wniosek:* W grach 1, 8, 9, 10, 11 i 12 poziom Godlike ma identyczną mechanikę co Ultimate, ale daje 45 s na kliknięcie odpowiedzi (zamiast 40 s), więc nie jest trudniejszy.

#### Grupa D: Gry z faktycznym zróżnicowaniem bazy wiedzy
* **Gra 13: Symbole chemiczne (`GameType.chemSymbols`)**
  * Beginner: indeksy 0–24, Easy: 0–49, Medium: 20–69, Hard: 40–89, Ultimate: 60–109, Godlike: 65–117 (do Oganessonu).
  * Pula pierwiastków na Godlike to najcięższe pierwiastki transuranowe.
* **Gra 14: Nazwy pierwiastków (`GameType.chemNames`)**
  * Analogicznie do Gry 13.
* **Gra 15: Flagi państw (`GameType.flags`)**
  * Beginner: 25 najpopularniejszych państw.
  * Easy: 50 państw.
  * Medium: 50 państw (indeksy 20–69).
  * Hard: 80 państw (indeksy 40–119).
  * Ultimate: 50 państw (indeksy 60–109) — *anomalia: węższy zakres niż na Hard!*
  * Godlike: aż 143 państwa (indeksy 60–202), w tym mikro-państwa i terytoria sporne.

---

### 1.3. Podsumowanie pytania: Czy ostatni poziom jest najtrudniejszy?
**Nie.** W 12 na 15 gier poziom Godlike **nie jest najtrudniejszy**:
1. W 3 grach (5, 6, 7) jest **najłatwiejszy** (identyczne zadania, 2.25x więcej czasu).
2. W 3 grach (2, 3, 4) trudniejszy jest **Hard**.
3. W 6 grach (1, 8, 9, 10, 11, 12) trudniejszy jest **Ultimate**.
4. Jedynie w chemii i flagach (13, 14, 15) poziom Godlike ma najtrudniejszą merytorycznie pulę wiedzy, ale nadal gracz ma aż 45 s na wybranie 1 z 4 opcji.

---

## CZĘŚĆ 2: Projekt Reformy Trudności Poziomów

### Założenia projektowe
1. **Zachowanie rosnącego czasu (`maxTime`) i mnożników:** 
   * Czas $20\text{ s} \to 25\text{ s} \to 30\text{ s} \to 35\text{ s} \to 40\text{ s} \to 45\text{ s}$ zostaje nienaruszony, aby umożliwić bicie rekordów punktowych.
2. **Adresowanie trudności:** 
   * Wyższe poziomy, a w szczególności **Ultimate** i **Godlike**, muszą być autentycznym wyzwaniem umysłowym, które uzasadnia dodatkowy czas.
3. **Dynamiczna progresja w ramach 15 pytań:**
   * Poziom Godlike może skalować trudność w trakcie samej sesji gry (pytanie 1 jest łatwiejsze, pytanie 15 to ekstremalne wyzwanie).

---

### Szczegółowy plan zmian dla każdej gry

#### 1. Dodawanie
* **Beginner:** Sumy do 10 (tabliczka podstawowa: $1\dots 5 + 1\dots 5$).
* **Easy:** Sumy do 20 / dodawanie do 50.
* **Medium:** Dodawanie dwucyfrowe: $20\dots 100 + 10\dots 50$.
* **Hard:** Dodawanie 3-cyfrowych: $100\dots 500 + 100\dots 500$.
* **Ultimate:** Dodawanie **3 składników**: $A + B + C$ (np. $145 + 280 + 365$).
* **Godlike:** Liczby 4-cyfrowe lub **4 składniki** (np. $1420 + 3850 + 940$), z progresją od 3 liczb w pytaniu 1 do 4 liczb wielocyfrowych w pytaniu 15.

#### 2. Odejmowanie
* **Beginner:** Do 10.
* **Easy:** Do 30.
* **Medium:** Do 100 (np. $84 - 39$).
* **Hard:** Liczby 3-cyfrowe: $200\dots 800 - 50\dots 400$.
* **Ultimate:** Odejmowanie łańcuchowe: $A - B - C$ (np. $850 - 240 - 180$).
* **Godlike:** Liczby 4-cyfrowe z przekroczeniami rzędów (np. $5234 - 2879$) lub łańcuchowe $A - B - C - D$.

#### 3. Mnożenie
* **Beginner:** $2\dots 9 \times 2\dots 9$.
* **Easy:** $3\dots 9 \times 11\dots 19$.
* **Medium:** $11\dots 25 \times 11\dots 25$.
* **Hard:** $20\dots 50 \times 15\dots 35$.
* **Ultimate:** 3 czynniki $A \times B \times C$ (np. $6 \times 7 \times 15$) lub 3-cyfrowa $\times$ 2-cyfrowa ($145 \times 24$).
* **Godlike:** 3-cyfrowa $\times$ 3-cyfrowa ($234 \times 156$) lub 3 czynniki dwucyfrowe ($12 \times 15 \times 18$).

#### 4. Dzielenie
* **Beginner:** Tabliczka dzielenia (dzielna do 50).
* **Easy:** Dzielna do 200, dzielnik jednocyfrowy.
* **Medium:** Dzielnik dwucyfrowy ($10\dots 25$), iloraz do 25.
* **Hard:** Dzielna 3-cyfrowa, dzielnik $15\dots 40$, iloraz $20\dots 50$.
* **Ultimate:** Dzielna 4-cyfrowa ($1000\dots 5000$), dzielnik dwucyfrowy ($25\dots 80$).
* **Godlike:** Dzielna 5-cyfrowa lub operacje łączone $(A \times B) \div C$.

#### 5. Kolejność działań
* **Beginner:** $a + b \times c$ (liczby $2\dots 9$).
* **Easy:** Zmiana kolejności: $a \times b - c$ oraz nawiasy $(a + b) \times c$.
* **Medium:** 3 działania: $a \times b + c \times d$ lub $(a + b) \times (c - d)$.
* **Hard:** 4 działania z dzieleniem: $a \times b + c \div d - e$, liczby dwucyfrowe.
* **Ultimate:** Potęgowanie i nawiasy: $(a^2 + b) \times c - d \times e$.
* **Godlike:** Złożone wyrażenia zagnieżdżone: $[(a \times b - c) \div d]^2 + e \times f$, gdzie z każdym kolejnym pytaniem w sesji przybywa poziom zagnieżdżenia.

#### 6. Ciągi liczbowe
* **Beginner:** Ciąg arytmetyczny rosnący z małym krokiem ($+1, +2, +3$).
* **Easy:** Ciąg arytmetyczny z krokiem do $+10$ lub malejący.
* **Medium:** Ciąg geometryczny ($\times 2, \times 3$) lub ciąg kwadratów liczb ($1, 4, 9, 16, \dots$).
* **Hard:** Ciąg Fibonacciego / ciąg naprzemienny ($+a, -b, +a, -b, \dots$).
* **Ultimate:** Ciągi nieliniowe (np. różnice drugiego rzędu: $+2, +4, +6, +8, \dots$, wzory $n^2 + 2n$).
* **Godlike:** Dwa przeplatane ciągi (np. $2, 20, 4, 18, 6, 16, ?$) lub ciągi rekurencyjne $a_n = a_{n-1} + 2a_{n-2}$.

#### 7. Równania
* **Beginner:** $x + a = b$ lub $x - a = b$.
* **Easy:** $a \cdot x + b = c$ (jedna niewiadoma).
* **Medium:** $y = a;\ x = b \cdot y + c$.
* **Hard:** Układ dwóch równań: $x + y = a$ oraz $x - y = b$.
* **Ultimate:** Układ równań z mnożeniem: $2x + 3y = a$ oraz $x - y = b$.
* **Godlike:** Równania kwadratowe $x^2 + px + q = 0$ (o całkowitych pierwiastkach) lub układ 3 równań z 3 niewiadomymi.

#### 8, 9, 10. Gry pamięciowe arytmetyczne (`memoryAdd`, `memoryAddSub`, `memoryAddSubMult`)
*Zastosowanie postulatu użytkownika:* dynamiczna progresja kroków w ramach sesji (od pytania 1 do 15):
* **Beginner:** 3 kroki (stała liczba).
* **Easy:** 4 kroki (pytania 1–8) $\to$ 5 kroków (pytania 9–15).
* **Medium:** 5 do 7 kroków.
* **Hard:** 7 do 10 kroków.
* **Ultimate:** 10 do 15 kroków.
* **Godlike (Gra 10 i pokrewne):** 
  * Wzór: `steps = 8 + questionIndex` (dla pytań $0\dots 14$).
  * **Pytanie 1:** 8 kroków.
  * **Pytanie 8:** 15 kroków.
  * **Pytanie 15:** aż **22 kroki**!
  * Na poziomie Godlike gracz musi utrzymać w pamięci sekwencję ponad 20 operacji mnożenia, dodawania i odejmowania, co w 100% uzasadnia 45 sekund na weryfikację i wybranie wyniku.

#### 11 i 12. Pamięć kształtów i Pamięć kolorów
* **Beginner:** 6 figur, 6.0 s podglądu.
* **Easy:** 8 figur, 7.0 s podglądu.
* **Medium:** 10 figur, 8.0 s podglądu.
* **Hard:** 12 figur, 8.0 s podglądu (mniej czasu na figurę: $0.66\text{ s}$).
* **Ultimate:** 16 figur (siatka $4 \times 4$), 7.0 s podglądu.
* **Godlike:** 
  * 20 do 25 figur (siatka $4 \times 5$ lub $5 \times 5$), podgląd skrócony do 6.0–7.0 s.
  * Opcjonalnie w Godlike: pytanie o **kombinację** cech, np. "Ile jest czerwonych trójkątów?" (jednoczesne zapamiętanie kształtu i koloru).

#### 13 i 14. Chemia (Symbole i Nazwy)
* **Beginner do Hard:** Zachowanie logicznego podziału układu okresowego.
* **Ultimate:** Lantanowce i aktynowce (indeksy 57–102).
* **Godlike:** Pierwiastki superciężkie (103–118) ORAZ inteligentny dobór fałszywych odpowiedzi:
  * Odpowiedzi mylące nie powinny być losowe, lecz bardzo podobne fonetycznie i symbolicznie (np. pytając o *Tantal (Ta)*, opcje to: *Ta, Tl, Ti, Tb*).

#### 15. Flagi państw
* **Korekta błędu Hard vs Ultimate:**
  * **Beginner:** 25 najpopularniejszych państw.
  * **Easy:** 50 państw.
  * **Medium:** 70 państw (indeksy 20–70).
  * **Hard:** 60 trudniejszych państw (indeksy 40–100).
  * **Ultimate:** 70 rzadkich państw (indeksy 80–150).
  * **Godlike:** 143 najtrudniejsze i najrzadsze państwa/terytoria (indeksy 60–202: Tuvalu, Kiribati, Nauru, Somaliland itp.).
* **Inteligentne fałszywe flagi:**
  * Na poziomach Ultimate i Godlike błędne odpowiedzi powinny mieć podobny wzór/kolorystykę (np. Rumunia vs Czad, Monako vs Indonezja, Mali vs Gwinea, flagi z krzyżem skandynawskim).
