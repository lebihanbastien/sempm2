 SUBROUTINE FLTR1(B,VAM,NSO)
C****************************************************************
C THE COMPLEX DIAGONAL FORM OF THE FLOQUET MATRIX, MUST CONTAIN THE
C EIGENVALUES ACCORDING TO THE ORDER OF THE CONJUGATE VARIABLES,
C IN OUR CASE SINCE THE ORDER IS X,PX,Y,PY,Z,PZ, IT MUST
C SATISFY B(2*I-1,2*I-1)+B(2*I,2*I)=0 FOR I=1,3
C THIS ROUTINE DOES A CHANGE IN THE THE DIAGONAL OF B
C IN ORDER TO FULLFIL THE ABOVE CONDITION. IT CHANGES AS WELL
C THE ORDER OF THE THIRD COUPLE ACCORDING TO NSO.
C****************************************************************
        IMPLICIT COMPLEX*16 (A-H,O-Z)
        REAL*8 TOL,XMD
C       PARAMETER (TOL=1.D-10)
        PARAMETER (TOL=1.D-8)
        DIMENSION B(6,6),VAM(6),LLOC(6),AU1(6),AU2(6)
        DO 1 I=1,6
            LLOC(I)=0
1       CONTINUE
        DO 2 I=1,5,2
            DO 3 J=1,6
                LLOC(I)=J
                DO 4 K=1,I-1
                IF (LLOC(K).EQ.J) GOTO 3
4               CONTINUE
                GOTO 5
3           CONTINUE
5           XMD=1.D10
            DO 6 J=1,6
                IF (XMD.GT.CDABS(B(J,J)+B(LLOC(I),LLOC(I)))) THEN
                LL=J
                XMD=CDABS(B(J,J)+B(LLOC(I),LLOC(I)))
                ENDIF
6           CONTINUE
            IF (XMD.GT.TOL) THEN
            WRITE (*,*) 'FLTR1. ASSOCIATED EIGENVALUE NOT FOUND'
            WRITE (*,*) '        XMD and TOL: ',XMD,TOL
            WRITE (*,*) '        VECTOR LLOC: ',LLOC
            WRITE (*,*) '        EIGENVALUES:'
            DO 10 K=1,6
                WRITE (*,*) K,B(K,K)
10          CONTINUE
            STOP
            ENDIF
            LLOC(I+1)=LL
2       CONTINUE
        DO 11 I=1,5
        DO 12 J=I+1,6
        IF (LLOC(I).EQ.LLOC(J)) THEN
        WRITE (*,*) 'FLTR1. COUPLES NOT DEFINED WITHIN TOL'
        WRITE (*,*) '        VECTOR LLOC: ',LLOC
        WRITE (*,*) '        EIGENVALUES:'
        DO 13 K=1,6
        WRITE (*,*) K,B(K,K)
13      CONTINUE
        STOP
        ENDIF
12      CONTINUE
11      CONTINUE
        IF (NSO.EQ.3) GOTO 150
        LL=LLOC(6)
        LLOC(6)=LLOC(2*NSO)
        LLOC(2*NSO)=LL
        LL=LLOC(5)
        LLOC(5)=LLOC(2*NSO-1)
        LLOC(2*NSO-1)=LL
        WRITE(*,*) 'FLTR1. VECTOR LLOC OF SORTING: ',LLOC
150     DO 160 I=1,6
        AU1(I)=B(I,I)
        AU2(I)=VAM(I)
160     CONTINUE
        DO 200 I=1,6
        B(I,I)=AU1(LLOC(I))
        VAM(I)=AU2(LLOC(I))
200     CONTINUE
        WRITE (*,*) 'FLTR1. NSO=',NSO
        WRITE (*,*) '        TEST OF THE COUPLES:'
        WRITE (*,*) B(1,1)+B(2,2)
        WRITE (*,*) B(3,3)+B(4,4)
        WRITE (*,*) B(5,5)+B(6,6)
        RETURN
        END




        SUBROUTINE FLTR2(VEM,NSO,IND)
C****************************************************************
C  THIS ROUTINE DOES A SECOND TEST. THE OUT OF PLANE COMPONENTS
C  (Z,PZ) ARE DECOUPLED FROM THE IN PLANE ONES X,PX,Y,PY.
C  ALL THE MANIPULATOR ASSUMES THAT THE DECOUPLED ONES ARE Z,PZ.
C  IF THE ORDER IN THE EIGENVALUES IS NOT THE RIGHT ONE, THE LAST
C  ASSUMPTION IS NOT FULLFILLED. THIS ROUTINE TESTS IF THE ORDER
C  IS A RIGHT ONE, AND IF NOT PROPOSES ANOTHER CHANGE VIA VARIABLE
C  NSO AND THE INDICATOR IND.
C****************************************************************
        IMPLICIT COMPLEX*16 (A-H,O-Z)
        REAL*8 TOL
        PARAMETER (TOL=1.D-10)
        DIMENSION VEM(6,6)
        IND=0
        DO 1 I=5,6
            DO 2 J=1,4
                IF (CDABS(VEM(I,J)).GT.TOL.OR.CDABS(VEM(J,I)).GT.TOL) IND=IND+1
2           CONTINUE
1           CONTINUE
            IF (IND.NE.0) THEN
                IF (NSO.EQ.3) THEN
                    NSO=1
                ELSE
                    IF (NSO.EQ.1) THEN
                        NSO=2
                    ELSE
                        WRITE (*,*) 'FLTR2. THE OUT OF PLANE VARIABLES SEEM TO BE'
                        WRITE (*,*) '        RELATED WITH THE IN-PLANE. THE PROGRAM'
                        WRITE (*,*) '        CAN NOT DEAL WITH THIS FACT.'
                    ENDIF
                ENDIF
            ENDIF
        RETURN
        END




        SUBROUTINE FLTR3(WS,B,VEM)
C****************************************************************
C THE EIGENVALUES OF THE FLOQUET MATRIX ARE THE (COMPLEX) LOGARITHMS
C OF THE EIGENVALUES OF THE MONODROMY MATRIX DIVIDED BY THE PERIOD
C OF THE PERTURBATION. THESE APPEAR IN COUPLES WITH ITS SUM EQUAL
C TO ZERO. IF WS IS THE FREQUENCY OF THE PERTURBATION, THE
C EIGENVALUES OF THE FLOQUET MATRIX ARE DETERMINED EXCEPT A MULTIPLE
C OF WS IN THE IMAGINARY PART.
C GIVEN THE MATRIX B, WHICH IS A DIAGONAL MATRIX CONTAINING THE
C CURRENT EIGENVALUES OF THE FLOQUET MATRIX IN ITS DIAGONAL, AND THE
C FREQUENCY OF THE PERTURBATION, THIS ROUTINE ASKS INTERACTIVELY
C THE DESIRED DETERMINATION OF ITS VALUES. THE MATRIX B IS RETURNED
C WITH THESE NEW VALUES.
C IT ALSO ASKS WHICH MEMBER OF THE COUPLE IS DESIRED IN THE DIAGONAL
C FORM. IF ANY PERMUTATION IS DESIRED, IT MODIFIES THE ORDER IN THE
C COUPLE AND THE MATRIX VEM WHICH AT THE INPUT MUST CONTAIN THE
C EIGENVALUES OF THE MONODROMY MATRIX IN THE BASIS X1,Y1,X2,Y2,X3,Y3.
C****************************************************************
        IMPLICIT COMPLEX*16 (A-H,O-Z)
        REAL*8 WS
        DIMENSION NV(3),B(6,6),VEM(6,6)
        WRITE (*,*)
        WRITE (*,*) '********* ROUTINE FLTR3 ************'
        WRITE (*,*) '     +++++ FIRST STEP +++++'
        WRITE (*,*)
        WRITE (*,*) 'THE EIGENVALUES OF THE FLOQUET MATRIX ARE THE'
        WRITE (*,*) '(COMPLEX) LOGARITHMS OF THE EIGENVALUES OF THE'
        WRITE (*,*) 'MONODROMY MATRIX DIVIDED BY THE PERIOD OF THE'
        WRITE (*,*) 'PERTURBATION. THESE APPEAR IN COUPLES WITH '
        WRITE (*,*) 'ITS SUM EQUAL TO ZERO.'
        WRITE (*,*) 'IF WS IS THE FREQUENCY OF THE PERTURBATION,'
        WRITE (*,*) 'THE EIGENVALUES OF THE FLOQUET MATRIX ARE'
        WRITE (*,*) 'DETERMINED EXCEPT A MULTIPLE OF WS IN THE '
        WRITE (*,*) 'IMAGINARY PART.'
        WRITE (*,*) 'NEXT, YOU WILL BE ASKED FOR THREE INTEGER VALUES.'
        WRITE (*,*) 'EACH INTEGER VALUE TIMES WS WILL BE ADDED TO THE'
        WRITE (*,*) 'IMAGINARY PART OF THE FIRST EIGENVALUE OF ITS'
        WRITE (*,*) 'RESPECTIVE COUPLE.'
        WRITE (*,*) 'YOU MUST ANSWER: 0 0 0 WHEN YOU WILL HAVE THE'
        WRITE (*,*) 'RIGHT DETERMINATION.'
        WRITE (*,*) 'MAY BE WITH YOUR CHOICE IT IS NOT POSSIBLE TO'
        WRITE (*,*) 'FIND A SYMPLECTIC CHANGE OR TO OBTAIN A REAL'
        WRITE (*,*) 'FLOQUET MATRIX. IN THIS CASE THE PROGRAM WILL'
        WRITE (*,*) 'STOP WHEN COMPUTING THE FLOQUET MATRIX.'
50      WRITE (*,*)
        WRITE (*,*)'THE LOGARITHMS OF THE EIGENVALUES OF THE MONODROMY'
        WRITE (*,*) 'MATRIX ARE THE FOLLOWING THREE (COMPLEX) COUPLES:'
        WRITE (*,*)
        DO 10 I=1,3
        WRITE (*,100) I,B(2*I-1,2*I-1)
        WRITE (*,101) B(2*I,2*I)
100     FORMAT (I4,3X,1H(,D23.15,1H,,D23.15,1H))
101     FORMAT (4X,3X,1H(,D23.15,1H,,D23.15,1H))
10      CONTINUE
        WRITE (*,*)
        WRITE(*,*)'CHOOSE THE APROPIATE DETERMINATION (3 INT. VALUES):'
        WRITE (*,102) WS
102     FORMAT ('(FREQUENCY OF THE PERTURBATION, WS= ',D21.15,')')
        READ (*,*) NV(1),NV(2),NV(3)
        IF (NV(1).EQ.0.AND.NV(2).EQ.0.AND.NV(3).EQ.0) GOTO 20
        DO 12 I=1,3
        B(2*I-1,2*I-1)=B(2*I-1,2*I-1)+DCMPLX(0.D0,NV(I)*WS)
        B(2*I,2*I)=B(2*I,2*I)-DCMPLX(0.D0,NV(I)*WS)
12      CONTINUE
        GOTO 50
20      WRITE (*,*)
C
C   IN THE REAL CASE THIS SECOND STEP IS NOT VERY USEFULL, BUT CAN BE
C   USED DELETING THE C's OF THE LINES.
C
C        WRITE (*,*) '     +++++ SECOND STEP +++++'
C        WRITE (*,*)
C        WRITE (*,*) 'YOU CAN CHOOSE WHICH MEMBER OF THE COUPLES'
C        WRITE (*,*) 'OF THE EIGENVALUES (ONE OR ITS OPPOSITE IN SIGN)'
C        WRITE (*,*) 'YOU PREFER IN THE DIAGONAL FORM OF THE SECOND'
C        WRITE (*,*) 'ORDER PART OF THE HAMILTONIAN.'
C        WRITE (*,*) 'NEXT, YOU WILL BE ASKED FOR AN INTEGER VALUE, I.'
C        WRITE (*,*) 'IT WILL MEAN THAT THE OTHER MEMBER OF THE COUPLE'
C        WRITE (*,*) 'NUMBER I MUST APPEAR IN THE DIAGONAL FORM.'
C        WRITE (*,*) 'GIVE 0 WHEN YOU HAVE THE DESIRED VALUES.'
C        WRITE (*,*)
C60      WRITE (*,*) 'MEMBERS OF EACH COUPLE IN THE DIAGONAL FORM:'
C        WRITE (*,*)
C        WRITE (*,100) 1,B(1,1)
C        WRITE (*,100) 2,B(3,3)
C        WRITE (*,100) 3,B(5,5)
C        WRITE (*,*)
C        WRITE(*,*)'GIVE THE ONE YOU WANT TO CHANGE. (0= IT IS OK)'
C        READ (*,*) NC
C        IF (NC.EQ.0) GOTO 500
C        IF (NC.GT.3.OR.NC.LT.0) GOTO 60
C        NC=2*NC-1
C        DO 40 I=1,6
C        VAL=VEM(I,NC)
C        VEM(I,NC)=VEM(I,NC+1)
C        VEM(I,NC+1)=VAL
C40      CONTINUE
C        VAL=B(NC,NC)
C        B(NC,NC)=B(NC+1,NC+1)
C        B(NC+1,NC+1)=VAL
C        GOTO 60
C500     WRITE (*,*)
        WRITE (*,*) '********** EXIT FLTR3 *************'
        RETURN
        END
