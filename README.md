# ARKO MIPS Projekt - Rysowanie trzypunktowej krzywej beziera
Program pobiera od użytkownika 3 punkty (w postaci 6 kolejnych współrzędnych) i na ich podstawie rysuje krzywą beziera. Następnie zapisuje ją do pliku result.bmp. 
### Znaczenia rejestów:
- ($t0 - $t5) - współrzędne punktów wprowadzone przez użytkownika
- $t6 - licznik pętli
- $s0 - maksymalna liczba puntków/koniec pętli
- $s1 - deskryptor pliku bmp
- $s2 - adres pierwszego piksela w pliku źródłowym
- $s3 - ilość bajtów w rzędzie
- $s4 - x
- $s5 - y
- $s6 - rozmiar pliku
- $s7 - ilość bajtów między nagłówkiem a mapą pixeli
- reszta zależy od funkcji

Do wyliczenia puntków w krzywej użyłem tego wzoru:
p = ((m - t)^2 * p0 + 2 * t * (m - t) * p1 + t^2 * p2)/(m^2)
