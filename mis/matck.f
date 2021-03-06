      SUBROUTINE MATCK (MFILE,PFILE,A,Z)        
C        
C     THIS ROUTINE CHECKS THE UNIQUENESS OF MATERIAL ID'S FOR        
C          1. MAT1 (1)     8. MATT1  (MB)  15. MATS1  (MC)        
C          2. MAT2         9. MATT2        16. MATPZ1 (MD)        
C          3. MAT3        10. MATT3        17. MTTPZ1        
C          4. MAT4        11. MATT4        18. MATPZ2        
C          5. MAT5        12. MATT5        19. MTTPZ2 (ME)        
C          6. MAT6        13. MATT6        20. DUMC        
C          7. MAT8 (MA)   14. DUMB         21. DUMD  (NMAT)        
C     AND THE MATERIAL ID SPECIFIED ON THE PROPERTY CARDS.        
C        
C     THIS ROUTINE SHOULD BE CALLED ONLY ONCE BY IFP.        
C     THIS ROUTINE DOES NOT OPEN OR CLOSE MATERIAL FILE (MFILE) OR      
C     ELEMENT PROPERTY FILE (PFILE)        
C        
C     WRITTEN BY G.CHAN/UNISYS,  OCT. 1982        
C        
      LOGICAL         ABORT        
      INTEGER         PFILE,    IH(3),    NAME(2),  Z(1),     MATI(2,22)
     1,               GROUP,    A(1),     EPTI(2,40),         MATJ(2,22)
      COMMON /SYSTEM/ N1,       NOUT,     ABORT,    SKIP(42), KDUM(9)   
      DATA    MATJ  / 103,-12,  203,-17,  1403,-16, 2103,-3,  2203,-8,  
     1               2503,-31,  603,-18,        
     2                703,-11,  803,-16,  1503,-16, 2303,-2,  2403,-7,  
     3               2603,-31,  -11,-00,        
     4                503,-11, 1603,-07,  1803,-07, 1703,-44, 1903,-44, 
     5                -11,-00,  -11,-00,   -11,-00/        
      DATA    EPTI  /  52,191, 2502,071,  7002,071, 0502,041, 2202,041, 
     1               5302,041, 0602,082,  0702,103, 0802,041, 0902,061, 
     2               1002,041, 2102,041,  7052,171, 1102,082, 1202,103, 
     3               1302,041, 7032,171,  1402,041, 1502,082, 1602,051, 
     4               1702,041, 2002,031,  0152,243, 5102,241, 5802,174, 
     5               5502,-49, 5602,-06,  5702,-06, 6102,001, 6202,001, 
     6               6302,001, 6402,001,  6502,001, 6602,001, 6702,001, 
     7               6802,001, 6902,001,     0,  0,    0,  0,    0,  0/ 
      DATA    NMAT  / 21/,      GROUP/ 7/        
      DATA    NEPT  / 37/        
      DATA    NAME  / 4HMATC,   4HK     /        
C        
C     FIRST WORDS ON THE EPTI TABLE ARE PROPERTY CARDS THAT SPECIFY     
C     MATERIAL.  THE FIRST 2 DIGITS OF THE SECOND WORD INDICATE THE     
C     NUMBER OF WORDS IN EACH PROPERTY INPUT CARD. AND THE 3RD DIGIT    
C     INDICATES NUMBER OF MATERIAL ID'S SPECIFIED.        
C     IF THIS SECOND WORD IS NEGATIVE, IT MEANS THE PROPERTY CARD IS    
C     OPEN-ENDED. THE 3RD DIGIT INDICATES WHERE MID1 BEGINS, AND        
C     REPEATING (FOR MID2, MID3,...) EVERY N WORDS WHERE N IS THE       
C     ABSOLUTE VALUE OF THE FIRST 2 DIGITS. (NO REPEAT OF N=0)        
C        
C     ARRAY A CONTAINS A LIST OF ACTIVE PROPERTY IDS - SET UP BY PIDCK  
C        
      IF (ABORT) GO TO 220        
      NOMAT = Z(1)        
      IF (NOMAT .EQ. 0) GO TO 145        
C        
C     UPDATE EPTI ARRAY IF DUMMY ELEMENT IS PRESENT        
C        
      DO 10 J = 1,9        
      IF (KDUM(J) .EQ. 0) GO TO 10        
      K = MOD(KDUM(J),1000)/10        
      EPTI(2,28+J) = K*10 + 1        
 10   CONTINUE        
C        
C     SET UP POINTERS FOR THE MATI TABLE        
C        
      MA = GROUP        
      MB = MA + 1        
      MC = MB + GROUP        
      MD = MC + 1        
      ME = MC + 4        
C        
C     READ MATERIAL ID INTO Z SPACE, AND SAVE APPROP. COUNT IN MATI(2,K)
C        
      DO 15 J = 1,NMAT        
      MATI(1,J) = MATJ(1,J)        
 15   MATI(2,J) = MATJ(2,J)        
      J = 1        
 20   CALL FWDREC (*50,MFILE)        
 25   CALL READ (*50,*50,MFILE,IH(1),3,0,KK)        
      DO 30 K = 1,NMAT        
      IF (IH(1) .EQ. MATI(1,K)) GO TO 35        
 30   CONTINUE        
      GO TO 20        
 35   NWDS =-MATI(2,K)        
      IF (NWDS .LT. 0) CALL MESAGE (-37,0,NAME)        
      MATI(2,K) = 0        
 40   CALL READ (*50,*25,MFILE,Z(J),NWDS,0,KK)        
      J = J + 1        
      MATI(2,K) = MATI(2,K) + 1        
      GO TO 40        
C        
C     INSTALL INITIAL COUNTERS IN MATI(1,K)        
C        
 50   JX = J        
      IF (JX .LE. 1) GO TO 140        
      MATI(1,1) = 0        
      DO 60 J = 1,NMAT        
      K = J + 1        
      IF (MATI(2,J) .LT. 0) MATI(2,J) = 0        
 60   MATI(1,K) = MATI(1,J) + MATI(2,J)        
C        
C     NOTE - ORIGINAL DATA IN MATI TABLE IS NOW DESTROYED        
C        
C     CHECK MATERIAL ID UNIQUENESS AMONG MAT1, MAT2,..., MAT8        
C     (MAT4 AND MAT5 ARE UNIQUE ONLY AMONG THEMSELVES)        
C        
      J = 0        
      DO 70 K = 1,MA        
      IF (MATI(2,K) .GT. 0) J = J + 1        
 70   CONTINUE        
      IF (J .LE. 1) GO TO 90        
      KK = MATI(1,MB)        
      K1 = KK - 1        
      K4 = MATI(1,4)        
      DO 80 K = 1,K1        
      J  = Z(K)        
      IB = K + 1        
      DO 75 I = IB,K1        
      IF (J .NE. Z(I)) GO TO 75        
      IF (K.LT.K4 .AND. I.GE.K4) GO TO 75        
      CALL MESAGE (30,213,J)        
      ABORT =.TRUE.        
      GO TO 80        
 75   CONTINUE        
 80   CONTINUE        
C        
C     CHECK MATT1, MATT2,..., MATT6 AND MATS1 MATERIAL ID        
C     AND THEIR CROSS REFERENCE TO MATI CARDS        
C        
 90   DO 110 K = MB,MC        
      IF (MATI(2,K) .LE. 0) GO TO 110        
      KK = MOD(K,MA)        
      IB = MATI(1,KK) + 1        
      IE = MATI(2,KK) + IB - 1        
      JB = MATI(1,K ) + 1        
      JE = MATI(2,K ) + JB - 1        
      DO 105 J = JB,JE        
      K1 = Z(J)        
      IF (IE .LT. IB) GO TO 100        
      DO 95 I = IB,IE        
      IF (Z(I) .EQ. K1) GO TO 105        
 95   CONTINUE        
 100  IH(1) = K1        
      IH(2) = KK        
      K1 = 217        
      IF (K .EQ. 15) K1 = 17        
      CALL MESAGE (30,K1,IH)        
      ABORT =.TRUE.        
 105  CONTINUE        
 110  CONTINUE        
C        
C     CHECK MATERIAL ID UNIQUENESS AMONG MATPZI AND MTTPZI        
C        
      J = 0        
      DO 115 K = MD,ME        
      IF (MATI(2,K) .GT. 0) J = J + 1        
 115  CONTINUE        
      IF (J .LE. 1) GO TO 140        
      KK = MATI(1,ME+1)        
      K1 = KK - 1        
      NN = MATI(1,MD)        
      DO 130 K = NN,K1        
      J  = Z(K)        
      IB = K + 1        
      DO 125 I = IB,KK        
      IF (J .NE. Z(I)) GO TO 125        
      CALL MESAGE (30,213,J)        
      ABORT =.TRUE.        
      GO TO 130        
 125  CONTINUE        
 130  CONTINUE        
C        
C     NOW, WE CONTINUE TO CHECK MATERIAL ID'S ON MOST PROPERTY CARDS.   
C     (MATERIAL ID'S ARE ON THE 2ND, 4TH, AND 6TH POSITIONS OF THE      
C     PROPERTY CARDS, EXECPT THE OPEN-ENDED PCOMPI GROUP)        
C        
 140  JE = MATI(1,NMAT)        
      II = A(1)        
 145  CALL FWDREC (*220,PFILE)        
 150  CALL READ (*220,*220,PFILE,IH(1),3,0,KK)        
      DO 160 K = 1,NEPT        
      IF (IH(1) .EQ. EPTI(1,K)) GO TO 170        
 160  CONTINUE        
      GO TO 145        
 170  IF (NOMAT .EQ. 0) GO TO 230        
      NWDS= EPTI(2,K)/10        
      NN  = EPTI(2,K) - NWDS*10        
      IB  = 1        
      IE  = NN*2        
      IC  = 2        
      KOMP= 0        
C        
C     CHANGE NWDS, IB, IE, AND IC IF PROPERTY CARD IS OPEN-ENDED        
C     WHERE (IB+JX) POINTS TO THE FIRST MID POSITION        
C        
      IF (EPTI(2,K) .GT. 0) GO TO 180        
      KOMP= 1        
      IB  =-NN - 1        
      IC  =-NWDS        
      IF (NWDS .EQ. 0) IC = 9999        
      NWDS= 10        
 180  IF (KOMP .EQ. 1) IE = JX + NWDS - 1        
C        
C     READ IN PROPERTY CARD. IF ID IS NOT ON ACTIVE LIST, SKIP IT.      
C     SKIP IT TOO IF IT HAS NO MATERIAL ID REQUESTED.        
C     (NO CORE SIZE CHECK HERE. SHOULD HAVE PLENTY AVAILABLE)        
C        
      CALL READ (*220,*150,PFILE,Z(JX),NWDS,0,KK)        
      IF (KOMP .EQ. 0) GO TO 182        
 181  IE = IE + 1        
      CALL READ (*220,*150,PFILE,Z(IE),1,0,KK)        
      IF (Z(IE) .NE. -1) GO TO 181        
      IE = IE - 1 - JX        
 182  DO 183 I = 2,II        
      IF (Z(JX) .EQ. A(I)) GO TO 185        
 183  CONTINUE        
      GO TO 180        
 185  DO 210 I = IB,IE,IC        
      KK = Z(JX+I)        
      IF (IE.EQ.8 .AND. I.EQ.7) KK = Z(JX+I+3)        
      IF (KK .EQ. 0) GO TO 210        
      IF (JX .LE. 1) GO TO 200        
      DO 190 J = 1,JE        
      IF (KK .EQ. Z(J)) GO TO 210        
 190  CONTINUE        
 200  IH(1) = KK        
      IH(2) = Z(JX)        
      CALL MESAGE (30,215,IH)        
      ABORT =.TRUE.        
 210  CONTINUE        
      GO TO 180        
 220  RETURN        
C        
 230  CALL MESAGE (30,16,IH)        
      ABORT =.TRUE.        
      RETURN        
      END        
