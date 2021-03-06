      SUBROUTINE FA1        
C        
C     FA1 IS THE DRIVER FOR PART ONE OF FLUTTER ANALYSIS        
C        
      INTEGER         SYSBUF,OUT,BUFF,BUFF1,NS(2),FLOOP,TSTART,        
     1                KHH,BHH,MHH,QHHL,CASECC,FLIST,FSAVE,KXHH,MXHH,    
     2                BXHH,SCR1,REC0(8),FLUT(10),IMETH(2),FMETHD,SMETH, 
     3                TRL(10),AERO(2),FLFACT(2),FLUTER(2),        
     4                SR,SM,SK,PR,PM,PK,SL,IBLOCK(12),METHOD(4)        
      REAL            BLOCK(12),REC(8),KFREQ,RHO        
      DIMENSION       DLT(3),Z(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,OUT        
      COMMON /BLANK / FLOOP,TSTART,ICEAD        
      COMMON /OUTPUT/ HDG(96)        
      COMMON /PACKX / ITI,ITO,IJ,NN,INCR1        
CZZ   COMMON /ZZFA1X/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /UNPAKX/ IOUT,II,JJ,INCR        
      EQUIVALENCE     (REC0(1),REC(1))        
      EQUIVALENCE     (BLOCK(1),IBLOCK(1))        
      EQUIVALENCE     (IZ(1),Z(1))        
      DATA  KHH /101/,   BHH /102/,  MHH /103/, QHHL /104/, CASECC /105/
     1,   FLIST /106/, FSAVE /201/, KXHH /202/, BXHH /203/,   MXHH /204/
      DATA  SCR1/301/,    NS /4HFA1 ,4H    /        
      DATA  IMETH   /  4HS   ,4HL   /        
      DATA  NMD /4  /, METHOD/4HK   ,4HKE  ,4HPK  ,4HINV /        
      DATA  TRL     /  90,1006,7*0,6 /        
      DATA  AERO    /  3202,32 /,   FLFACT /4102,41/,   FLUTER /3902,39/
C        
      DO 5 I = 1,12        
    5 IBLOCK(I) = 0        
      NCORE = KORSZ(IZ)        
      BUFF  = NCORE - SYSBUF - 1        
      BUFF1 = BUFF  - SYSBUF        
      IF (FLOOP .NE. 0) GO TO 200        
C        
C     FIRST TIME THROUGH FIND FMETHOD ON CASECC        
C        
      IFILE = CASECC        
      CALL GOPEN (CASECC,IZ(BUFF+1),0)        
      CALL READ (*530,*10,CASECC,IZ,BUFF,1,NWR)        
   10 LCC = NWR        
      CALL CLOSE (CASECC,1)        
C        
C     GET DATA FOR REC0 OF FSAVE        
C        
      CALL FNAME (FSAVE,REC0)        
      IFILE = FLIST        
      CALL PRELOC (*480,IZ(BUFF+1),FLIST)        
      CALL LOCATE (*470,IZ(BUFF+1),AERO,IDUM)        
      CALL READ (*530,*530,FLIST,REC0(4),4,1,NWR)        
C     BREF = REFC*0.5        
      REC(6) = REC(6)*0.5        
      CALL LOCATE (*15,IZ(BUFF+1),FLFACT,IDUM)        
      CALL READ (*530,*20,FLIST,IZ(LCC+1),BUFF,1,NWR)        
      GO TO 400        
   15 NWR = 0        
   20 LFL = NWR + LCC        
      CALL LOCATE (*450,IZ(BUFF+1),FLUTER,IDUM)        
   30 CALL READ (*530,*450,FLIST,FLUT,10,0,NWR)        
      I165 = 165        
      IF (FLUT(1) .NE. IZ(I165)) GO TO 30        
      CALL CLOSE (FLIST,1)        
      REC0(8) = FLUT(9)        
      IEP = FLUT(10)        
      DO 40 I = 1,NMD        
      IF (FLUT(2) .EQ. METHOD(I)) GO TO 50        
   40 CONTINUE        
      GO TO 490        
   50 REC0(3) = I        
      FMETHD = I        
      GO TO (60,60,61,490), I        
   60 REC0(4) = 0        
      IF (FLUT(7) .EQ. IMETH(1)) REC0(4) = 1        
      IF (FLUT(7) .EQ. IMETH(2)) REC0(4) = 2        
      IF (REC0(4) .EQ. 0) GO TO 430        
      SMETH = REC0(4)        
      GO TO 65        
C        
C     PK METHOD HAS LINEAR SPLINE ONLY        
C        
   61 REC0(4) = 2        
      SMETH = 2        
   65 CONTINUE        
C        
C     BUILD RECORDS 0,1,2,3 OF SAVE        
C        
      IFILE = FSAVE        
      CALL OPEN (*480,FSAVE,IZ(BUFF+1),1)        
      CALL WRITE (FSAVE,REC0,8,1)        
      BREF = REC(6)        
      RREF = REC(7)        
      NEIW = REC0(8)        
C        
C     BUILD M,K,RHO LIST FOR FLUTTER LOOP        
C        
      SR = 0        
      SM = 0        
      SK = 0        
      I  = LCC        
      IF (I .EQ. LFL) GO TO 410        
   70 I  = I + 1        
      IF (IZ(I) .EQ. FLUT(4)) SR = I        
      IF (IZ(I) .EQ. FLUT(5)) SM = I        
      IF (IZ(I) .EQ. FLUT(6)) SK = I        
   80 I = I + 1        
      IF (I .GE. LFL) GO TO 90        
      IF (IZ(I) .EQ. -1) GO TO 70        
      GO TO 80        
   90 IF (SR.EQ.0 .OR. SM.EQ.0 .OR. SK.EQ.0) GO TO 410        
      NRHO = 0        
      PR = SR        
   95 PR = PR + 1        
      IF (IZ(PR) .EQ. -1) GO TO 97        
      NRHO = NRHO + 1        
      GO TO 95        
   97 NLOOPS = 0        
      IF (FMETHD .NE. 3) GO TO 105        
C        
C     J.PETKAS/LOCKHEED      3/91        
C     19 LINES OF OLD CODE FOR BUILDING ELEMENTS OF FSAVE FOR PK METHOD 
C     WERE IN ERROR, AND ARE NOW REPLACED BY NEXT 29 NEW LINES        
C        
      PM = SM        
  101 PM = PM + 1        
      IF (IZ(PM) .EQ. -1) GO TO 130        
      DLT(1) = Z(PM)        
C        
C     CENTER LOOP ON RHO        
C        
      PR = SR        
  102 PR = PR + 1        
      IF (IZ(PR) .EQ. -1) GO TO 101        
      DLT(3) = Z(PR)        
C        
C     INNER LOOP ON VELOCITY        
C        
      PK = SK        
  103 PK = PK + 1        
      IF (IZ(PK) .EQ. -1) GO TO 102        
      DLT(2) = Z(PK)        
      NLOOPS = NLOOPS + 1        
      CALL WRITE (FSAVE,DLT,3,0)        
      GO TO 103        
C        
C     ALGORITHM FOR BUILDING ELEMENTS OF FSAVE FOR K AND KE METHODS     
C        
  105 CONTINUE        
C        
C     OUTER LOOP ON MACH NUMBER        
C        
      PM = SM        
  107 PM = PM + 1        
      IF (IZ(PM) .EQ. -1) GO TO 130        
      DLT(1) = Z(PM)        
C        
C     CENTER LOOP ON KFREQ        
C        
      PK = SK        
  110 PK = PK + 1        
      IF (IZ(PK) .EQ. -1) GO TO 107        
      DLT(2) = Z(PK)        
C        
C     INNER LOOP ON RHO        
C        
      PR = SR        
  120 PR = PR + 1        
      IF (IZ(PR) .EQ. -1) GO TO 110        
      DLT(3) = Z(PR)        
      NLOOPS = NLOOPS + 1        
      CALL WRITE (FSAVE,DLT,3,0)        
      GO TO 120        
  130 CALL WRITE (FSAVE,0,0,1)        
C        
C     PICK UP M AND K FROM QHHL        
C        
      IFILE = QHHL        
      CALL OPEN (*480,QHHL,IZ(BUFF1+1),0)        
      CALL READ (*530,*140,QHHL,IZ(LCC+1),BUFF1,1,NWR)        
      GO TO 400        
  140 LFL = NWR + LCC        
      SL  = LCC + 5        
      CALL CLOSE (QHHL,1)        
      REC0(1) = QHHL        
      CALL RDTRL (REC0)        
      NP  = MIN0(IZ(SL-1),REC0(2)/REC0(3))        
      LFL = MIN0(LFL,2*NP+SL-1)        
      NP  = LFL - SL + 1        
      CALL WRITE (FSAVE,IZ(SL),NP,1)        
      NP  = NP/2        
C        
C     WRITE CASECC RECORD AND TRAILER        
C        
      CALL WRITE (FSAVE,IZ(1),LCC,1)        
      CALL CLOSE (FSAVE,1)        
      REC0(1) = FSAVE        
      REC0(2) = FLOOP        
      REC0(3) = NLOOPS        
      REC0(4) = NP        
      REC0(5) = LCC        
      REC0(6) = 0        
      REC0(7) = NRHO        
      CALL WRTTRL (REC0)        
      GO TO 210        
  200 IFILE = FSAVE        
      CALL OPEN (*480,FSAVE,IZ(BUFF+1),0)        
      CALL READ (*530,*530,FSAVE,IZ(1),8,1,NWR)        
      CALL CLOSE (FSAVE,1)        
      IZX   = 0        
      FMETHD= IZ(IZX+3)        
      SMETH = IZ(IZX+4)        
      BREF  =  Z(IZX+6)        
      RREF  =  Z(IZX+7)        
      NEIW  = IZ(IZX+8)        
  210 REC0(1) = FSAVE        
      CALL RDTRL (REC0)        
C        
C     START OF LOOPING BUMP LOOP COUNTER SET TIME AND GO        
C        
      FLOOP = FLOOP + 1        
      NLOOPS= REC0(3)        
      CALL KLOCK (TSTART)        
      GO TO (220,230,240,490), FMETHD        
C        
C     K METHOD BUILD PROPER QHH ON SCR1        
C        
  220 CALL FA1K (SMETH,KFREQ,RHO,SCR1,0)        
      GO TO 300        
C        
C     KE METHOD DO INCORE EIGNVALUE EXTRACTION        
C        
  230 REC0(1) = BHH        
      CALL RDTRL (REC0)        
      IF (REC0(1).GT.0 .AND. REC0(7).GT.0) GO TO 510        
      REC0(1) = KHH        
      CALL RDTRL (REC0)        
      ICO = REC0(2)*REC0(2)*4 + 4        
  235 CALL FA1K (SMETH,KFREQ,RHO,SCR1,ICO)        
      CALL FA1KE (SCR1,KFREQ,BREF,RHO,RREF,FLOOP,NLOOPS)        
      IF (FLOOP .GE. NLOOPS) GO TO 350        
      FLOOP = FLOOP + 1        
      GO TO 235        
C        
C     PK METHOD  LINEAR INTERPOLATION  AND INCORE LOOP FOR        
C     EIGENVALUE CONVERGENCE        
C        
  240 CALL FA1PKI (FSAVE,QHHL)        
      CALL FA1PKE (KHH,BHH,MHH,BXHH,FSAVE,NLOOPS,BREF,RREF,NEIW,IEP)    
      IF (FLOOP .GE. NLOOPS) GO TO 250        
      FLOOP = FLOOP  + 1        
      GO TO 240        
C        
C     PHID  - KXHH   CLAMAD - BXHH        
C        
  250 IBUF = BUFF1 - SYSBUF        
      TRL(1) = SCR1        
      CALL RDTRL (TRL)        
      IF (TRL(2) .EQ. 0) GO TO 350        
      CALL OPEN (*350,SCR1,Z(IBUF),0)        
      CALL READ (*290,*255,SCR1,REC,6,1,NWR)        
  255 CALL READ (*290,*260,SCR1,Z,IBUF,1,NWR)        
  260 NN = NWR/2        
      CALL GOPEN (KXHH,Z(BUFF),1)        
      CALL GOPEN (BXHH,Z(BUFF1),1)        
      CALL WRITE (BXHH,TRL(1),50,0)        
      CALL WRITE (BXHH,HDG,96,1)        
      TRL(1) = KXHH        
      TRL(2) = 0        
      TRL(3) = NN        
      TRL(4) = 2        
      TRL(5) = 3        
      ITI = 3        
      ITO = 3        
      IJ  = 1        
      INCR1 = 1        
  265 CALL WRITE (BXHH,REC,6,0)        
      CALL PACK  (Z,KXHH,TRL)        
      CALL READ  (*280,*270,SCR1,REC,6,1,NWR)        
  270 CALL READ  (*280,*265,SCR1,Z,IBUF,1,NWR)        
  280 CALL WRITE (BXHH,0,0,1)        
      CALL CLOSE (BXHH,1)        
      CALL CLOSE (KXHH,1)        
      CALL WRTTRL (TRL)        
      TRL(1) = BXHH        
      TRL(2) = 1006        
      TRL(7) = 0        
      CALL WRTTRL (TRL)        
  290 CALL CLOSE (SCR1,1)        
      GO TO 350        
C        
C     COPY KHH TO KXHH        
C        
  300 CALL GOPEN (KHH,IZ(BUFF+1),0)        
      CALL GOPEN (KXHH,IZ(BUFF1+1),1)        
      REC0(1) = KHH        
      CALL RDTRL (REC0)        
      REC0(1) = KXHH        
      IOUT = REC0(5)        
      INCR = 1        
      I = REC0(2)        
      REC0(2) = 0        
      REC0(6) = 0        
      REC0(7) = 0        
      CALL CYCT2B (KHH,KXHH,I,Z,REC0)        
      CALL CLOSE  (KHH,1)        
      CALL CLOSE  (KXHH,1)        
      CALL WRTTRL (REC0)        
C        
C     BUILD BXHH = (K/B)BHH        
C        
      REC0(1) = BHH        
      CALL RDTRL (REC0)        
      IF (REC0(1) .LE. 0) GO TO 310        
      IBLOCK(2) = 1        
      BLOCK(3) = KFREQ/BREF        
      CALL SSG2C (BHH,0,BXHH,0,BLOCK(2))        
  310 CONTINUE        
C        
C                2  2        
C     MXHH  =  (K /B ) MHH  + (RHO*RREF/2.0) QHH        
C        
      IBLOCK(2) = 1        
      BLOCK (3) = (KFREQ*KFREQ)/(BREF*BREF)        
      IBLOCK(8) = 1        
      BLOCK (9) = RHO*RREF/2.0        
      CALL SSG2C (MHH,SCR1,MXHH,0,BLOCK(2))        
C        
C     THE END        
C        
  350 CONTINUE        
      REC0(1) = FSAVE        
      CALL RDTRL (REC0)        
      REC0(2) = FLOOP        
      CALL WRTTRL (REC0)        
      IF (FLOOP .EQ. NLOOPS) FLOOP = -1        
      ICEAD = 1        
      IF (FMETHD .EQ. 2) ICEAD = -1        
      IF (FMETHD .EQ. 3) ICEAD = -1        
      GO TO 600        
C        
C     ERROR MESSAGES        
C        
  400 CALL MESAGE (-8,0,NS)        
  410 WRITE  (OUT,420) UFM,FLUT(4),FLUT(5),FLUT(6)        
  420 FORMAT (A23,', ONE OR MORE OF THE FOLLOWING FLFACT SETS WERE NOT',
     1       ' FOUND - ',3I9)        
      GO TO 540        
  430 WRITE  (OUT,440) UFM,FLUT(7)        
  440 FORMAT (A23,' 2267, INTERPOLATION METHOD ',A4,' UNKNOWN')        
      GO TO 540        
  450 I165 = 165        
      WRITE  (OUT,460) UFM,IZ(I165)        
  460 FORMAT (A23,' 2268, FMETHOD SET',I9,' NOT FOUND')        
      GO TO 540        
  470 CALL MESAGE (-7,0,NS)        
  480 CALL MESAGE (-1,IFILE,NS)        
  490 WRITE  (OUT,500) UFM,FLUT(2)        
  500 FORMAT (A23,' 2269, FLUTTER METHOD ',A4,' NOT IMPLEMENTED')       
      GO TO 540        
  510 WRITE  (OUT,520) UFM,FLUT(2)        
  520 FORMAT (A23,', FLUTTER METHOD ',A4,' NOT IMPLEMENTED WITH B ',    
     1       'MATRIX')        
      GO TO 540        
  530 CALL MESAGE (-3,IFILE,NS)        
  540 CALL MESAGE (-61,0,NS)        
C        
  600 RETURN        
      END        
