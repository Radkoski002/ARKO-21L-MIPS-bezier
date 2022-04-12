.eqv POINTS 11		# 2^POINTS = ilość punktów z których składa się krzywa (POINTS>=0)

	.data
.align 4
res:		.space 2
header:		.space 54
source:		.asciiz "source.bmp"	# nazwa pliku źródłowego
result:		.asciiz "result.bmp"	# nazwa pliku wynikowego
input:		.asciiz "Enter coordinates of p0, p1 and p2 (x0, y0, x1, y1, x2, y2)\n"
open_error_msg:	.asciiz "Failed to open source file"
input_ltz_msg:	.asciiz "Corodinate is less than 0"
input_gtx_msg:	.asciiz "Coordinate x is greater than "
input_gty_msg:	.asciiz "Coordinate y is greater than "

	.text
	.globl main

main:
	li $s0, 1
	sll $s0, $s0, POINTS	# liczba punktów


read_from_file:
# otwarcie pliku ($a0 - nazwa pliku, $a1 - flaga, $a2 tryb)
	li $v0, 13
        la $a0, source
        li $a1, 0
        li $a2, 0
        syscall
        blt $v0, $0, open_error
	move $s1, $v0      # zapis desktyptora
	

# odczyt danych z nagłówka ($a0 - deskryptor, $a1 - adres buforu, $a2 - rozmiar nagłówka)
	li $v0, 14
	move $a0, $s1
	la $a1, header
	li $a2, 54
	syscall

	la $t7, header + 2
	lw $s6, ($t7)		# pobranie informacji o wielkości pliku bez nagłówka
	subu $s6, $s6, 54	# rozmiar pliku bez nagłówka

	addiu $t7, $t7, 8
	lw $s7, ($t7)		# pobranie informacji o offsecie do pierwszego pixela
	subi $s7, $s7, 54

	addiu $t7, $t7, 8
	lw $s4, ($t7)		# pobranie informacji o wymiarze x
	
	addiu $t7, $t7, 4
	lw $s5, ($t7)		# pobranie informacji o wymiarze y
	

# zaalokowanie pamięci na stosie ($a0 - ilość bajtów do zaalokowania na stosie)	
	li $v0, 9
        move $a0, $s6
        syscall		
        move $s2, $v0	# adres pierwszego elementu zaalokowanej pamięci
        
# wczytanie reszty pliku
        li $v0, 14
        move $a0, $s1
        move $a1, $s2
        move $a2, $s6
        syscall
        

        addu $s2, $s2, $s7	# adres pierwszego pixela
	

# zamknięcie pliku ($a0 - deskryptor pliku do zamknięcia)
	li $v0, 16
	move $a0, $s1
        syscall


# Obliczanie paddingu
	sll $s3, $s4, 1
	addu $s3, $s3, $s4	# $s3 = 3 * x
	andi $t7, $s3, 3	# $t7 = (3 * x) % 4
	beqz $t7, input_handling
	subu $s3, $s3, $t7
	addiu $s3, $s3, 4
	

input_handling:
# Wyświetlenie informacji dla użytkownika
	li $v0 4
	la $a0 input
	syscall
	
# Wczytywanie danych od użytkownika
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s4, input_gtx
	move $t0, $v0
	
	
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s5, input_gty
	move $t1, $v0
	
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s4, input_gtx
	move $t2, $v0
	
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s5, input_gty
	move $t3, $v0
	
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s4, input_gtx
	move $t4, $v0
	
	li $v0, 5
	syscall
	blt $v0, $0, input_ltz 
	bgt $v0, $s5, input_gty
	move $t5, $v0
	


	
	beqz $s0, save_file	# jeśli liczba punktów = 0 skocz do zapisu pliku

loop:
	
# obliczanie koordynatów 
	move $t7, $s0		# x = m
	subu $t7, $t7, $t6	# x = m - t
	move $t8, $t7		# tmp = m - t
	mulu $t7, $t7, $t7	# x = (m - t)^2
	mulu $t7, $t7, $t0	# x = (m - t)^2 * x0
	sll $t8, $t8, 1		# tmp = 2 * (m - t)
	mulu $t8, $t8, $t6	# tmp = 2 * (m - t) * t
	mulu $t8, $t8, $t2	# tmp = 2 * (m - t) * t * x1
	addu $t7, $t7, $t8	# x = (m - t)^2 * x0 + 2 * (m - t) * t * x1
	move $t8, $t6		# tmp = t
	mulu $t8, $t8, $t8	# tmp = t^2
	mulu $t8, $t8, $t4	# tmp = t^2 * x2
	addu $t7, $t7, $t8	# x = (m - t)^2 * x0 + 2 * (m - t) * t * x1 + t^2 * x2
	srl $t7, $t7, POINTS	
	srl $t7, $t7, POINTS	# x / m^2
	move $a0, $t7		# zapisanie x jako argument 0 następnej funkcji
	
	move $t7, $s0		# y = m
	subu $t7, $t7, $t6	# y = m - t
	move $t8, $t7		# tmp = m - t
	mulu $t7, $t7, $t7	# y = (m - t)^2
	mulu $t7, $t7, $t1	# y = (m - t)^2 * y0
	sll $t8, $t8, 1		# tmp = 2 * (m - t)
	mulu $t8, $t8, $t6	# tmp = 2 * (m - t) * t
	mulu $t8, $t8, $t3	# tmp = 2 * (m - t) * t * y1
	addu $t7, $t7, $t8	# y = (m - t)^2 * y0 + 2 * (m - t) * t * y1
	move $t8, $t6		# tmp = t
	mulu $t8, $t8, $t8	# tmp = t^2
	mulu $t8, $t8, $t5	# tmp = t^2 * y2
	addu $t7, $t7, $t8	# y = (m - t)^2 * y0 + 2 * (m - t) * t * y1 + t^2 * y2
	srl $t7, $t7, POINTS	
	srl $t7, $t7, POINTS	# y / m^2
	move $a1, $t7		# zapis y jako argument 1 następnej funkcji
	
	move $a2, $0		# zapisanie koloru jako argument 2 do następnej funkcji
	
	addiu $t6, $t6, 1 	# t += 1

print_pixel:
# obliczanie wartości adresu piksela ($a0 - x, $a1 - y, $a2 - kolor)
	mul $t7, $a1, $s3	# t7 = y * (ilość bajtów w rzędzie danego pliku)
	move $t8, $a0		# wczytanie x	
	sll $a0, $a0, 1		# x *= 2
	add $t8, $t8, $a0	# $t8 = 3 * x
	add $t7, $t7, $t8	# $t7 = 3 * x + y * (ilość bajtów w rzędzie danego pliku)
	move $t8, $s2		# wczytanie adresu piewszego piksela
	add $t8, $t8, $t7	# adres piksela
	
# ustawianie koloru pixela
	sb $a2,($t8)		# Niebieski
	srl $a2,$a2,8
	sb $a2,1($t8)		# Zielony
	srl $a2,$a2,8
	sb $a2,2($t8)		# Czerwony
	
	blt $t6, $s0, loop	# jeżeli $t6 > $s0 to skocz do zapisywania pliku

save_file:
# otwarcie pliku wynikowego
	li $v0, 13
        la $a0, result
        li $a1, 1
        li $a2, 0
        syscall
	move $s1, $v0
	
        li $v0, 15	# wczytanie nagłówka
        move $a0, $s1
        la $a1, header
        li $a2, 54
        syscall
	
	subu $s2, $s2, $s7
	
# zapis pliku ($a0 - deskryptor, $a1 - adres buforu, $a2 - maksymalny rozmiar pliku)
	li $v0, 15
	move $a0, $s1
	move $a1, $s2
	move $a2, $s6
	syscall

# zamknięcie pliku
	li $v0, 16
	move $a0, $s1
        syscall

end:
# zakończenie działania programu
	li $v0, 10
	syscall

# Funkcje obsługujące błędy:
open_error:

	li $v0, 4
	la $a0, open_error_msg
	syscall
	b end

input_ltz:

	li $v0, 4
	la $a0, input_ltz_msg
	syscall
	b end
	
input_gtx:

	li $v0, 4
	la $a0, input_gtx_msg
	syscall
	
	li $v0, 1
	move $a0, $s4
	syscall
	b end
	
input_gty:

	li $v0, 4
	la $a0, input_gty_msg
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	b end
	
