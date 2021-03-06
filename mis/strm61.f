      SUBROUTINE STRM61
C
C
C   PHASE I OF  STRESS DATA RECOVERY FOR TRIANGULAR MEMBRANE ELEMENT TRI
C
C   OUTPUTS FROM THIS PHASE FOR USE IN PHASE II ARE THE FOLLOWING
C
C   1) ELEMENT ID             WORDS    1    STORAGE IN PH1OUT   1
C   2) SIX SILS               WORDS    6                        2-7
C   3) THICKNESS T1           WORDS    1                        8
C   4) THICKNESS T2           WORDS    1                        9
C   5) THICKNESS T3           WORDS    1                       10
C   6) REFERENCE TEMP T0      WORDS    1                       11
C   7) S SUB I MATRICES       WORDS    216                     12-227
C   8) THERMAL VECTOR G ALF   WORDS    3                      228-230
C
C    EST ENTRIES SAME AS IN SUBROUTINE KTRM6S
C
C
      REAL NSM,IVECT,JVECT,KVECT
C
      DIMENSION IEST(45),IND(6,3),EE1(6),NPH1OU(990),XC(6),YC(6),ZC(6)
     1,   Q(6,6),QQ(36),IVECT(3),JVECT(3),KVECT(3),E( 6 ),EPH1(6)
     2,   NAME(2),ICS(6),NL(6),TRANS(9),BALOTR(9),EMOD(9),TM(3,12)
     3,   TMM(36)
C
      COMMON /SDR2X5/ EST(100),PH1OUT(250)
      COMMON /MATIN / MATID,MATFLG,ELTEMP,PLA34,SINTH,COSTH
      COMMON /MATOUT/ EM(6),RHOY,ALF(3),TREF,GSUBE,SIGTY,SIGCY,SIGSY
C
      EQUIVALENCE (NPH1OU(1),PH1OUT(1)),(IEST(1),EST(1))
      EQUIVALENCE (TM(1,1),TMM(1))
C
      DATA NAME /4HSTRM,4H61  / , BLANK  /4H    /                       
      DATA DEGRA /0.0174532925/                                         
C                                                                       
      IDELE=IEST(1)
      DO 109 I=1,6
      NL(I)=IEST(I+1)
  109 CONTINUE
      THETAM=EST(8)
      MATID1=IEST(9)
      TMEM1 =EST(10)
      TMEM3 =EST(11)
      TMEM5 =EST(12)
C
C   IF TMEM3 OR TMEM5 IS 0.0 OR BLANK , IT WILL BE SET EQUAL TO TMEM1
C
      IF (TMEM3.EQ.0.0. OR .TMEM3.EQ.BLANK)  TMEM3 = TMEM1
C
      IF (TMEM5.EQ.0.0. OR .TMEM5.EQ.BLANK)  TMEM5 = TMEM1
C
      NSM = EST(13)
C
      J=0
      DO 120 I=14,34,4
      J=J+1
      ICS(J)=IEST(I)
      XC(J) = EST(I+1)
      YC(J) = EST(I+2)
      ZC(J)=EST(I+3)
  120 CONTINUE
      ELTEMP=(EST(38)+EST(39)+EST(40)+EST(41)+EST(42)+EST(43))/6.0
      THETA1=THETAM*DEGRA
      SINTH=SIN(THETA1)
      COSTH=COS(THETA1)
      IF (ABS(SINTH).LE.1.0E-06) SINTH=0.0
C
C
C   EVALUATE MATERIAL PROPERTIES
C
      MATFLG = 2
      MATID  = MATID1
      CALL MAT (IDELE)
      TO=TREF
C
C   CALCULATIONS FOR THE TRIANGLE
C
      CALL TRIF (XC,YC,ZC,IVECT,JVECT,KVECT,DISTA,DISTB,DISTC,IEST(1),
     1           NAME)
C
C   TRANSFORMATION MATRIX BETWEEN ELEMENT AND BASIC CO-ORDINATES
C
      E(1)=IVECT(1)
      E(2)=JVECT(1)
      E(3)=IVECT(2)
      E(4)=JVECT(2)
      E(5)=IVECT(3)
      E(6)=JVECT(3)
C
C   CALCULATIONS FOR  Q MATRIX AND ITS INVERSE
C
      DO 110 I=1,6
      DO 110 J=1,6
      Q(I,J)=0.0
  110 CONTINUE
      DO 115 I=1,6
      Q(I,1)=1.0
      Q(I,2)=XC(I)
      Q(I,3)=YC(I)
      Q(I,4)=XC(I)*XC(I)
      Q(I,5)=XC(I)*YC(I)
      Q(I,6)=YC(I)*YC(I)
  115 CONTINUE
C
C     FIND INVERSE OF Q  MATRIX
C
C     NO NEED TO COMPUTE DETERMINANT SINCE IT IS NOT USED SUBSEQUENTLY.
      ISING = -1
      CALL INVERS (6,Q,6,QQ(1),0,DETERM,ISING,IND)
C
C   ISING EQUAL TO 2 IMPLIES THAT Q MATRIX IS SINGULAR
C
      DO 152 I=1,6
      DO 152 J=1,6
      IJ=(I-1)*6+J
      QQ(IJ)=Q(I,J)
  152 CONTINUE
      DO 154 I=1,9
      BALOTR(I)=0.0
  154 CONTINUE
C
      DO 102 I=1,7
      PH1OUT(I)=EST(I)
  102 CONTINUE
      PH1OUT(8)=EST(10)
      PH1OUT(9)=EST(11)
      PH1OUT(10)=EST(12)
      PH1OUT(11)=TO
      EMOD(1)=EM(1)
      EMOD(2)=EM(2)
      EMOD(3)=EM(3)
      EMOD(4)=EM(2)
      EMOD(5)=EM(4)
      EMOD(6)=EM(5)
      EMOD(7)=EM(3)
      EMOD(8)=EM(5)
      EMOD(9)=EM(6)
C
C   STRESSES AND STRAINS ARE EVALUATED AT FOUR POINTS ,VIZ., THE THREE
C   CORNER GRID POINTS AND THE CENTROID
C
      DO 700 JJ=1,4
      J=2*(JJ-1)+1
      IF (J.EQ.7) GO TO 103
      X=XC(J)
      Y=YC(J)
      GO TO 104
  103 X=(XC(1)+XC(3)+XC(5))/3.0
      Y=(YC(1)+YC(3)+YC(5))/3.0
  104 CONTINUE
      DO 105 I=1,36
      TMM(I)=0.0E0
  105 CONTINUE
C
C   TM MATRIX IS THE PRODUCT OF B AND QINVERSE MATRICES
C
      DO 258 J=1,6
      J1=(J-1)*2+1
      J2=J1+1
      TM(1,J1)=Q(2,J)+2.0*X*Q(4,J)+Y*Q(5,J)
      TM(2,J2)=Q(3,J)+X*Q(5,J)+2.0*Y*Q(6,J)
      TM(3,J1)=TM(2,J2)
      TM(3,J2)=TM(1,J1)
  258 CONTINUE
      DO 600 II=1,6
      IF (ICS(II).EQ.0) GO TO 130
      CALL TRANSS (IEST(4*II+10),TRANS)
      CALL GMMATS (E,3,2,+1,TRANS,3,3,0,EE1)
      GO TO 133
  130 CONTINUE
      DO 132 I=1,3
      DO 132 J=1,2
      I1=(I-1)*2+J
      J1=(J-1)*3+I
      EE1(J1)=E(I1)
  132 CONTINUE
  133 CONTINUE
      IJ1=(JJ-1)*54+(II-1)*9+12
      MZ=(II-1)*6+1
      CALL GMMATS (EMOD,3,3,0,TMM(MZ),2,3,+1,EPH1)
      CALL GMMATS (EPH1,3,2,0,EE1,2,3,0,PH1OUT(IJ1))
  600 CONTINUE
  700 CONTINUE
      CALL GMMATS (EMOD,3,3,0,ALF,3,1,0,PH1OUT(228))
      RETURN
      END
