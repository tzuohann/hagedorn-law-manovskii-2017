!Computing the mean of wages at firms and counts
#include "fintrf.h" 
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
implicit none

!This is fixed. Don't touch.
mwPointer plhs(*), prhs(*)
integer(4) nlhs, nrhs
mwPointer mxCreateNumericMatrix
integer(4) mxClassIDFromClassName

!This is fixed as well so long we are not interested in anything but integers            
mwPointer mxGetPr
mwsize mxGetM, mxGetN

!Name as many size holders
mwsize LenM,LenN

!Name as many LHS and RHS variables
mwpointer WN, WW, WageCount, NumAgentsSim, Vector, Num

!Here, assign input variables to the pointers
WN                = mxGetPr(prhs(1))
WW                = mxGetPr(prhs(2))
NumAgentsSim      = mxGetPr(prhs(3))

LenM              = mxGetM(prhs(1))
LenN              = mxGetN(prhs(1))

!Create matrix for the return argument.
!Describe the output. Dimensions, what they are, data type, and is it complex      
plhs(1)           = mxCreateNumericMatrix(%val(NumAgentsSim),2,mxClassIDFromClassName('double'),0)
plhs(2)           = mxCreateNumericMatrix(LenM*LenN, 1, mxClassIDFromClassName('double'),0)
plhs(3)           = mxCreateNumericMatrix(1, 1, mxClassIDFromClassName('int32'),0)

!Assign output variables to pointers
WageCount      = mxGetPr(plhs(1))
Vector         = mxGetPr(plhs(2))
Num            = mxGetPr(plhs(3))

!Stuff these into a subroutine which calls all the other subroutines which are written in f90
call MexWrap(LenM,LenN,%val(NumAgentsSim),%val(WN),%val(WW),%val(WageCount),%val(Vector),%val(Num))
return
end

subroutine MexWrap(LenM,LenN,NumAgentsSim,WN,WW,WageCount,Vector,Num)
implicit none

integer(4), intent(in)                          :: LenM,LenN,NumAgentsSim
integer(4), intent(in), dimension(LenM,LenN)    :: WN
real(8), intent(in), dimension(LenM,LenN)       :: WW
real(8), intent(out), dimension(NumAgentsSim,2) :: WageCount
real(8), dimension(NumAgentsSim,LenN)           :: WageRecord
real(8), intent(out), dimension(LenM*LenN)      :: Vector
integer(4), intent(out)                         :: Num
integer(4)  :: ij,it,i1
character(1000) :: line

WageCount       = 0
Vector          = 0
Num             = 0

!First construct for each worker, the wages at the firm. Keep count.
do it = 1,LenN
  !$OMP PARALLEL DO NUM_THREADS(8)
  do ij = 1,LenM
    if (WN(ij,it) .ne. 0) then
      WageCount(WN(ij,it),2) = WageCount(WN(ij,it),2) + 1
      WageRecord(WN(ij,it),WageCount(WN(ij,it),2)) = WW(ij,it)
    endif
  enddo
enddo

Num = 0
!If really pushing the sample size paralleize. Since we are only working with 1 firm and a max of 240 periods,
!Make vector 240*NumAgentsSim, and paralllize over workers.
!Now, get the mean, an for each worker at the firm.
do i1 = 1,NumAgentsSim
  if (WageCount(i1,2).ge.1) then
    !Compute the mean.
    WageCount(i1,1)  = sum(WageRecord(i1,1:WageCount(i1,2)))/WageCount(i1,2)
    !Keep the Vector to spit out
    Vector(Num + 1 : Num + WageCount(i1,2)) = WageRecord(i1,1:WageCount(i1,2)) - WageCount(i1,1)
!    Vector(Num + 1 : Num + WageCount(i1,2)) = Vector(Num + 1 : Num + WageCount(i1,2))   
    Num = Num + WageCount(i1,2)
  endif
enddo

return
end subroutine MexWrap

subroutine mexWriteString(String)
  implicit none
  character(*),intent(in):: String
  call mexevalString('display('''//trim(String)//''')')
end subroutine mexWriteString
