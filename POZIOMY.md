# Analiza Poziomów Trudności i Raport z Reformy Gry (iFunSchool v2)

Niniejszy dokument zawiera:
1. Pierwotną diagnozę kodu źródłowego dotyczącą 15 gier i 6 poziomów trudności (`GameLevel`).
2. Szczegółowy raport ze zrealizowanych zmian w kodzie (`QuestionGenerator.swift`), które sprawiły, że poziomy **Ultimate** i **Godlike** stały się faktycznie najtrudniejsze, przy zachowaniu mechaniki premiowania czasem i punktami.
3. Szczegółowy opis systemu generowania odpowiedzi i dystraktorów opartych na wielu zmiennych strategiach (ochrona przed meta-gamingiem).
4. Wyniki testów automatycznych weryfikujących poprawność generatora.

---

## CZĘŚĆ 1: Diagnoza stanu pierwotnego (Historyczna Analiza Kodu)

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
> **Problem w starym kodzie:** ponieważ trudność samego zadania nie wzrastała proporcjonalnie na wyższych poziomach, gracz dostawał więcej czasu na proste zadanie, przez co wyższy poziom był w praktyce **łatwiejszy** do przejścia bezbłędnie na 5 gwiazdek.

---

### 1.2. Zestawienie 15 gier przed reformą

#### Grupa A: Gry, w których poziom był CAŁKOWICIE IGNOROWANY w generatorze
* **Gra 5: Kolejność działań (`GameType.order`)** – losowane były identyczne jednocyfrowe działania na każdym poziomie. Godlike dawał 45 s zamiast 20 s na to samo zadanie.
* **Gra 6: Ciągi liczbowe (`GameType.sequences`)** – zawsze 4-elementowy prosty ciąg arytmetyczny z krokiem 2–8.
* **Gra 7: Równania (`GameType.equations`)** – zawsze jedno proste równanie jednocyfrowe $y = a;\ x = b \cdot y + c$.

#### Grupa B: Gry, w których Hard, Ultimate i Godlike były KODOWO IDENTYCZNE
* **Gra 2: Odejmowanie (`GameType.subtraction`)** – wspólny blok `default` odjemnik 50–150, różnica 20–100.
* **Gra 3: Mnożenie (`GameType.multiplication`)** – wspólny blok `default` $20\dots 50 \times 15\dots 30$.
* **Gra 4: Dzielenie (`GameType.division`)** – wspólny blok `default` dzielnik 15–40, iloraz 15–35.

#### Grupa C: Gry, w których Ultimate i Godlike były KODOWO IDENTYCZNE
* **Gra 1: Dodawanie (`GameType.addition`)** – wspólny blok `default` (suma 200–1000).
* **Gry 8, 9, 10: Pamięciowe operacje arytmetyczne** – stałe 7 kroków na obu poziomach.
* **Gry 11, 12: Pamięć kształtów i kolorów** – stałe 15 figur i 10.0 s podglądu na obu poziomach.

#### Grupa D: Gry z anomaliami zakresów
* **Gra 15: Flagi państw (`GameType.flags`)** – na poziomie Ultimate pula wynosiła 50 państw, podczas gdy na Hard wynosiła aż 80 państw (anomalia zawężenia puli).

---

## CZĘŚĆ 2: Wdrożona Reforma Trudności Poziomów (Zrealizowano w Kodzie)

Wszystkie poniższe zmiany zostały wdrożone w pliku `iFunSchool v2/QuestionGenerator.swift` oraz zweryfikowane automatycznymi testami jednostkowymi w `iFunSchool v2UITests/QuestionGeneratorTests.swift`.

### 2.1. Główne zasady architektoniczne reformy

1. **Nienaruszone parametry czasowo-punktowe:**
   * Czas `maxTime` ($20\text{ s} \to 25\text{ s} \to 30\text{ s} \to 35\text{ s} \to 40\text{ s} \to 45\text{ s}$) oraz mnożniki punktów ($1.000\times \dots 2.667\times$) pozostały bez zmian. Daje to graczowi pełną satysfakcję ze zdobywania rekordowych wyników punktowych na Godlike.
2. **Parametr `questionIndex` (Dynamiczna progresja w trakcie sesji):**
   * Do interfejsu generatora wprowadzono parametr `questionIndex: Int` ($0\dots 14$).
   * Pozwala to na płynne podnoszenie poprzeczki w trakcie samej rozgrywki (pytania 1–7 wprowadzają w poziom, pytania 8–15 stanowią ekstremalne wyzwanie).
3. **Prawdziwa hierarchia trudności:**
   * Żaden wyższy poziom nie współdzieli już kodu w bloku `default` z niższym poziomem. Każdy poziom (od Beginner do Godlike) posiada unikalną, dedykowaną logikę generowania pytań.

---

### 2.2. Zrealizowane zmiany w poszczególnych grach

#### 1. Dodawanie (`GameType.addition`)
* **Beginner:** Sumy jednocyfrowe ($1\dots 9 + 2\dots 9$).
* **Easy:** Sumy dwucyfrowe do 40 ($1\dots 19 + 2\dots 18$).
* **Medium:** Dodawanie w zakresie $20\dots 100$.
* **Hard:** Dodawanie 3-cyfrowe w zakresie $100\dots 500$.
* **Ultimate:** Dodawanie **3 składników**: $A + B + C$ (np. $185 + 234 + 192$).
* **Godlike:**
  * Pytania 1–7: Trzy duże składniki 3-cyfrowe ($200\dots 800 + 200\dots 800 + 200\dots 800$).
  * Pytania 8–15: Aż **4 składniki** wielocyfrowe ($A + B + C + D$, np. $350 + 420 + 280 + 510$).

#### 2. Odejmowanie (`GameType.subtraction`)
* **Beginner:** Podstawowe odejmowanie jednocyfrowe (różnica $1\dots 10$).
* **Easy:** Różnice dwucyfrowe do 20, odjemna do 50.
* **Medium:** Różnice dwucyfrowe do 50, odjemna do 100.
* **Hard:** Liczby 3-cyfrowe ($200\dots 600 - 50\dots 250$).
* **Ultimate:** Odejmowanie **dwustopniowe / łańcuchowe**: $A - B - C$ (np. $680 - 210 - 150$).
* **Godlike:**
  * Pytania 1–7: Trudne odejmowanie 4-cyfrowe ($1000\dots 4500 - 300\dots 1500$) z pożyczaniem dziesiątek.
  * Pytania 8–15: Łańcuchowe odejmowanie 3 składników od dużej liczby ($A - B - C$, $A$ do 2000).

#### 3. Mnożenie (`GameType.multiplication`)
* **Beginner:** Tabliczka mnożenia ($2\dots 9 \times 2\dots 9$).
* **Easy:** Mnożenie przez liczby nastoczęciowe ($3\dots 9 \times 11\dots 18$).
* **Medium:** Mnożenie dwucyfrowe ($11\dots 24 \times 11\dots 24$).
* **Hard:** Duże liczby dwucyfrowe ($20\dots 50 \times 15\dots 35$).
* **Ultimate:** Mnożenie **3 czynników**: $A \times B \times C$ (np. $5 \times 9 \times 12$).
* **Godlike:**
  * Pytania 1–7: Mnożenie 3 czynników dwucyfrowych ($11\dots 16 \times 11\dots 16 \times 11\dots 15$, iloczyny rzędu 2000–3500).
  * Pytania 8–15: Mnożenie liczby 3-cyfrowej przez dwucyfrową ($120\dots 350 \times 15\dots 45$, iloczyny rzędu 5 000–15 000).

#### 4. Dzielenie (`GameType.division`)
* **Beginner:** Dzielenie tabliczkowe (iloraz $1\dots 10$, dzielnik $2\dots 9$).
* **Easy:** Dzielna do 200 (iloraz $10\dots 20$, dzielnik $3\dots 10$).
* **Medium:** Dzielnik dwucyfrowy ($10\dots 30$, iloraz $10\dots 25$).
* **Hard:** Dzielnik $15\dots 40$, iloraz $20\dots 45$ (dzielna do 1800).
* **Ultimate:** Dzielnik $25\dots 75$, iloraz $30\dots 85$ (dzielna wielocyfrowa $2000\dots 6000$).
* **Godlike:**
  * Pytania 1–7: Duże dzielenie (dzielnik $35\dots 95$, iloraz $55\dots 130$, dzielna do 12 000).
  * Pytania 8–15: Działania łączone ze skracaniem: $(A \times B) \div C$, gdzie wynik wymaga dwuetapowego przeliczenia.

#### 5. Kolejność działań (`GameType.order`)
* **Beginner:** Podstawowe mnożenie i dodawanie: $a + b \times c$ lub $b \times c + a$.
* **Easy:** Mnożenie z odejmowaniem lub proste nawiasy: $(a + b) \times c$.
* **Medium:** Dwa iloczyny lub dwa nawiasy: $a \times b + c \times d$ oraz $(a + b) \times (c - d)$.
* **Hard:** Złożone 4-elementowe wyrażenie z dzieleniem: $a \times b + dividend \div divisor - c$.
* **Ultimate:** Potęgowanie kwadratowe z nawiasami: $a^2 + b \times c - d$ oraz $(a + b^2) \times c - d$.
* **Godlike:** Złożone wielopoziomowe wyrażenia nawiasowe z potęgami: $[(a \times b - c) \div d]^2 + e \times f$.

#### 6. Ciągi liczbowe (`GameType.sequences`)
* **Beginner:** Ciąg arytmetyczny rosnący z małym krokiem ($+1\dots +3$).
* **Easy:** Ciąg arytmetyczny rosnący lub malejący z krokiem $4\dots 9$.
* **Medium:** Ciągi geometryczne ($\times 2, \times 3$) oraz ciągi kwadratów ($n^2$).
* **Hard:** Ciągi Fibonacciego ($a_n = a_{n-1} + a_{n-2}$) oraz ciągi z naprzemiennym krokiem ($+a, -b, +a, -b$).
* **Ultimate:** Ciągi z różnicami drugiego rzędu (przyspieszające: $+2, +5, +8, \dots$).
* **Godlike:**
  * Dwa przeplatane ciągi (np. $A_1, B_1, A_2, B_2, A_3, B_3$, gdzie jeden rośnie, a drugi maleje).
  * Ciągi rekurencyjne typu $a_n = 2a_{n-1} - 1$.

#### 7. Równania (`GameType.equations`)
* **Beginner:** Proste równanie z jedną niewiadomą: $x + a = b$ lub $x - a = b$.
* **Easy:** Równanie liniowe z mnożeniem: $a \cdot x + b = c$.
* **Medium:** Układ podstawieniowy: $y = a;\ x = b \cdot y + c$.
* **Hard:** Układ dwóch równań liniowych: $x + y = a$ oraz $x - y = b$ (szukanie $x$ lub $y$).
* **Ultimate:** Układ ze współczynnikiem: $2x + y = c_1$ oraz $x - y = c_2$.
* **Godlike:**
  * Pytania 1–7: Równania kwadratowe $x^2 - Sx + P = 0$ (szukanie dodatniego pierwiastka ze wzorów Viète'a).
  * Pytania 8–15: Układ 3 równań z 3 niewiadomymi: $x + y + z = S$, $x + y = A$, $y + z = B$ (szukanie $x, y$ lub $z$).

#### 8, 9, 10. Pamięciowe operacje arytmetyczne (`memoryAdd`, `memoryAddSub`, `memoryAddSubMult`)
*Zrealizowano postulat użytkownika dotyczący dynamicznej progresji kroków w ramach 15 pytań:*
* **Beginner:** 3 kroki (stała liczba).
* **Easy:** 4 kroki (pytania 1–8) $\to$ 5 kroków (pytania 9–15).
* **Medium:** 5 kroków (pytania 1–8) $\to$ 6 kroków (pytania 9–15).
* **Hard:** 7 kroków (pytania 1–8) $\to$ 9 kroków (pytania 9–15).
* **Ultimate:** 9 kroków (pytanie 1) $\to$ 14 kroków (pytanie 15). Wzór: `9 + Int(questionIndex * 5 / 14)`.
* **Godlike:**
  * **Wzór w kodzie:** `stepCount = 8 + Int(round(Double(questionIndex) * 15.0 / 14.0))`
  * **Pytanie 1 (index 0):** dokładnie **8 kroków**.
  * **Pytanie 8 (index 7):** dokładnie **16 kroków**.
  * **Pytanie 15 (index 14):** dokładnie **23 kroki**!
  * Gracz na poziomie Godlike musi bezbłędnie przeliczyć w pamięci sekwencję aż 23 kolejnych operacji matematycznych (z mnożeniem, dodawaniem i odejmowaniem w grze 10), co w pełni uzasadnia 45 sekund na odpowiedź.

#### 11 i 12. Pamięć kształtów i Pamięć kolorów (`memoryShapes`, `memoryColors`)
* **Beginner:** 6 elementów, czas podglądu 6.0 s.
* **Easy:** 8 elementów, czas podglądu 6.5 s.
* **Medium:** 10 elementów, czas podglądu 7.0 s.
* **Hard:** 12 elementów, czas podglądu 7.0 s.
* **Ultimate:** 16 elementów (siatka $4 \times 4$), czas podglądu 7.0 s.
* **Godlike:**
  * Skalowanie: **20 elementów** (pytania 1–7) $\to$ aż **24 elementy** (pytania 8–15).
  * Czas podglądu: skrócony do **6.5 s** (mniej niż 0.28 sekundy na zapamiętanie jednej figury!).

#### 13 i 14. Chemia (Symbole i Nazwy pierwiastków)
* **Korekta puli pierwiastków:**
  * **Beginner:** 25 najpopularniejszych pierwiastków (indeksy 0–24, wodór do manganu).
  * **Easy:** 45 pierwiastków (indeksy 0–44).
  * **Medium:** 60 pierwiastków (indeksy 15–74).
  * **Hard:** 70 trudniejszych pierwiastków (indeksy 35–104).
  * **Ultimate:** 60 rzadkich pierwiastków (indeksy 50–109: lantanowce i aktynowce).
  * **Godlike:** 45 najtrudniejszych pierwiastków (indeksy 73–117: od tantalu i wolframu aż po oganesson).

#### 15. Flagi państw (`GameType.flags`)
* **Korekta anomalii puli państw:**
  * **Beginner:** 25 najpopularniejszych państw świata.
  * **Easy:** 50 państw (indeksy 0–49).
  * **Medium:** 60 państw (indeksy 20–79).
  * **Hard:** 75 państw (indeksy 40–114).
  * **Ultimate:** 85 państw (indeksy 60–144) — *naprawiono błąd, gdzie pula była mniejsza niż na Hard*.
  * **Godlike:** Pełna pula 143 najtrudniejszych i najrzadszych państw/terytoriów (indeksy 60–202: Tuvalu, Nauru, Kiribati itp.).

---

## CZĘŚĆ 3: System Generowania Odpowiedzi (Dystraktory i Anti-Meta-Gaming)

Aby uniemożliwić graczowi zgadywanie poprawnej odpowiedzi bez pełnego rozwiązania zadania, wdrożono **zaawansowany silnik generowania fałszywych opcji (dystraktorów)** oparty na wielu zróżnicowanych archetypach błędów.

### 3.1. Zasada Anti-Meta-Gaming (Brak powtarzalnych wzorców)
Jeśli gra stosowałaby sztywną, powtarzalną regułę (np. w grze 7 zawsze podawałaby opcję z przeciwnym znakiem $-x$), gracz mógłby stosować tzw. *meta-gaming* – szukać pary liczb o przeciwnych znakach i wybierać bardziej prawdopodobną, całkowicie ignorując treść równania.

**Rozwiązanie w kodzie:**
* Każde pytanie generuje szeroki zbiór potencjalnych dystraktorów (pool) z **kilku niezależnych strategii**.
* Zbiór ten jest losowo tasowany, a 3 fałszywe opcje są dobierane metodą round-robin z różnych archetypów.
* W rezultacie **każde pytanie w grze ma unikalną, nieprzewidywalną kompozycję odpowiedzi błędnych**.

---

### 3.2. Strategie dystraktorów w grach liczbowych (`makeNumericOptions`)

Dla gier 1–12 generator łączy 5 niezależnych źródeł błędnych opcji:

1. **Strategia A: Błędy specyficzne dla zadania (Context Candidates):**
   * **Dodawanie:** suma częściowa (pominięcie ostatniego składnika), odjęcie jednego składnika zamiast dodania.
   * **Odejmowanie:** dodanie ostatniego składnika ($A - B + C$), odwrócenie kolejności odjemnych.
   * **Mnożenie:** iloczyn tylko pierwszych 2 czynników w $A \times B \times C$, dodanie trzeciego czynnika zamiast pomnożenia, mnożenie przez czynnik przesunięty o 1.
   * **Dzielenie:** iloczyn zamiast ilorazu w zadaniach łączonych $(A \times B) \div C$, dzielnik pominięty lub przesunięty.
   * **Kolejność działań:** wynik obliczeń od lewej do prawej (zignorowanie pierwszeństwa operacji), błąd potęgowania przed dodawaniem, opuszczenie nawiasu.
   * **Równania:** wartość drugiej niewiadomej ($y$ lub $z$ zamiast $x$), drugi pierwiastek równania kwadratowego, suma lub iloczyn współczynników.
   * **Pamięć liczbowa (8, 9, 10):** **wynik przedostatniego kroku** (krok $N-1$) – podchwytliwe dla graczy, którzy zgubili ostatnią operację; odwrócenie znaku ostatniego kroku.
   * **Pamięć kształtów i kolorów (11, 12):** **liczba wystąpień innej figury / innego koloru** z tej samej planszy (np. na planszy było 5 kół i 4 kwadraty $\to$ opcja 4 jest aktywnym dystraktorem!).
2. **Strategia B: Ochrona przed exploitem „ostatniej cyfry” (Same Last Digit):**
   * Przy dużych liczbach (np. $130 \times 25 = 3250$) gracz mógłby wytypować poprawną opcję tylko po cyfrze jedności ($0$).
   * Generator celowo tworzy opcje kończące się na **tę samą cyfrę**: $correct \pm 10, correct \pm 20, correct \pm 100$.
3. **Strategia C: Błędy przeniesienia i pożyczania (Carry / Borrow):**
   * $correct \pm 1$, $correct \pm 9$, $correct \pm 11$, $correct \pm 2$ – symulujące błąd pamięci podręcznej w dodawaniu pisemnym.
4. **Strategia D: Proporcjonalne przesunięcie skali (Scale Offset):**
   * Przesunięcie o wielokrotności $10\%$ wartości wyniku, co uniemożliwia szacowanie rzędu wielkości.
5. **Strategia E: Czeski błąd (Transpozycja cyfr):**
   * Zamiana miejscami dwóch ostatnich cyfr (np. $542 \to 524$), symulująca błąd ludzkiej percepcji.

---

### 3.3. Dystraktory w Chemii i Flagach (Gry 13, 14, 15)

#### Chemia (Gry 13 i 14):
Zamiast losować przypadkowe pierwiastki z całej tablicy, generator korzysta z 4 pul:
1. **Pula grupowa (`chemicalGroupClusters`):** pierwiastki z tej samej grupy chemicznej (np. litowce: Li, Na, K, Rb, Cs; fluorowce: F, Cl, Br, I).
2. **Pula mylących symboli (`chemicalConfusionClusters`):** symbole powszechnie mylone fonetycznie lub literowo (np. Na / N / Ni / Ne; K / P / Pb / Pt; Ag / Au / Al; Cu / Co / Cr).
3. **Pula pierwszej litery:** pierwiastki o tym samym inicjale symbolu (np. dla $Ta$: $Tl, Ti, Tb$).
4. **Pula poziomu:** pierwiastki o zbliżonym stopniu rzadkości.

#### Flagi państw (Gra 15):
Dystraktory dobierane są z 4 niezależnych wymiarów:
1. **Klastry wizualne (`confusingCountryClusters`):** flagi trójkolorowe o identycznych barwach (Czad/Rumunia, Mali/Gwinea, Irlandia/WKS), dwukolorowe (Monako/Indonezja/Polska), krzyże skandynawskie, półksiężyce, gwiazdy.
2. **Klastry geograficzno-regionalne (`regionalCountryPools`):** kraje z tego samego regionu świata (kraje bałtyckie, Bałkany, państwa wyspiarskie Pacyfiku/Oceanii, kraje Azji Środkowej, Afryki Zachodniej, Ameryki Środkowej).
3. **Klastry językowe (`similarNameClusters`):** mylące pary nazw (Słowacja / Słowenia, Niger / Nigeria, Gwinea / Gwinea-Bissau, Dominika / Dominikana).
4. **Pula poziomu trudności:** kraje o zbliżonej rozpoznawalności.

---

## CZĘŚĆ 4: Weryfikacja i Testy Automatyczne

Do projektu dołączono dedykowany zestaw testów jednostkowych w pliku `iFunSchool v2UITests/QuestionGeneratorTests.swift`.

### Zakres wykonanych testów:
1. `testAll15GamesGenerateValidQuestionsForAll6Levels`:
   * Przetestowano wszystkie 15 gier $\times$ wszystkie 6 poziomów trudności ($15 \times 6 = 90$ kombinacji).
   * Zweryfikowano: brak pustych pól tekstowych, dokładnie 4 unikalne opcje odpowiedzi na pytanie, poprawność indeksu `correctIndex` ($0\dots 3$).
2. `testDistractorDiversityAndMultiStrategyPools`:
   * Zweryfikowano generowanie dystraktorów o tej samej ostatniej cyfrze w mnożeniu i dodawaniu (ochrona przed exploitem ostatniej cyfry).
   * Zweryfikowano brak stałych, deterministycznych szablonów fałszywych opcji.
3. `testGodlikeMemoryProgressionFrom8To23Steps`:
   * Przetestowano gry pamięciowe 8, 9 i 10 na poziomie Godlike dla wszystkich 15 pytań ($index = 0\dots 14$).
   * Zweryfikowano: pytanie 1 zaczyna się dokładnie od **8 kroków**, a pytanie 15 kończy się dokładnie na **23 krokach**.
4. `testFullGameQuestionsGenerationFor15Questions`:
   * Zweryfikowano generowanie pełnej 15-pytaniowej sesji dla gier matematycznych, pamięciowych oraz wiedzy ogólnej.
5. `testMemoryAddNoConsecutiveDuplicates`:
   * Zweryfikowano brak powtarzających się bezpośrednio po sobie operacji.
6. `testMemoryAddSubNoDuplicatesAndNoBelowZero`:
   * Zweryfikowano, że wyniki cząstkowe nigdy nie spadają poniżej zera.
7. `testMemoryAddSubMultNoDuplicatesAndNoBelowZero`:
   * Zweryfikowano poprawne obliczenia przy operacjach mnożenia, dodawania i odejmowania w pamięci.

### Wynik polecenia testowego:
```bash
xcodebuild test -project iFunSchool.xcodeproj -scheme "iFunSchool v2UITests" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:"iFunSchool v2UITests/QuestionGeneratorTests"
```
**Status: ** `** TEST SUCCEEDED **` (**7 testów wykonanych, 0 błędów**).
Kompilacja na platformy iOS oraz macOS przeszła bez żadnych ostrzeżeń ani błędów (`** BUILD SUCCEEDED **`).

---

## Podsumowanie Końcowe
Dzięki wprowadzonym modyfikacjom:
* Poziomy **Ultimate** i **Godlike** są teraz niekwestionowanie najtrudniejszymi poziomami w grze.
* Zachowano w pełni mechanikę bicia rekordów punktowych (więcej czasu na pytanie $\times$ wyższy mnożnik punktowy).
* W grach pamięciowych zrealizowano dynamiczny wzrost wyzwania w trakcie samej sesji (od 8 do 23 kroków).
* Odpowiedzi błędne są **inteligentne, podchwytliwe i generowane wielo-strategijnie**, co całkowicie uniemożliwia zgadywanie odpowiedzi za pomocą trików (np. sprawdzania ostatniej cyfry lub par ze zmienionym znakiem).
