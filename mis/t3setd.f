      SUBROUTINE T3SETD (IERR,SIL,JGPDT,ELTH,GPTH,DGPTH,EGPDT,GPNORM,   
     1           EPNORM,IORDER,TEB,TUB,CENT,AVGTHK,LX,LY,EDGLEN,ELID)   
C        
C     DOUBLE PRECISION ROUTINE TO DO THE SET-UP FOR TRIA3 ELEMENTS      
C        
C        
C     INPUT :        
C           SIL    - ARRAY OF SIL NUMBERS        
C           JGPDT  - BGPDT DATA (INTEGER ARRAY)        
C           ELTH   - ELEMENT THICKNESS FROM EPT        
C           GPTH   - GRID POINT THICKNESS DATA        
C           ELID   - ELEMENT ID        
C     OUTPUT:        
C           IERR   - ERROR FLAG        
C           SIL    - ARRAY OF SIL NUMBERS       (REARRANGED)        
C           JGPDT  - BGPDT DATA (INTEGER ARRAY) (REARRANGED)        
C           GPTH   - GRID POINT THICKNESS DATA  (REARRANGED)        
C           DGPTH  - GRID POINT THICKNESS DATA  (HIGH PREC)        
C           EGPDT  - BGPDT DATA IN ELEMENT COORD. SYSTEM        
C           GPNORM - GRID POINT NORMALS        
C           EPNORM - GRID POINT NORMALS IN ELEMENT COORD .SYSTEM        
C           IORDER - ARRAY OF ORDER INDICATORS FOR REARRANGED DATA      
C           TEB    - TRANSFORMATION FROM ELEMENT TO BASIC COORD. SYSTEM 
C           TUB    - TRANSFORMATION FROM USER TO BASIC COORD. SYSTEM    
C           CENT   - LOCATION OF THE CENTER OF THE ELEMENT        
C           AVGTHK - AVERAGE THICKNESS OF THE ELEMENT        
C           LX     - DIMENSION OF ELEMENT ALONG X-AXIS        
C           LY     - DIMENSION OF ELEMENT ALONG Y-AXIS        
C           EDGLEN - EDGE LENGTHS        
C        
C        
      INTEGER          IGPDT(4,3),JGPDT(4,3),IGRID(4,3),SIL(3),        
     1                 IORDER(3),KSIL(3),ELID        
      REAL             BGPDT(4,3),GPTH(3),TMPTHK(3)        
      DOUBLE PRECISION CENT(3),EGPDT(4,3),GGU(9),TEB(9),TUB(9),CC,      
     1                 DGPTH(3),GPNORM(4,3),EPNORM(4,3),AVGTHK,LX,LY,   
     2                 AREA2,LENGTH,SMALL,X(3),Y(3),Z(3),EDG12(3),      
     3                 EDG23(3),EDG13(3),EDGLEN(3),AXIS(3,3)        
      EQUIVALENCE      (IGPDT(1,1),BGPDT(1,1))        
C        
C        
C     INITIALIZE        
C        
      IERR  = 0        
      NNODE = 3        
C        
      DO 100 I = 1,NNODE        
      DO 100 J = 1,4        
      IGPDT(J,I) = JGPDT(J,I)        
  100 CONTINUE        
C        
C     SET UP THE USER COORDINATE SYSTEM        
C        
      DO 120 I = 1,3        
      II = (I-1)*3        
      DO 120 J = 1,3        
      GGU(II+J) = DBLE(BGPDT(J+1,I))        
  120 CONTINUE        
      CALL BETRND (TUB,GGU,0,ELID)        
C        
C     SET UP THE ELEMENT COORDINATE SYSTEM        
C        
C     1. SET UP THE EDGE VECTORS AND THEIR LENGTHS        
C        
      DO 140 I = 1,NNODE        
      X(I) = BGPDT(2,I)        
      Y(I) = BGPDT(3,I)        
      Z(I) = BGPDT(4,I)        
  140 CONTINUE        
C        
      CENT(1) = (X(1)+X(2)+X(3))/3.0D0        
      CENT(2) = (Y(1)+Y(2)+Y(3))/3.0D0        
      CENT(3) = (Z(1)+Z(2)+Z(3))/3.0D0        
C        
      EDG12(1) = X(2) - X(1)        
      EDG12(2) = Y(2) - Y(1)        
      EDG12(3) = Z(2) - Z(1)        
      EDGLEN(1)= EDG12(1)**2 + EDG12(2)**2 + EDG12(3)**2        
      IF (EDGLEN(1) .EQ. 0.0D0) GO TO 380        
      EDGLEN(1) = DSQRT(EDGLEN(1))        
C        
      EDG23(1) = X(3) - X(2)        
      EDG23(2) = Y(3) - Y(2)        
      EDG23(3) = Z(3) - Z(2)        
      EDGLEN(2)= EDG23(1)**2 + EDG23(2)**2 + EDG23(3)**2        
      IF (EDGLEN(2) .EQ. 0.0D0) GO TO 380        
      EDGLEN(2) = DSQRT(EDGLEN(2))        
C        
      EDG13(1) = X(3) - X(1)        
      EDG13(2) = Y(3) - Y(1)        
      EDG13(3) = Z(3) - Z(1)        
      EDGLEN(3)= EDG13(1)**2 + EDG13(2)**2 + EDG13(3)**2        
      IF (EDGLEN(3) .EQ. 0.0D0) GO TO 380        
      EDGLEN(3) = DSQRT(EDGLEN(3))        
C        
C     2. FIND THE SMALLEST EDGE LENGTH        
C        
      SMALL = EDGLEN(1)        
      NODEI = 3        
      NODEJ = 1        
      NODEK = 2        
C        
      IF (EDGLEN(2) .GE. SMALL) GO TO 160        
      SMALL = EDGLEN(2)        
      NODEI = 1        
      NODEJ = 2        
      NODEK = 3        
  160 IF (EDGLEN(3) .GE. SMALL) GO TO 180        
      SMALL = EDGLEN(3)        
      NODEI = 2        
      NODEJ = 1        
      NODEK = 3        
C        
C     3. ESTABLISH AXIS 3 AND NORMALIZE IT        
C        
  180 CALL DAXB (EDG12,EDG13,AXIS(1,3))        
C        
      LENGTH = DSQRT(AXIS(1,3)**2 + AXIS(2,3)**2 + AXIS(3,3)**2)        
      AXIS(1,3) = AXIS(1,3)/LENGTH        
      AXIS(2,3) = AXIS(2,3)/LENGTH        
      AXIS(3,3) = AXIS(3,3)/LENGTH        
      AREA2     = LENGTH        
C        
C     4. ESTABLISH AXES 1 AND 2 AND NORMALIZE THEM        
C        
      AXIS(1,1) = (X(NODEJ)+X(NODEK))/2.0D0 - X(NODEI)        
      AXIS(2,1) = (Y(NODEJ)+Y(NODEK))/2.0D0 - Y(NODEI)        
      AXIS(3,1) = (Z(NODEJ)+Z(NODEK))/2.0D0 - Z(NODEI)        
C        
      LENGTH = DSQRT(AXIS(1,1)**2 + AXIS(2,1)**2 + AXIS(3,1)**2)        
      AXIS(1,1) = AXIS(1,1)/LENGTH        
      AXIS(2,1) = AXIS(2,1)/LENGTH        
      AXIS(3,1) = AXIS(3,1)/LENGTH        
C        
      CALL DAXB (AXIS(1,3),AXIS(1,1),AXIS(1,2))        
C        
      DO 200 I = 1,3        
      TEB(I  ) = AXIS(I,1)        
      TEB(I+3) = AXIS(I,2)        
      TEB(I+6) = AXIS(I,3)        
  200 CONTINUE        
C        
C     LX = MAX(EDGLEN(1),EDGLEN(2),EDGLEN(3))        
      LX = LENGTH        
      LY = AREA2/LX        
C        
C        
C     THE ELEMENT COORDINATE SYSTEM IS NOW READY        
C        
C     THE ARRAY IORDER STORES THE ELEMENT NODE ID IN INCREASING SIL     
C     ORDER.        
C        
C     IORDER(1) = NODE WITH LOWEST  SIL NUMBER        
C     IORDER(3) = NODE WITH HIGHEST SIL NUMBER        
C        
C     ELEMENT NODE NUMBER IS THE INTEGER FROM THE NODE LIST  G1,G2,.... 
C     THAT IS, THE 'I' PART OF THE 'GI' AS THEY ARE LISTED ON THE       
C     CONNECTION BULK DATA CARD DESCRIPTION.        
C        
      DO 220 I = 1,NNODE        
      KSIL(I) = SIL(I)        
  220 CONTINUE        
C        
      DO 260 I = 1,NNODE        
      ITEMP = 1        
      ISIL = KSIL(1)        
      DO 240 J = 2,NNODE        
      IF (ISIL .LE. KSIL(J)) GO TO 240        
      ITEMP = J        
      ISIL = KSIL(J)        
  240 CONTINUE        
      IORDER(I) = ITEMP        
      KSIL(ITEMP) = 99999999        
  260 CONTINUE        
C        
C     USE THE POINTERS IN IORDER TO COMPLETELY REORDER THE GEOMETRY DATA
C     INTO INCREASING SIL ORDER.        
C        
      DO 280 I = 1,NNODE        
      KSIL(I) = SIL(I)        
      TMPTHK(I) = GPTH(I)        
      DO 280 J = 1,4        
      IGRID(J,I) = IGPDT(J,I)        
  280 CONTINUE        
      DO 300 I = 1,NNODE        
      IPOINT = IORDER(I)        
      SIL(I) = KSIL(IPOINT)        
      GPTH(I)= TMPTHK(IPOINT)        
      DO 300 J = 1,4        
      IGPDT(J,I) = IGRID(J,IPOINT)        
      JGPDT(J,I) = IGPDT(J,I)        
  300 CONTINUE        
C        
C     THE COORDINATES OF THE ELEMENT GRID POINTS MUST BE TRANSFORMED    
C     FROM THE BASIC COORD. SYSTEM TO THE ELEMENT COORD. SYSTEM        
C        
      DO 320 I = 1,3        
      IP = (I-1)*3        
      DO 320 J = 1,NNODE        
      EGPDT(I+1,J) = 0.0D0        
      DO 320 K = 1,3        
      CC = DBLE(BGPDT((K+1),J)) - CENT(K)        
      EGPDT(I+1,J) = EGPDT(I+1,J) + TEB(IP+K)*CC        
  320 CONTINUE        
C        
C     SET NODAL NORMALS        
C        
      DO 340 I = 1,NNODE        
      EPNORM(1,I) = 0.0D0        
      EPNORM(2,I) = 0.0D0        
      EPNORM(3,I) = 0.0D0        
      EPNORM(4,I) = 1.0D0        
      GPNORM(1,I) = 0.0D0        
      GPNORM(2,I) = TEB(7)        
      GPNORM(3,I) = TEB(8)        
      GPNORM(4,I) = TEB(9)        
  340 CONTINUE        
C        
C     SET NODAL THICKNESSES        
C        
      AVGTHK = 0.0D0        
      DO 370 I = 1,NNODE        
      IF (GPTH(I)) 380,350,360        
  350 IF (ELTH .LE. 0) GO TO 380        
      GPTH(I) = ELTH        
  360 DGPTH(I) = DBLE(GPTH(I))        
      AVGTHK = AVGTHK + DGPTH(I)/NNODE        
  370 CONTINUE        
      GO TO 400        
C        
  380 IERR = 1        
  400 RETURN        
      END        
