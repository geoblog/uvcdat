      SUBROUTINE PELKAP(XMOM,PARA,IFAIL)
C***********************************************************************
C*                                                                     *
C*  FORTRAN CODE WRITTEN FOR INCLUSION IN IBM RESEARCH REPORT RC20525, *
C*  'FORTRAN ROUTINES FOR USE WITH THE METHOD OF L-MOMENTS, VERSION 3' *
C*                                                                     *
C*  J. R. M. HOSKING                                                   *
C*  IBM RESEARCH DIVISION                                              *
C*  T. J. WATSON RESEARCH CENTER                                       *
C*  YORKTOWN HEIGHTS                                                   *
C*  NEW YORK 10598, U.S.A.                                             *
C*                                                                     *
C*  VERSION 3     AUGUST 1996                                          *
C*                                                                     *
C***********************************************************************
C
C  PARAMETER ESTIMATION VIA L-MOMENTS FOR THE KAPPA DISTRIBUTION
C
C  PARAMETERS OF ROUTINE:
C  XMOM   * INPUT* ARRAY OF LENGTH 4. CONTAINS THE L-MOMENTS LAMBDA-1,
C                  LAMBDA-2, TAU-3, TAU-4.
C  PARA   *OUTPUT* ARRAY OF LENGTH 4. ON EXIT, CONTAINS THE PARAMETERS
C                  IN THE ORDER XI, ALPHA, K, H.
C  IFAIL  *OUTPUT* FAIL FLAG. ON EXIT, IT IS SET AS FOLLOWS.
C                  0  SUCCESSFUL EXIT
C                  1  L-MOMENTS INVALID
C                  2  (TAU-3, TAU-4) LIES ABOVE THE GENERALIZED-LOGISTIC
C                     LINE (SUGGESTS THAT L-MOMENTS ARE NOT CONSISTENT
C                     WITH ANY KAPPA DISTRIBUTION WITH H.GT.-1)
C                  3  ITERATION FAILED TO CONVERGE
C                  4  UNABLE TO MAKE PROGRESS FROM CURRENT POINT IN
C                     ITERATION
C                  5  ITERATION ENCOUNTERED NUMERICAL DIFFICULTIES -
C                     OVERFLOW WOULD HAVE BEEN LIKELY TO OCCUR
C                  6  ITERATION FOR H AND K CONVERGED, BUT OVERFLOW
C                     WOULD HAVE OCCURRED WHEN CALCULATING XI AND ALPHA
C
C  N.B.  PARAMETERS ARE SOMETIMES NOT UNIQUELY DEFINED BY THE FIRST 4
C  L-MOMENTS. IN SUCH CASES THE ROUTINE RETURNS THE SOLUTION FOR WHICH
C  THE H PARAMETER IS LARGEST.
C
C  OTHER ROUTINES USED: DLGAMA,DIGAMD
C
C  THE SHAPE PARAMETERS K AND H ARE ESTIMATED USING NEWTON-RAPHSON
C  ITERATION ON THE RELATIONSHIP BETWEEN (TAU-3,TAU-4) AND (K,H).
C  THE CONVERGENCE CRITERION IS THAT TAU-3 AND TAU-4 CALCULATED FROM
C  THE ESTIMATED VALUES OF K AND H SHOULD DIFFER BY LESS THAN 'EPS'
C  FROM THE VALUES SUPPLIED IN ARRAY XMOM.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION XMOM(4),PARA(4)
      DATA ZERO/0D0/,HALF/0.5D0/,ONE/1D0/,TWO/2D0/,THREE/3D0/,FOUR/4D0/
      DATA FIVE/5D0/,SIX/6D0/,TWELVE/12D0/,TWENTY/20D0/,THIRTY/30D0/
      DATA P725/0.725D0/,P8/0.8D0/
C
C         EPS,MAXIT CONTROL THE TEST FOR CONVERGENCE OF N-R ITERATION
C         MAXSR IS THE MAX. NO. OF STEPLENGTH REDUCTIONS PER ITERATION
C         HSTART IS THE STARTING VALUE FOR H
C         BIG IS USED TO INITIALIZE THE CRITERION FUNCTION
C         OFLEXP IS SUCH THAT DEXP(OFLEXP) JUST DOES NOT CAUSE OVERFLOW
C         OFLGAM IS SUCH THAT DEXP(DLGAMA(OFLGAM)) JUST DOES NOT CAUSE
C           OVERFLOW
C
      DATA EPS/1D-6/,MAXIT/20/,MAXSR/10/,HSTART/1.001D0/,BIG/10D0/
      DATA OFLEXP/170D0/,OFLGAM/53D0/
C
      T3=XMOM(3)
      T4=XMOM(4)
      DO 10 I=1,4
   10 PARA(I)=ZERO
C
C         TEST FOR FEASIBILITY
C
      IF(XMOM(2).LE.ZERO)GOTO 1000
      IF(DABS(T3).GE.ONE.OR.DABS(T4).GE.ONE)GOTO 1000
      IF(T4.LE.(FIVE*T3*T3-ONE)/FOUR)GOTO 1000
      IF(T4.GE.(FIVE*T3*T3+ONE)/SIX )GOTO 1010
C
C         SET STARTING VALUES FOR N-R ITERATION:
C         G IS CHOSEN TO GIVE THE CORRECT VALUE OF TAU-3 ON THE
C         ASSUMPTION THAT H=1 (I.E. A GENERALIZED PARETO FIT) -
C         BUT H IS ACTUALLY SET TO 1.001 TO AVOID NUMERICAL
C         DIFFICULTIES WHICH CAN SOMETIMES ARISE WHEN H=1 EXACTLY
C
      G=(ONE-THREE*T3)/(ONE+T3)
      H=HSTART
      Z=G+H*P725
      XDIST=BIG
C
C         START OF NEWTON-RAPHSON ITERATION
C
      DO 100 IT=1,MAXIT
C
C         REDUCE STEPLENGTH UNTIL WE ARE NEARER TO THE REQUIRED
C         VALUES OF TAU-3 AND TAU-4 THAN WE WERE AT THE PREVIOUS STEP
C
      DO 40 I=1,MAXSR
C
C         - CALCULATE CURRENT TAU-3 AND TAU-4
C
C           NOTATION:
C           U.    - RATIOS OF GAMMA FUNCTIONS WHICH OCCUR IN THE PWM'S
C                   BETA-SUB-R
C           ALAM. - L-MOMENTS (APART FROM A LOCATION AND SCALE SHIFT)
C           TAU.  - L-MOMENT RATIOS
C
      IF(G.GT.OFLGAM)GOTO 1020
      IF(H.GT.ZERO)GOTO 20
      U1=DEXP(DLGAMA(  -ONE/H-G)-DLGAMA(  -ONE/H+ONE))
      U2=DEXP(DLGAMA(  -TWO/H-G)-DLGAMA(  -TWO/H+ONE))
      U3=DEXP(DLGAMA(-THREE/H-G)-DLGAMA(-THREE/H+ONE))
      U4=DEXP(DLGAMA( -FOUR/H-G)-DLGAMA( -FOUR/H+ONE))
      GOTO 30
   20 U1=DEXP(DLGAMA(  ONE/H)-DLGAMA(  ONE/H+ONE+G))
      U2=DEXP(DLGAMA(  TWO/H)-DLGAMA(  TWO/H+ONE+G))
      U3=DEXP(DLGAMA(THREE/H)-DLGAMA(THREE/H+ONE+G))
      U4=DEXP(DLGAMA( FOUR/H)-DLGAMA( FOUR/H+ONE+G))
   30 CONTINUE
      ALAM2=U1-TWO*U2
      ALAM3=-U1+SIX*U2-SIX*U3
      ALAM4=U1-TWELVE*U2+THIRTY*U3-TWENTY*U4
      IF(ALAM2.EQ.ZERO)GOTO 1020
      TAU3=ALAM3/ALAM2
      TAU4=ALAM4/ALAM2
      E1=TAU3-T3
      E2=TAU4-T4
C
C         - IF NEARER THAN BEFORE, EXIT THIS LOOP
C
      DIST=DMAX1(DABS(E1),DABS(E2))
      IF(DIST.LT.XDIST)GOTO 50
C
C         - OTHERWISE, HALVE THE STEPLENGTH AND TRY AGAIN
C
      DEL1=HALF*DEL1
      DEL2=HALF*DEL2
      G=XG-DEL1
      H=XH-DEL2
   40 CONTINUE
C
C         TOO MANY STEPLENGTH REDUCTIONS
C
      IFAIL=4
      RETURN
C
C         TEST FOR CONVERGENCE
C
   50 CONTINUE
      IF(DIST.LT.EPS)GOTO 110
C
C         NOT CONVERGED: CALCULATE NEXT STEP
C
C         NOTATION:
C         U1G  - DERIVATIVE OF U1 W.R.T. G
C         DL2G - DERIVATIVE OF ALAM2 W.R.T. G
C         D..  - MATRIX OF DERIVATIVES OF TAU-3 AND TAU-4 W.R.T. G AND H
C         H..  - INVERSE OF DERIVATIVE MATRIX
C         DEL. - STEPLENGTH
C
      XG=G
      XH=H
      XZ=Z
      XDIST=DIST
      RHH=ONE/(H*H)
      IF(H.GT.ZERO)GOTO 60
      U1G=-U1*DIGAMD(  -ONE/H-G)
      U2G=-U2*DIGAMD(  -TWO/H-G)
      U3G=-U3*DIGAMD(-THREE/H-G)
      U4G=-U4*DIGAMD( -FOUR/H-G)
      U1H=      RHH*(-U1G-U1*DIGAMD(  -ONE/H+ONE))
      U2H=  TWO*RHH*(-U2G-U2*DIGAMD(  -TWO/H+ONE))
      U3H=THREE*RHH*(-U3G-U3*DIGAMD(-THREE/H+ONE))
      U4H= FOUR*RHH*(-U4G-U4*DIGAMD( -FOUR/H+ONE))
      GOTO 70
   60 U1G=-U1*DIGAMD(  ONE/H+ONE+G)
      U2G=-U2*DIGAMD(  TWO/H+ONE+G)
      U3G=-U3*DIGAMD(THREE/H+ONE+G)
      U4G=-U4*DIGAMD( FOUR/H+ONE+G)
      U1H=      RHH*(-U1G-U1*DIGAMD(  ONE/H))
      U2H=  TWO*RHH*(-U2G-U2*DIGAMD(  TWO/H))
      U3H=THREE*RHH*(-U3G-U3*DIGAMD(THREE/H))
      U4H= FOUR*RHH*(-U4G-U4*DIGAMD( FOUR/H))
   70 CONTINUE
      DL2G=U1G-TWO*U2G
      DL2H=U1H-TWO*U2H
      DL3G=-U1G+SIX*U2G-SIX*U3G
      DL3H=-U1H+SIX*U2H-SIX*U3H
      DL4G=U1G-TWELVE*U2G+THIRTY*U3G-TWENTY*U4G
      DL4H=U1H-TWELVE*U2H+THIRTY*U3H-TWENTY*U4H
      D11=(DL3G-TAU3*DL2G)/ALAM2
      D12=(DL3H-TAU3*DL2H)/ALAM2
      D21=(DL4G-TAU4*DL2G)/ALAM2
      D22=(DL4H-TAU4*DL2H)/ALAM2
      DET=D11*D22-D12*D21
      H11= D22/DET
      H12=-D12/DET
      H21=-D21/DET
      H22= D11/DET
      DEL1=E1*H11+E2*H12
      DEL2=E1*H21+E2*H22
C
C         TAKE NEXT N-R STEP
C
      G=XG-DEL1
      H=XH-DEL2
      Z=G+H*P725
C
C         REDUCE STEP IF G AND H ARE OUTSIDE THE PARAMETER SPACE
C
      FACTOR=ONE
      IF(G.LE.-ONE)FACTOR=P8*(XG+ONE)/DEL1
      IF(H.LE.-ONE)FACTOR=DMIN1(FACTOR,P8*(XH+ONE)/DEL2)
      IF(Z.LE.-ONE)FACTOR=DMIN1(FACTOR,P8*(XZ+ONE)/(XZ-Z))
      IF(H.LE.ZERO.AND.G*H.LE.-ONE)
     *  FACTOR=DMIN1(FACTOR,P8*(XG*XH+ONE)/(XG*XH-G*H))
      IF(FACTOR.EQ.ONE)GOTO 80
      DEL1=DEL1*FACTOR
      DEL2=DEL2*FACTOR
      G=XG-DEL1
      H=XH-DEL2
      Z=G+H*P725
   80 CONTINUE
C
C         END OF NEWTON-RAPHSON ITERATION
C
  100 CONTINUE
C
C         NOT CONVERGED
C
      IFAIL=3
      RETURN
C
C         CONVERGED
C
  110 IFAIL=0
      PARA(4)=H
      PARA(3)=G
      TEMP=DLGAMA(ONE+G)
      IF(TEMP.GT.OFLEXP)GOTO 1030
      GAM=DEXP(TEMP)
      TEMP=(ONE+G)*DLOG(DABS(H))
      IF(TEMP.GT.OFLEXP)GOTO 1030
      HH=DEXP(TEMP)
      PARA(2)=XMOM(2)*G*HH/(ALAM2*GAM)
      PARA(1)=XMOM(1)-PARA(2)/G*(ONE-GAM*U1/HH)
      RETURN
C
 1000 IFAIL=1
      RETURN
 1010 IFAIL=2
      RETURN
 1020 IFAIL=5
      RETURN
 1030 IFAIL=6
      RETURN
C
      END