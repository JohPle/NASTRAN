      SUBROUTINE XSAVE        
C     THE PURPOSE OF THIS ROUTINE IS TO PERFORM THE FUNCTIONS ASSIGNED  
C     TO THE SAVE DMAP INSTRUCTION.        
C        
      COMMON/XVPS/ IVPS(1)        
      COMMON/BLANK/ IPAR(1)        
      COMMON /OSCENT/ IOSCR(7)        
C     GET NUMBER OF PARAMETERS FROM OSCAR        
      N = IOSCR(7)*2 + 6        
      DO 20 I1 = 8,N,2        
C     GET VPS POINTER AND POINTER TO VALUE IN BLANK COMMON.        
      J = IOSCR(I1)        
      K = IOSCR(I1+1)        
C     GET LENGTH OF VALUE FROM VPS        
      L = IVPS(J-1)        
C     TRANSFER VALUE FROM BLANK COMMON TO VPS        
      DO 10 I2 = 1,L        
      IVPS(J) = IPAR(K)        
      J = J + 1        
   10 K = K + 1        
   20 CONTINUE        
      RETURN        
      END        
