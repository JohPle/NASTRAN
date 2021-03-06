      SUBROUTINE BDAT05        
C        
C     THIS SUBROUTINE PROCESSES THE GNEW BULK DATA        
C        
      LOGICAL         TDAT        
      INTEGER         SCR2,BUF3,SCBDAT,BUF2,BUF1,GNEW(2),FLAG,GEOM4,    
     1                CONSET,AAA(2),Z,OUTT,SCORE        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /CMB001/ SCR1,SCR2,SCBDAT,SCSFIL,SCCONN,SCMCON,        
     1                SCTOC,GEOM4,CASECC        
      COMMON /CMB002/ BUF1,BUF2,BUF3,BUF4,BUF5,SCORE,LCORE,INPT,OUTT    
      COMMON /CMB003/ COMBO(7,5),CONSET,IAUTO,TOLER,NPSUB        
      COMMON /CMB004/ TDAT(6)        
      COMMON /BLANK / STEP,IDRY        
      DATA    GNEW  / 1410,14 / , AAA/ 4HBDAT,4H05   /        
C        
      IFILE = SCR2        
      CALL OPEN (*30,SCR2,Z(BUF3),1)        
      IFILE = GEOM4        
      CALL LOCATE (*20,Z(BUF1),GNEW,FLAG)        
      WRITE  (OUTT,10) UFM        
 10   FORMAT (A23,' 6532, THE GNEW OPTION IS NOT CURRENTLY AVAILABLE.') 
      IDRY = -2        
      RETURN        
C        
 20   CALL EOF (SCBDAT)        
      CALL CLOSE (SCR2,1)        
      RETURN        
C        
 30   IMSG = -1        
      CALL MESAGE (IMSG,IFILE,AAA)        
      RETURN        
      END        
