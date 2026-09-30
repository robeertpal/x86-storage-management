.data
    operatii: .space 4
    vector: .space 4096
    codOperatie: .space 4
    fisiere: .space 4
    dimensiune: .space 8
    indexADD: .space 4
    ID: .space 4
    index: .space 4
    indexDEFRAGMENTATION: .space 4
    ultimul: .space 4
    liber: .space 4
    transformare: .long 8
    blocuri: .space 4
    start: .space 4
    stop: .space 4
    contor: .space 4
    formatScanf: .asciz "%ld"
    formatPrintf: .asciz " %ld\n"
    formatADD: .asciz "%ld: (%ld, %ld)\n"
    formatGET: .asciz "(%ld, %ld)\n"
    formatDELETE: .asciz "%ld: "
    formatSHOW: .asciz "%ld: "
    formatAfisare: .asciz "%ld "
    n: .long 1024
    

.text

ADD:
    cmpl $8, dimensiune
    jle nicioAdaugareADD

    xorl %edx, %edx
    xorl %eax, %eax

    movl dimensiune, %eax
    divl transformare
    movl %eax, blocuri

    cmpl $0, %edx
    je faraRestADD

    restADD:
        incl blocuri

    faraRestADD:

    movl $0, liber

    movl $0, start
    movl $0, stop

    xorl %eax, %eax
    xorl %edx, %edx
    cautareSpatiiLibereADD:
        movl blocuri, %edx
        cmpl %edx, liber
        je adaugareADD
 
        cmpl n, %eax
        je nicioAdaugareADD

        movl (%esi, %eax, 4), %ebx

        cmpl $0, %ebx
        jne spatiuNeLiberADD

        spatiuLiberADD:
            cmpl $0, liber
            je initializareStartADD

            actualizareStopADD:
                incl liber
                movl %eax, stop
            jmp cautareSpatiiLibereFinalADD
            
            initializareStartADD:
                incl liber
                movl %eax, start
                movl $0, stop
        jmp cautareSpatiiLibereFinalADD
       
        spatiuNeLiberADD:
            movl $0, liber
            movl $0, start
            movl $0, stop
        jmp cautareSpatiiLibereFinalADD
            
       cautareSpatiiLibereFinalADD:
            incl %eax
    jmp cautareSpatiiLibereADD

    adaugareADD:
        movl ID, %ebx

        movl start, %eax
        adaugareStartStopADD:
            cmpl %eax, stop
            je adaugareaUltimuluiADD

            movl %ebx, (%esi, %eax, 4)

            incl %eax
        jmp adaugareStartStopADD

        adaugareaUltimuluiADD:
            movl %ebx, (%esi, %eax, 4)
    jmp afisareADD
      
    afisareADD:
        pushl stop
        pushl start
        pushl ID
        pushl $formatADD
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

    jmp finalADD

    nicioAdaugareADD:
        pushl $0
        pushl $0
        pushl ID
        pushl $formatADD
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

    jmp finalADD

    finalADD:
        pushl $0
        call fflush
        popl %ebx
ret

GET:
    movl $0, contor
    movl $0, start
    movl $0, stop

    xorl %eax, %eax
    cautareIDGET:
        cmpl n, %eax
        je afisareGET
            
        movl (%esi, %eax, 4), %ebx

        cmpl ID, %ebx
        jne verificareGET

        incl contor

        contorizareGET:
            cmpl $1, contor
            je initializareStartGET

            actaulizareStopGET:
                movl %eax, stop
            jmp finalCautareIDGET

            initializareStartGET:
                movl %eax, start
        jmp finalCautareIDGET

        verificareGET:
            cmpl $0, contor
        jne afisareCuSuccesGET
        
        finalCautareIDGET:
            incl %eax
    jmp cautareIDGET

    afisareGET:
        cmpl $0, stop
        jne afisareCuSuccesGET

        afisareNulaGET:
            pushl $0
            pushl $0
            pushl $formatGET
            call printf
            popl %ebx
            popl %ebx
            popl %ebx
        jmp finalGET

        afisareCuSuccesGET:
            pushl stop
            pushl start
            pushl $formatGET
            call printf
            popl %ebx
            popl %ebx
            popl %ebx
    jmp finalGET

    finalGET:
        pushl $0
        call fflush
        popl %ebx
ret

DELETE:
    xorl %eax, %eax
    cautareSiStergereDELETE:
        cmpl n, %eax
        je iesireCautareSiStergereDELETE

        movl (%esi, %eax, 4), %ebx

        cmpl ID, %ebx
        jne finalCautareSiStergereDELETE

        movl $0, (%esi, %eax, 4)

        finalCautareSiStergereDELETE:
            incl %eax
    jmp cautareSiStergereDELETE

    iesireCautareSiStergereDELETE:
        call SHOW 
    finalDELETE:
ret

SHOW:
    movl $-1, ultimul
    
    movl $0, contor
    afisareSHOW:
        xorl %eax, %eax
        movl contor, %eax
        cmpl n, %eax
        je finalSHOW

        movl (%esi, %eax, 4), %ebx

        cmpl $0, %ebx
        jne afisarePotentialaSHOW

        jmp finalAfisareSHOW

        afisarePotentialaSHOW:
            cmpl ultimul, %ebx
            jne afisareNecesaraSHOW

            jmp finalAfisareSHOW

            afisareNecesaraSHOW:
                movl %ebx, ultimul
                movl %ebx, ID

                pushl ID
                pushl $formatSHOW
                call printf
                popl %ebx
                popl %ebx

                pushl $0
                call fflush
                popl %ebx

                pushl contor
                call GET
                popl contor
        jmp finalAfisareSHOW
        
        finalAfisareSHOW:
            incl contor
    jmp afisareSHOW

    finalSHOW:
ret

DEFRAGMENTATION:
    movl $0, contor
    
    xorl %eax, %eax
    mutareLaStangaDEFRAGMENTATION:
        cmpl n, %eax
        je completareaCu0DEFRAGMENTATION

        movl (%esi, %eax, 4), %ebx
        
        cmpl $0, %ebx
        jne mutareDEFRAGMENTATION

        jmp finalMutareLaStangaDEFRAGMENTATION

        mutareDEFRAGMENTATION:
            xorl %edx, %edx
            movl contor, %edx
            movl %ebx, (%esi, %edx, 4)
            incl contor
        jmp finalMutareLaStangaDEFRAGMENTATION

        finalMutareLaStangaDEFRAGMENTATION:
            incl %eax
    jmp mutareLaStangaDEFRAGMENTATION

    completareaCu0DEFRAGMENTATION:
        xorl %eax, %eax
        movl contor, %eax
        cmpl n, %eax
        je afisareDEFRAGMENTATION

        movl $0, (%esi, %eax, 4)

        incl contor
    jmp completareaCu0DEFRAGMENTATION
    
    afisareDEFRAGMENTATION:
        call SHOW
    jmp finalDEFRAGMENTATION

    finalDEFRAGMENTATION:
ret

.global main

main:
    pushl $operatii
    pushl $formatScanf
    call scanf
    pop %ebx
    pop %ebx

    lea vector, %esi

    movl $0, index
    etichetaFor:
        movl index, %ecx
        cmpl %ecx, operatii
        je etichetaExit

        pushl $codOperatie
        pushl $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        movl $1, %eax
        cmp %eax, codOperatie
        je etichetaADD

        movl $2, %eax
        cmp %eax, codOperatie
        je etichetaGET

        movl $3, %eax
        cmp %eax, codOperatie
        je etichetaDELETE

        movl $4, %eax
        cmp %eax, codOperatie
        je etichetaDEFRAGMENTATION

        finalEtichetaFor:
            incl index
    jmp etichetaFor

    etichetaADD:
        pushl $fisiere
        pushl $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        movl $0, indexADD

        movl $0, %eax
        etichetaForADD:
            movl indexADD, %eax
            cmp %eax, fisiere
            je finalEtichetaFor

            pushl $ID
            pushl $formatScanf
            call scanf
            pop %ebx
            pop %ebx

            pushl $dimensiune
            pushl $formatScanf
            call scanf
            pop %ebx
            pop %ebx

            call ADD

            incl indexADD
    jmp etichetaForADD

    etichetaGET:
        pushl $ID
        pushl $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        call GET

    jmp finalEtichetaFor

    etichetaDELETE:
        pushl $ID
        pushl $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        call DELETE

    jmp finalEtichetaFor

    etichetaDEFRAGMENTATION:
    
        call DEFRAGMENTATION

    jmp finalEtichetaFor

etichetaExit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax 
    xorl %ebx, %ebx
    int $0x80
