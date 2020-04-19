.eqv	TWO	33554432
.eqv	FOUR	67108864
		.data
output:			.asciiz "juliaout.bmp"
.align 2
naglowek_bufor: 	.space 54
piksele_bufor: 		.space 3600
skala_kolorow: 		.word 7 11 13

#do komunikacji z u¿ytkownikiem
wez_szerokosc:		.asciiz "Szerokosc obrazka: "
wez_wysokosc:		.asciiz "\nWysokosc obrazka: "
wez_czesc_rzeczywista:	.asciiz "\nWpisz stala (liczby w od -1 do 1 w formacie x*2^24):\nRe(c): "
wez_czesc_urojona:	.asciiz "\nIm(c): "
wez_liczbe_iteracji:	.asciiz "\nWpisz liczbe iteracji: "
wiadomosc_koniec:	.asciiz "\nWynik w pliku juliaout.bmp"

		.text
main:
wez_zmienne:
	#pobieramy szerokosc od uzytkownika
	li $v0, 4           
	la $a0, wez_szerokosc
	syscall
	li $v0, 5
	syscall
	move $s1, $v0
	
	#pobieramy wysokosc od uzytkownika
	li $v0, 4           
	la $a0, wez_wysokosc
	syscall
	li $v0, 5
	syscall
	move $s2, $v0
	
	#pobieramy liczbê iteracji od u¿ytkownika
	li $v0, 4           
	la $a0, wez_liczbe_iteracji
	syscall
	li $v0, 5
	syscall
	move $s5, $v0
	
	#pobieramy Re(c) od uzytkownika
	li $v0, 4           
	la $a0, wez_czesc_rzeczywista
	syscall
	li $v0, 5
	syscall
	move $s6, $v0
	
	#pobieramy Im(c) od uzytkownika
	li $v0, 4           
	la $a0, wez_czesc_urojona
	syscall
	li $v0, 5
	syscall
	move $s7, $v0  
	
stworz_naglowek: #zapisujemy w buforze dane zgodnie z formatem nag³ówka bmp
	#sygnatura	
	la $t1, naglowek_bufor
	li $t2, 'B'
	sb $t2, ($t1)
	addiu $t1, $t1, 1
	li $t2, 'M'
	sb $t2, ($t1)
	addiu $t1, $t1, 1
	
	#rozmiar pliku w bajtach
	mul $t2, $s1, 3
	mul $s0, $t2, $s2
	mul $t2, $s1, $t9
	addu $s0, $s0, $t2
	addiu $t3, $s3, 54
	sh $t3, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $t3, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	
	#zarezerwowane bajty, których nasza aplikacja nie u¿ywa
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#offset
	li $t2, 54
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#wielkoœæ nag³ówka DIB
	li $t2, 40
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#szerokoœæ
	sh $s1, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $s1, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	
	#wysokoœæ
	sh $s2, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $s2, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	
	#liczba warstw kolorów
	li $t2, 1
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	
	#liczba bitów na piksel
	li $t2, 24
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	
	#kompresja
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#rozmiar samego obrazu
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#rozdzielczoœæ pozioma
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#rodzielczoœæ pionowa
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#liczba kolorów w palecie
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#liczba wa¿nych kolorów w palecie
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	#flaga rotacji ustawiona na domyœlne 0
	
stworz_plik:
	#otwieramy plik
	li $v0, 13
	la $a0, output
	li $a1, 1
	li $a2, 0
	syscall
	
	#zapisujemy nag³ówek
	move $a0, $v0
	li $v0, 15
	la $a1, naglowek_bufor
	li $a2, 54
	syscall
	
# $s0 - liczba bitów			$t0 - iterator pêtli julia
# $s1 - szerokoœæ			$t1 - iterator szerokoœci
# $s2 - wysokoœæ			$t2 - iterator wysokoœci
# $s5 - liczba iteracji			$t3 - iterator bufora pikseli
# $s6 - Re(c)				$t4 - rejestr pomocniczy do obliczeñ
# $s7 - Im(c)				$t5 - -||-
# $fp - bufor dla pikseli		$t6 - -||-
#($fp jako dodatkowy rejestr)		$t7 - -||-
#$ra -||-				$t8 - -||-
					#$t9 - iterator bufora

przygotuj_petle:	
	li $fp, 3000
	subiu $fp, $fp, 3
	
	li $t2, 4
	divu $s1, $t2
	mfhi $t9
	move $s0, $t9
	li $t9, 0
	
	li $t1, 0
	li $t2, 0
	subi $t1, $t1, 1 #inkrementujemy petle na pocz¹tku wiêc musimy wyrównaæ
	la $t3, piksele_bufor
	
poziomo:
	li $t0, 0
	bge $t9, $fp, zapisz_do_pliku
	addiu $t9, $t9, 3 #kolejny piksel w buforze
	addi $t1, $t1, 1 #kolejny piksel w poziomie
	bge $t1, $s1, pionowo
	
skalowanie:
	#w obliczeniach przyjmujemy 8 bitów na czêœæ ca³kowit¹ i 24 na u³amkow¹
	#skalujemy aktualne wspó³rzêdne na podstawie wzoru skal(x)=2*x/szer-1 <=> x=2/szer(x-szer/2) - analog. dla y
	li $t4, TWO
	div $t4, $t4, $s1
	mflo $t7
	mul $t5,$t7,$t1	
	srl $t8,$s1,1
	mul $t8,$t8,$t7
	sub $t5,$t5,$t8
	
	#analogicznie dla wysokoœci
	li $t4, TWO
	div $t4, $t4, $s2
	mflo $t7
	mul $t6,$t7,$t2
	srl $t8,$s2,1
	mul $t8,$t8,$t7
	sub $t6,$t6,$t8
	
julia:
	#jeœli dla danego piksela wykonaliœmy wszystkie iteracje, kolorujemy go
	beq $t0, $s5, koloruj_piksel
	
	#obliczanie wartosci funkcji dla danej iteracji
	#Re(z)^2
	mult $t5, $t5
	mfhi $t7
	mflo $t8
	srl $t8, $t8, 24
	sll $t7,$t7, 8
	or $t7, $t7, $t8
	#Im(z)^2
	mult $t6, $t6
	mfhi $t8
	mflo $t4
	srl $t4, $t4, 24
	sll $t8, $t8, 8
	or $t8, $t8, $t4
	#Re(z)^2-Im(z)^2
	subu $t7,$t7,$t8
	#Re(z)*Im(z)
	mult $t5, $t6,
	mfhi $t4
	mflo $ra
	srl $ra, $ra, 24 #skoñczy³y mi siê rejestry
	sll $t4, $t4, 8
	or $t4, $t4, $ra
	#2Re(z)*Im(z)
	sll $t4,$t4,1
	#zapisujemy dla nastepnej iteracji
	move $t5, $t7
	move $t6, $t4
	#Re(z)^2-Im(z)^2+Re(c)
	addu $t5, $t5, $s6
	#2Re(z)*Im(z)+Im(c)
	addu $t6, $t6, $s7
	
	#obliczanie modu³u otrzymanej liczby aby sprawdziæ, czy nie wysz³a za ustalon¹ granicê
	#Re(z)^2
	mult $t5, $t5
	mfhi $t7
	mflo $t8
	sll $t7,$t7, 8
	srl $t8, $t8, 24
	or $t7, $t7, $t8
	#Im(z)^2
	mult $t6, $t6
	mfhi $t4
	mflo $t8
	sll $t4, $t4, 8
	srl $t8, $t8, 24
	or $t8, $t4, $t8
	#Re(z)^2+Im(z)^2
	addu $t7, $t7, $t8
	#|z|<2 => Re(z)^2+Im(z)^2 < 4 
	bgt $t7, FOUR, koloruj_piksel
	
	#kolejna iteracja
	addiu $t0, $t0, 1
	b julia
	
koloruj_piksel:
	la $t8, skala_kolorow
	lw $t6, ($t8) 
	lw $t7, 4($t8)
	lw $t8, 8($t8)
	
	#red
	mult $t0, $t6
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1
	
	#green
	mult $t0, $t7
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1
	
	#blue
	mult $t0, $t8
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1	
	j poziomo

pionowo:
	move $t5, $s0
padding:
	#po dojœciu do koñca wiersza musimy dodaæ padding
	beqz $t5, sprawdz_czy_koniec
	sb $zero, ($t3)
	addiu $t3, $t3, 1
	addiu $t9, $t9, 1
	subiu $t5, $t5, 1
	j padding
	bge $t9, $fp, zapisz_do_pliku
sprawdz_czy_koniec:
	li $t1, 0 #reset iteratora poziomego
	addi $t2, $t2, 1 #kolejny wiersz
	bge $t2, $s2, zapisz_do_pliku
	j skalowanie
	
zapisz_do_pliku:
	li $v0, 15
	la $a1, piksele_bufor
	move $a2, $t9
	syscall
	
	li $t9, 0
	la $t3, piksele_bufor
	bne $t2, $s2, poziomo
	
	#zamykamy plik
	li $v0, 16
	syscall
	
	#wiadomoœæ o udanym przetworzeniu obrazu
	li $v0, 4           
	la $a0, wiadomosc_koniec
	syscall
koniec:
	li $v0, 10
	syscall
