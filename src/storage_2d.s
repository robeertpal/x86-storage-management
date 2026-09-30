.data
    operatii: .space 4
    matrice: .space 4194304
    codOperatie: .space 4
    fisiere: .space 4
    dimensiune: .space 8
    indexADD: .space 4
    ID: .space 4
    formatPath: .asciz "%s"
    path: .space 256
    linie: .space 8
    linieDefragmentation: .space 8
    coloanaDefragmentation: .space 8
    coloana: .space 8
    index: .space 4
    indexDEFRAGMENTATION: .space 4
    ultimul: .space 4
    liber: .space 4
    directorID: .space 4
    transformare: .long 8
    blocuri: .space 4
    startLinie: .space 4
    linieDEFRAGMENTATION: .space 4
    coloanaDEFRAGMENTATION: .space 4
    startColoana: .space 4
    stopLinie: .space 4
    stopColoana: .space 4
    contor: .space 64
    contorLinie: .space 64
    contorColoana: .space 64
    formatScanf: .asciz "%ld"
    formatPrintf: .asciz " %ld\n"
    formatADD: .asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    formatSHOW: .asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    formatGET: .asciz "((%ld, %ld), (%ld, %ld))\n"
    formatDELETE: .asciz "%ld: "
    formatDEBUGDF: .asciz "ID: %ld dimensiune:%ld\n"
    formatAfisare: .asciz "%ld "
    formatInt: .asciz "%ld "
    newLine: .asciz "\n"
    dimensiuneMatrice: .long 1024
    n: .long 1024
    formatDebug: .asciz "debug: %ld\n"
    formatDebugLinii: .asciz "debug          LINIA : %ld\n"
    formatDebugColoane: .asciz "debug COLOANA: %ld -  VALOAREA %ld\n"
    

.text


ADD:
    cmpl $8, dimensiune
    jle afisareNula

    xorl %edx, %edx
    xorl %eax, %eax
    movl dimensiune, %eax
    divl transformare

    movl %eax, blocuri

    cmpl $0, %edx
    je faraRest

    rest:
        incl blocuri

    faraRest:

    xorl %eax, %eax
    xorl %edx, %edx

    movl $0, liber

    xorl %ecx, %ecx
    parcurgereLiniiADD:
        movl linie, %ecx
        cmpl n, %ecx
        je afisareNula

        movl $0, liber

        parcurgereColoaneADD:
            movl liber, %edx
            cmpl blocuri, %edx
            je adaugare

            movl coloana, %ecx
            cmpl n, %ecx
            je iesireDinParcurgereaColoanelorADD

            xorl %eax, %eax
            movl linie, %eax
            mull n
            addl coloana, %eax

            movl (%edi, %eax, 4), %ebx

            cmpl $0, %ebx
            jne spatiuNeLiberADD

            spatiuLiberADD:
                cmpl $0, liber
                je spatiuLiberNouADD

                spatiuLiberContinuareADD:
                    incl liber
                    
                    movl linie, %ebx
                    movl %ebx, stopLinie

                    movl coloana, %ebx
                    movl %ebx, stopColoana

                jmp continuareParcurgereaColoanelorADD

                spatiuLiberNouADD:
                    movl $1, liber

                    movl linie, %ebx
                    movl %ebx, startLinie

                    movl coloana, %ebx
                    movl %ebx, startColoana

                jmp continuareParcurgereaColoanelorADD
            
            spatiuNeLiberADD:
                movl $0, liber
        
            continuareParcurgereaColoanelorADD:
                
                incl coloana
        jmp parcurgereColoaneADD

        iesireDinParcurgereaColoanelorADD:

        incl linie
        movl $0, coloana
    jmp parcurgereLiniiADD
    

    adaugare:
        movl startColoana, %ecx
        movl %ecx, coloana

        movl startLinie, %ecx
        movl %ecx, linie

        movl $0, %ecx
        adaugareLinii:
            movl linie, %ecx
            cmpl %ecx, stopLinie
            jl iesireAdaugareLinii

            adaugareColoane:
                movl coloana, %ecx
                cmpl %ecx, stopColoana  
                #stopColoana<coloana
                jl continuareAdaugareLinii

                movl linie, %eax
                mull dimensiuneMatrice
                addl coloana, %eax

                movl ID, %ebx
                movl %ebx, (%edi, %eax, 4)
    
                addl $1, coloana
                jmp adaugareColoane

            continuareAdaugareLinii:
                addl $1, linie
                jmp adaugareLinii
        
        iesireAdaugareLinii:


        afisareADD:
            pushl stopColoana
            pushl stopLinie
            pushl startColoana
            pushl startLinie
            pushl ID
            pushl $formatADD
            call printf
            popl %ebx
            popl %ebx
            popl %ebx
            popl %ebx
            popl %ebx
            popl %ebx

            pushl $0
            call fflush
            popl %eax

            xorl %ebx, %ebx
            movl stopLinie, %ebx
            movl %ebx, linieDEFRAGMENTATION

            xorl %ebx, %ebx
            movl stopColoana, %ebx
            movl %ebx, coloanaDEFRAGMENTATION

    jmp finalADD

    afisareNula:
        pushl $0
        pushl $0
        pushl $0
        pushl $0
        pushl ID
        pushl $formatADD
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        pushl $0
        call fflush
        popl %eax
    finalADD:
ret

GET:
    movl $0, startLinie
    movl $0, stopLinie

    movl $0, startColoana
    movl $0, stopColoana

    movl $0, liber

    xorl %ecx, %ecx

    xorl %eax, %eax

    movl $0, linie
    parcurgereLiniiGET:
        movl linie, %ecx
        cmpl n, %ecx
        je iesireParcurgereaLiniilorGET

        movl $0, coloana
        parcurgereColoaneGET:
            movl coloana, %ecx
            cmpl n, %ecx
            je continuareParcurgereaLiniilorGET

            movl linie, %eax
            mull dimensiuneMatrice
            addl coloana, %eax

            movl (%edi, %eax, 4), %ebx

            cmpl ID, %ebx
            je identificat

            jmp continuareParcurgereaColoanelorGET
            
            identificat:
                cmpl $0, liber
                je startIdentificat

                stopIdentificat:
                    movl linie, %edx
                    movl %edx, stopLinie

                    movl coloana, %edx
                    movl %edx, stopColoana

                jmp continuareParcurgereaColoanelorGET

                startIdentificat:
                    movl linie, %edx
                    movl %edx, startLinie

                    movl coloana, %edx
                    movl %edx, startColoana

                    incl liber

                jmp continuareParcurgereaColoanelorGET

            continuareParcurgereaColoanelorGET:
                incl coloana
            jmp parcurgereColoaneGET

        continuareParcurgereaLiniilorGET:
            incl linie
    jmp parcurgereLiniiGET
        

        
    iesireParcurgereaLiniilorGET:

    afisareGET:

        pushl stopColoana
        pushl stopLinie
        pushl startColoana
        pushl startLinie
        pushl $formatGET
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        pushl $0
        call fflush
        popl %eax

    finalGET:
ret

DELETE:
    xorl %ecx, %ecx
    movl $0, linie
    parcurgereLiniiDELETE:
        movl linie, %ecx
        cmpl n, %ecx
        je iesireParcurgereaLiniilorDELETE

        movl $0, coloana
        parcurgereColoaneDELETE:
            movl coloana, %ecx
            cmpl n, %ecx
            je continuareParcurgereaLiniilorDELETE

            movl linie, %eax
            mull n
            addl coloana, %eax

            movl (%edi, %eax, 4), %ebx

            cmpl ID, %ebx
            jne continuareParcurgereaColoanelorDELETE

            stergere:
                movl $0, (%edi, %eax, 4)

            continuareParcurgereaColoanelorDELETE:
                addl $1, coloana
        jmp parcurgereColoaneDELETE

        continuareParcurgereaLiniilorDELETE:
            addl $1, linie
    jmp parcurgereLiniiDELETE
        
    iesireParcurgereaLiniilorDELETE:
ret

SHOW:
    movl $0, ultimul
    xorl %ecx, %ecx

    movl $0, linie
    parcurgereLiniiSHOW:
        movl linie, %ecx
        cmpl n, %ecx
        je iesireParcurgereaLiniilorSHOW

        movl $0, coloana
        parcurgereColoaneSHOW:
            movl coloana, %ecx
            cmpl n, %ecx
            je continuareParcurgereaLiniilorSHOW

            movl linie, %eax
            mull n
            addl coloana, %eax

            movl (%edi, %eax, 4), %ebx

            cmpl $0, %ebx
            je continuareParcurgereaColoanelorSHOW

            cmpl ultimul, %ebx
            jne afisareSHOW

            jmp continuareParcurgereaColoanelorSHOW

            afisareSHOW:
                movl %ebx, ultimul
                movl %ebx, ID

                movl $0, startLinie
                movl $0, stopLinie
                movl $0, startColoana
                movl $0, stopColoana

                movl linie, %eax
                movl %eax, startLinie
                movl %eax, stopLinie
                movl coloana, %eax
                movl %eax, startColoana

                gasireStopSHOW:
                    movl linie, %eax
                    mull n
                    addl coloana, %eax

                    movl (%edi, %eax, 4), %ebx

                    cmpl ID, %ebx
                    jne stopGasit

                    addl $1, coloana
                jmp gasireStopSHOW

                stopGasit:
                    decl coloana
                    movl coloana, %eax
                    movl %eax, stopColoana

                finalAfisareSHOW:
                    pushl stopColoana
                    pushl stopLinie
                    pushl startColoana
                    pushl startLinie
                    pushl ID
                    pushl $formatSHOW
                    call printf
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx
                    popl %ebx

                    pushl $0
                    call fflush
                    popl %eax

            continuareParcurgereaColoanelorSHOW:
                addl $1, coloana
        jmp parcurgereColoaneSHOW

        continuareParcurgereaLiniilorSHOW:
            addl $1, linie
    jmp parcurgereLiniiSHOW
        
    iesireParcurgereaLiniilorSHOW:
ret

DEFRAGMENTATION:
    movl $0, linieDEFRAGMENTATION
    movl $0, coloanaDEFRAGMENTATION
    movl $0, ultimul

    xorl %ecx, %ecx
    movl $0, linie
    parcurgereLiniiDEFRAGMENTATION:
        movl linie, %ecx
        cmpl n, %ecx
        je iesireDinParcurgereDEFRAGMENTATION

        movl $0, coloana
        parcurgereColoaneDEFRAGMENTATION:
            movl coloana, %ecx
            cmpl n, %ecx
            je continuareParcurgereaLiniilorDEFRAGMENTATION

            xorl %eax, %eax
            movl linie, %eax
            mull n
            addl coloana, %eax

            movl (%edi, %eax, 4), %ebx

            cmpl $0, %ebx
            je continuareParcurgereaColoanelorDEFRAGMENTATION

            mutare:
                movl %ebx, ID
                movl $0, dimensiune
                xorl %ebx, %ebx

                aflareDimensiune:
                    xorl %eax, %eax
                    movl linie, %eax
                    mull n
                    addl coloana, %eax

                    movl (%edi, %eax, 4), %ebx

                    cmpl ID, %ebx
                    je contorizareDimensiuneDEFRAGMENTATION

                    decl coloana
                    jmp cautareSpatiiLibereDEFRAGMENTATION

                    contorizareDimensiuneDEFRAGMENTATION:
                        incl dimensiune
                        movl $0, (%edi, %eax, 4)
                
                    continuareAflareDimensiune:
                    incl coloana
                jmp aflareDimensiune

                cautareSpatiiLibereDEFRAGMENTATION:
                

                    movl dimensiune, %eax
                    imull transformare
                    movl %eax, dimensiune

                    pushl linie
                    pushl coloana

                    xorl %ebx, %ebx
                    movl linieDEFRAGMENTATION, %ebx
                    movl %ebx, linie

                    xorl %ebx, %ebx
                    movl coloanaDEFRAGMENTATION, %ebx
                    movl %ebx, coloana


                    call ADD

                    popl coloana
                    popl linie

            continuareParcurgereaColoanelorDEFRAGMENTATION:
                incl coloana
        jmp parcurgereColoaneDEFRAGMENTATION

        continuareParcurgereaLiniilorDEFRAGMENTATION:
        incl linie
    jmp parcurgereLiniiDEFRAGMENTATION

    iesireDinParcurgereDEFRAGMENTATION:
ret


.global main

main:
    pushl $operatii
    pushl $formatScanf
    call scanf
    pop %ebx
    pop %ebx

    lea matrice, %edi

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

        movl $5, %eax
        cmp %eax, codOperatie
        je etichetaCONCRETE

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

        xorl %eax, %eax
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

            movl $0, linie
            movl $0, coloana
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

        call SHOW

    jmp finalEtichetaFor

    etichetaDEFRAGMENTATION:
        call DEFRAGMENTATION
    jmp finalEtichetaFor


    etichetaCONCRETE:
        pushl $path
        pushl $formatPath
        call scanf 
        popl %ebx
        popl %ebx

        #dechidem directorul
        pushl $path
        movl $5, %eax
        movl $path, %ebx
        xorl %ecx, %ecx
        int $0x80
        movl %eax, directorID



        

    jmp finalEtichetaFor



    etichetaExit:
        pushl $0
        call fflush
        popl %eax

        movl $1, %eax 
        xorl %ebx, %ebx
    int $0x80
    
