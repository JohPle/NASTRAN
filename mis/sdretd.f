      SUBROUTINE SDRETD (ELID,TI,GRIDS)        
C        
C     THIS ROUTINE (CALLED BY -SDR2E-) READS ELEMENT TEMPERATURE        
C     DATA FROM A PRE-POSITIONED RECORD        
C        
C     ELID   = ID OF ELEMENT FOR WHICH DATA IS DESIRED        
C     TI     = BUFFER DATA IS TO BE RETURNED IN        
C     GRIDS  = 0 IF EL-TEMP FORMAT DATA IS TO BE RETURNED        
C            = NO. OF GRID POINTS IF GRID POINT DATA IS TO BE RETURNED. 
C     ELTYPE = ELEMENT TYPE TO WHICH -ELID- BELONGS        
C     OLDEL  = ELEMENT TYPE CURRENTLY BEING WORKED ON (INITIALLY 0)     
C     OLDEID = ELEMENT ID FROM LAST CALL        
C     EORFLG = .TRUE. WHEN ALL DATA HAS BEEN EXHAUSTED IN RECORD        
C     ENDID  = .TRUE. WHEN ALL DATA HAS BEEN EXHAUSTED WITHIN AN ELEMENT
C              TYPE.        
C     BUFFLG = NOT USED        
C     ITEMP  = TEMPERATURE LOAD SET ID        
C     IDEFT  = NOT USED        
C     IDEFM  = NOT USED        
C     RECORD = .TRUE. IF A RECORD OF DATA IS INITIALLY AVAILABLE        
C     DEFALT = THE DEFALT TEMPERATURE VALUE OR -1 IF IT DOES NOT EXIST  
C     AVRAGE = THE AVERAGE ELEMENT TEMPERATURE        
C        
      LOGICAL         EORFLG   ,ENDID    ,BUFFLG   ,RECORD        
      INTEGER         TI(33)   ,OLDEID   ,GRIDS    ,ELID     ,ELTYPE   ,
     1                OLDEL    ,NAME(2)  ,GPTT     ,DEFALT        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ DUM      ,IOUT        
      COMMON /SDRETT/ ELTYPE   ,OLDEL    ,EORFLG   ,ENDID    ,BUFFLG   ,
     1                ITEMP    ,IDEFT    ,IDEFM    ,RECORD   ,OLDEID    
      COMMON /SDR2X2/ DUMMY(6) ,GPTT     ,DUM20(20)        
      COMMON /SDR2DE/ DUM2(2)  ,DEFALT        
      DATA    NAME  / 4HSDRE   ,4HTD  /  ,MAXWDS   / 33 /        
C        
      IF (OLDEID .EQ. ELID) RETURN        
      OLDEID = ELID        
      IF (ITEMP .NE. 0) GO TO 20        
      DO 10 I = 1,MAXWDS        
   10 TI(I) = 0        
      RETURN        
C        
   20 IF (.NOT.RECORD .OR. EORFLG) GO TO 80        
      IF (ELTYPE .NE. OLDEL) GO TO 160        
      IF (ENDID) GO TO 80        
C        
C     HERE WHEN ELTYPE IS AT HAND AND END OF THIS TYPE DATA        
C     HAS NOT YET BEEN REACHED.  READ AN ELEMENT ID        
C        
   40 CALL READ (*300,*310,GPTT,ID,1,0,FLAG)        
      IF (ID) 50,80,50        
   50 IF (IABS(ID) .EQ. ELID) IF (ID) 90,90,70        
      IF (ID) 40,40,60        
   60 CALL READ (*300,*310,GPTT,TI,NWORDS,0,FLAG)        
      GO TO 40        
C        
C     MATCH ON ELEMNT ID MADE AND IT WAS WITH DATA        
C        
   70 CALL READ (*300,*310,GPTT,TI,NWORDS,0,FLAG)        
C        
C     IF QUAD4 (ELTYPE 64) OR TRIA3 (ELTYPE 83) ELEMENT, SET FLAG FOR   
C     SQUD42 OR STRI32        
C        
      IF (ELTYPE.NE.64 .OR. ELTYPE.NE.83) RETURN        
      TI(7) = 13        
      IF (TI(6) .NE. 1) TI(7) = 2        
      RETURN        
C        
C     NO MORE DATA FOR THIS ELEMENT TYPE        
C        
   80 ENDID = .TRUE.        
C        
C     NO DATA FOR ELEMENT ID DESIRED, THUS USE DEFALT        
C        
   90 IF (DEFALT .EQ. -1) GO TO 140        
      IF (GRIDS  .GT.  0) GO TO 110        
      DO 100 I = 2,MAXWDS        
  100 TI(I) = 0        
      TI(1) = DEFALT        
      IF (ELTYPE .EQ. 34) TI(2) = DEFALT        
      RETURN        
C        
  110 IF (ELTYPE.NE.64 .OR. ELTYPE.NE.83) GO TO 120        
C                 QUAD4             TRIA3        
      TI(4) = 0        
      TI(5) = 0        
      TI(6) = 0        
      TI(7) = 0        
  120 DO 130 I = 1,GRIDS        
  130 TI(I) = DEFALT        
      TI(GRIDS+1) = DEFALT        
      RETURN        
C        
C     NO TEMP DATA OR DEFALT        
C        
  140 WRITE  (IOUT,150) UFM,ELID,ITEMP        
  150 FORMAT (A23,' 4016, THERE IS NO TEMPERATURE DATA FOR ELEMENT',I9, 
     1       ' IN SET',I9)        
      CALL MESAGE (-61,0,0)        
C        
C     LOOK FOR MATCH ON ELTYPE (FIRST SKIP ANY UNUSED ELEMENT DATA)     
C        
  160 IF (ENDID) GO TO 190        
  170 CALL READ (*300,*310,GPTT,ID,1,0,FLAG)        
      IF (ID) 170,190,180        
  180 CALL READ (*300,*310,GPTT,TI,NWORDS,0,FLAG)        
      GO TO 170        
C        
C     READ ELTYPE AND COUNT        
C        
  190 CALL READ (*300,*200,GPTT,TI,2,0,FLAG)        
      OLDEL  = TI(1)        
      NWORDS = TI(2)        
      ENDID = .FALSE.        
      GO TO 40        
C     END OF RECORD HIT        
C        
  200 EORFLG = .TRUE.        
      GO TO 80        
C        
  300 CALL MESAGE (-2,GPTT,NAME)        
  310 CALL MESAGE (-3,GPTT,NAME)        
      RETURN        
      END        
