      SUBROUTINE LINEIN(X1,Y1,Z1,X2,Y2,Z2,HCDL)
C
C PERFORMS LINE INTEGRAL FROM (X1,Y1,Z1) TO (X2,Y2,Z2) OF BIOT-SAVART
C FILED DOTTED INTO THE LINE, IE INT(HC.DL)
C
      DIMENSION XI(4),W(4)
      DATA XI/.06943184,.33000948,.66999052,.93056816/                  
      DATA W/.17392742,2*.32607258,.173927423/                          
C                                                                       
C COMPONENTS OF LINE SEGMENT                                            
C                                                                       
      HCDL=0.
      SEGX=X2-X1
      SEGY=Y2-Y1
      SEGZ=Z2-Z1
      SEGL=SQRT(SEGX**2+SEGY**2+SEGZ**2)
      IF(SEGL.EQ.0.)RETURN
C
C 4 POINT INTEGRATION OVER LINE SEGMENT(XI= / TO +1)
C
      DO 10 I=1,4
      XX=X1+SEGX*XI(I)
      YY=Y1+SEGY*XI(I)
      ZZ=Z1+SEGZ*XI(I)
      CALL BIOTSV(XX,YY,ZZ,HCX,HCY,HCZ)
      HCDL=HCDL+(HCX*SEGX+HCY*SEGY+HCZ*SEGZ)*W(I)
   10 CONTINUE
      RETURN
      END
