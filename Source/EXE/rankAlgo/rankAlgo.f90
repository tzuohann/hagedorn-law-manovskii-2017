module GlobalPars
  implicit none
  save
  integer(4), parameter :: fid = 666
  integer(4) :: NumAgentsSim 
  integer(4) :: sizeBI
  integer(4) :: OMPTHREADS 
  integer(4) :: NITERMAX
  integer(4) :: DistMaxInGlo
  real(8)    :: ProbDistInc
  integer(4) :: MovesToSave
  integer(4) :: DispCheck
  integer(4) :: DispMove
  integer(4), parameter :: LOGFILE = 999
end module GlobalPars

module GlobalVars
  use GlobalPars
  implicit none
    
  integer(4)  :: maxC, maxFirm
  integer(4),dimension(:),allocatable         :: wIdxS,wIdxE,sFVec,eFVec,NameAtRank,DontUse
  integer(4),dimension(:),allocatable         :: FirmList,OrderFID, OrderWID, minCoWID, maxCoWID
  real(4),dimension(:),allocatable            :: WAve,InvC
  real(8)                                     :: StdNoiseRt2
end module GlobalVars

subroutine GenNAtRNow(wPrev,wNxt,NAtRNow)
	use GlobalPars
	implicit none
	integer(4),intent(in),dimension(NumAgentsSim)  :: wPrev,wNxt
	integer(4),intent(out),dimension(NumAgentsSim) :: NAtRNow
	integer(4)                                     :: i1,i2,i3
	NAtRNow = 0
	
	!Update NAtRNow from both directions.
	do i1 = 1,NumAgentsSim
		if (wPrev(i1) .eq. 0) then
		  i2 = i1
		  i3 = 1
		  do
		    NAtRNow(i3) = i2
		    if (wNxt(i2).gt.0) then
		    	i3 = i3 + 1
		    	i2 = wNxt(i2)
		    else
		    	exit
		    endif
		  enddo
		  exit
		endif 
	enddo
	return
end subroutine GenNAtRNow

subroutine getwPrevNxt(wPrev,wNxt,NAtRank)
  use GlobalPars
  implicit none
  integer(4), intent(out), dimension(NumAgentsSim)   :: wPrev,wNxt
  integer(4), intent(in), dimension(NumAgentsSim)    :: NAtRank
  integer(4)                   :: i1
  
  wPrev = 0
  wNxt  = 0
  do i1 = 1,NumAgentsSim - 1
  	wNxt(NAtRank(i1))   = NAtRank(i1 + 1)
  	wPrev(NAtRank(i1+1)) = NAtRank(i1)
  enddo


  return
end subroutine getwPrevNxt  

subroutine getwBin(wPrev,wNxt,wBin,BinSize,NumBin)
	use GlobalPars
	implicit none
	integer(4),intent(in),dimension(NumAgentsSim)   :: wNxt,wPrev
	integer(4),intent(in)    :: BinSize
	integer(4),intent(out),dimension(NumAgentsSim)  :: wBin
	integer(4),intent(out) :: NumBin 
	integer(4)  :: i1,i2,i3
	
    !Go through all workers.
	do i1 = 1,NumAgentsSim
        !Find the first worker.
		if (wPrev(i1).eq.0) then
			i2 = i1
			i3 = 1
			do
              wBin(i2) = ceiling(real(i3)/real(BinSize))
              if (wNxt(i2).gt.0) then
			  	i3 = i3 + 1
			  	i2 = wNxt(i2)
			  else
			  	exit
			  endif
			enddo
		endif
    enddo
    
	NumBin = maxval(wBin)
	return
end subroutine getwBin

subroutine randperm(N,p)
  implicit none
  integer(4), intent(in) :: N
  integer(4), dimension(n), intent(out) :: p
  
  integer(4) :: i,j,k
  integer(4) :: temp
  real(8) :: u
  
  p = (/(i,i=1,n)/)
  
  do j = N,2,-1
    call random_number(u)
    k = floor(j*u) + 1
    
    temp = p(k)
    p(k) = p(j)
    p(j) = temp
  enddo
  return
end subroutine randperm


subroutine ReadData
  use GlobalPars
  use GlobalVars
  implicit none
  integer(4) :: i1000,TempI,FPrev,i1,i2,i3,ir

  write(*,*) "read DistMaxInGlo"
  open(unit=fid, file='DistMaxInGlo.txt',status='old',action='read')
  read(fid,*) DistMaxInGlo

  write(*,*) "read NITERMAX"
  open(unit=fid, file='NITERMAX.txt',status='old',action='read')
  read(fid,*) NITERMAX

  write(*,*) "read NumAgentsSim"
  open(unit=fid, file='NumAgentsSim.txt',status='old',action='read')
  read(fid,*) NumAgentsSim

  allocate(NameAtRank(NumAgentsSim))
  allocate(DontUse(NumAgentsSim))
  allocate(wIdxS(NumAgentsSim))
  allocate(wIdxE(NumAgentsSim))
  allocate(sFVec(NumAgentsSim))
  allocate(eFVec(NumAgentsSim))
  allocate(minCoWID(NumAgentsSim))
  allocate(maxCoWID(NumAgentsSim))
  
  write(*,*) "read SizeBI"
  open(unit=fid, file='sizeBI.txt',status='old',action='read')
  read(fid,*) SizeBI
  
  allocate(FirmList(SizeBI))
  allocate(WAve(SizeBI))
  allocate(InvC(SizeBI))  
  allocate(OrderFID(SizeBI)) 
  allocate(OrderWID(SizeBI))
  
  write(*,*) "read VarNoise"    
  open(unit=fid, file='VarNoise.txt',status='old',action='read')
  read(fid,*) StdNoiseRt2
  close(fid,status = 'keep')

  StdNoiseRt2 = 2.0d0**0.5*StdNoiseRt2**0.5d0 

  write(*,*) "read DontUse"
  open(unit=fid, file='DontUse.txt',status='old',action='read')
  read(fid,*) DontUse
  close(fid,status = 'keep')  
  
  write(*,*) "read Name"
  open(unit=fid, file='NRAgg.txt',status='old',action='read')
  read(fid,*) NameAtRank
  close(fid,status = 'keep')

  write(*,*) "read wIdxS"
  open(unit=fid, file='wIdxS.txt',status='old',action='read')
  read(fid,*) wIdxS
  close(fid,status = 'keep')

  write(*,*) "read wIdxE"
  open(unit=fid, file='wIdxE.txt',status='old',action='read')
  read(fid,*) wIdxE
  close(fid,status = 'keep')

  write(*,*) "read eID"
  open(unit=fid, file='eID.txt',status='old',action='read')
  read(fid,*) FirmList
  close(fid,status = 'keep')

  write(*,*) "read WAve"
  open(unit=fid, file='WAve.txt',status='old',action='read')
  read(fid,*) WAve
  close(fid,status = 'keep')

  write(*,*) "read cInv"
  open(unit=fid, file='cInv.txt',status='old',action='read')
  read(fid,*) InvC
  close(fid,status = 'keep')
  
  write(*,*) "read OrderFID"
  open(unit=fid, file='OrderFID.txt',status='old',action='read')
  read(fid,*) OrderFID
  close(fid,status = 'keep')
  
  write(*,*) "read OrderWID"
  open(unit=fid, file='OrderWID.txt',status='old',action='read')
  read(fid,*) OrderWID
  close(fid,status = 'keep')  
    
  
  maxFirm     = maxval(FirmList)
  maxC        = maxval(wIdxE - wIdxS + 1)
  
  do i1000 = 1,NumAgentsSim
    sFVec(i1000) = FirmList(wIdxS(i1000))
    eFVec(i1000) = FirmList(wIdxE(i1000))
  enddo
  
  write(*,*) "Completed first and last firm"
    
  FPrev = OrderFID(1)
  ir    = 1
  minCoWID = 666666666
  maxCoWID = -666666666
  do i1 = 2,SizeBI
    if (OrderFID(i1) .ne. FPrev) then
      FPrev = OrderFID(i1)
      do i3 = ir,i1-1
        minCoWID(OrderWID(i3)) = min(minCoWID(OrderWID(i3)),OrderWID(ir))
        maxCoWID(OrderWID(i3)) = max(maxCoWID(OrderWID(i3)),OrderWID(i1-1))
      enddo
      ir = i1
    endif

    if (i1 .eq. SizeBI) then
      do i3 = ir,i1
        minCoWID(OrderWID(i3)) = min(minCoWID(OrderWID(i3)),OrderWID(ir))
        maxCoWID(OrderWID(i3)) = max(maxCoWID(OrderWID(i3)),OrderWID(i1))
      enddo
    endif    
  enddo
  write(*,*) "Completed detecting min and max coworkers"
end subroutine ReadData

subroutine doFastZ(costOut,FinalRank,DistMaxIn)
  use GlobalPars
  use GlobalVars
  use OMP_LIB
  implicit none
  
  !IO 
  integer(4),intent(out), dimension(NumAgentsSim) :: FinalRank
  integer(4), intent(in)                          :: DistMaxIn
  real(8), intent(in)                             :: costOut
  
  !Functionals
  byte, dimension(maxFirm) :: rFList
  real(4), dimension(maxC) :: rWList,rCList
  byte                     :: prFList
  integer(4),dimension(NumAgentsSim)   :: wPrev,wNxt,wBin
  integer(4),dimension(NumAgentsSim)   :: RandWorker
  integer(4)                           :: DistMax, DistMaxPvtU, DistMaxPvtD
  logical,dimension(:), allocatable    :: BinMove,WorkerIsMoved,BinMovePvt
  integer(4),dimension(2,2) :: chgBin,wJmpUD
  
  !Temps
  real(8)    :: Cost,CostPrev,TmpR,CostCol,NumD,NumU,CostChgD,CostChgU,CostChgDMax,CostChgUMax
  integer(4) :: DistMaxPrev,UpDown,tstart,tend,trate
  integer(4) :: FinalLoop,NumBin,UDMove,ThreadUse
  logical    :: ThreadToWork
  character(100) :: fName
  
  !Counters
  integer(4)    :: i1,i2,i3,iMove,icD,icU,ihU,ihD,ccU,ccD,iCheck,im, inR,i4,ifoo
  integer(4)    :: ir,ic,rBin,rBinO,rS,rE,frS,frE,TmpI,TID
  
  write(*,*) "doFastZ"
  !write(LOGFILE,*) "doFastZ"
  
  DistMaxPrev = DistMaxIn
  Cost        = costOut
  rWList      = 0.0d0
  rCList      = 0.0d0
  rFList      = 0
  
  !Initialize
  FinalRank   = NameAtRank
  FinalLoop   = 0
  call getwPrevNxt(wPrev,wNxt,NameAtRank)
  call random_seed(PUT = (/10,10/))
  allocate(BinMove(NumAgentsSim))
  allocate(BinMovePvt(NumAgentsSim))
  
  !For now, just do a fixed number of iterations
  do i3 = 1,NITERMAX
   	
   	!Exit Variable
   	CostPrev = Cost
   	
   	!Generate a random permutation
   	call RandPerm(NumAgentsSim,RandWorker)
    WorkerIsMoved = .false.   	

  write(*,*) "read DispCheck"
  open(unit=fid, file='DispCheck.txt',status='old',action='read')
  read(fid,*) DispCheck    

  write(*,*) "read DispMove"
  open(unit=fid, file='DispMove.txt',status='old',action='read')
  read(fid,*) DispMove  
  
    write(*,*) "read OMPTHREADS"
    open(unit=fid, file='OMPTHREADS.txt',status='old',action='read')
    read(fid,*) OMPTHREADS  
  
    write(*,*) "read ProbDistInc"
    open(unit=fid, file='ProbDistInc.txt',status='old',action='read')
    read(fid,*) ProbDistInc    
    
    write(*,*) "read MovesToSave"
    open(unit=fid, file='MovesToSave.txt',status='old',action='read')
    read(fid,*) MovesToSave    
    
   	!Reset make DistMax larger sometimes
   	call random_number(TmpR)
   	if (TmpR .gt. ProbDistInc) then
      write(*,*) "DISTMAX DECREASE"
      DistMax     = DistMaxPrev
      DistMaxPrev = 1
    else
      write(*,*) "DISTMAX INCREASE"
   	  !Sometimes, make DistMax grow larger. But at most, to NumAgentsSim
   		DistMax      = min(int(1.1*DistMaxPrev),NumAgentsSim)
   		DistMaxPrev  = 1
    endif
   	
    ThreadUse = OMPTHREADS
    if (FinalLoop == 1) then
      !write(LOGFILE,*) "FINAL LOOP: DISTMAX SET TO MAX, 1 THREAD!"
      write(*,*) "FINAL LOOP: DISTMAX SET TO MAX, 1 THREAD!"
      DistMax = NumAgentsSim
      ThreadUse= 1
    endif
    
    !write(LOGFILE,*) "DistMax :",DistMax
    write(*,*) "DistMax :",DistMax 
    
		iMove    = 0
		iCheck   = 0
		CostCol  = 0
   	i4       = 1
    BinMove  = .false.
    
   	!write(LOGFILE,*) "Using :",ThreadUse," threads."
   	write(*,*) "Using :",ThreadUse," threads."

    call system_clock(tstart,trate)
  
   	!$OMP PARALLEL DO NUM_THREADS(ThreadUse) SHARED(RandWorker,DistMaxPrev,CostCol,DistMax)&
   	!$OMP& FIRSTPRIVATE(UDMove,NumU,NumD,ThreadToWork,inR,ir,ccU,ccD,rS,rE,frS,frE,DistMaxPvtU,DistMaxPvtD,rFList,rWList,rCList,ihD,ihU,wJmpUD,CostChgUMax,CostChgDMax,CostChgU,CostChgD,icU,icD,rBin,chgBin,rBinO,prFList,TmpR,TmpI,TID,UpDown,BinMovePvt,i4) 
   	do i2 = 1,NumAgentsSim
   		
   	  !Find a worker in an unoccupied bin
   		ThreadToWork = .FALSE.
      do ifoo = 1,1000
        !Since this loop is parallel, workers can be stuck in an infinite loop without this.
        if (iCheck .eq. NumAgentsSim) exit
        
        !Pick a worker at random. 
        i4 = mod(i4,NumAgentsSim) + 1

        !$OMP CRITICAL   
        ir = RandWorker(i4)
        if (ir .eq. 0) then
          !Nothing, this worker has already been investigated. Go to next.
        elseif (BinMove(ir)) then
          !This worker is currently affected by some other worker. Don't proceed.
          !Set ir = 0 so nothing happens, but don't make it done.
          ir = 0
        elseif (DontUse(ir) .eq. 1) then
          !Do not use this worker. Make it done set ir = 0 so that no moving happens.
          RandWorker(i4) = 0
          iCheck         = iCheck + 1
          ir             = 0
	 		    if (mod(iCheck,DispCheck).eq.0) then
	 			    !write(LOGFILE,*) "Checked :",iCheck
	 			    write(*,*) "Checked :",iCheck
	 		    endif
        else
          !This worker is ready to be worked with.
          !Consider it done.
          RandWorker(i4) = 0
          iCheck         = iCheck + 1
	 		    if (mod(iCheck,DispCheck).eq.0) then
	 			    !write(LOGFILE,*) "Checked :",iCheck
	 			    write(*,*) "Checked :",iCheck
	 		    endif
        endif

        if (ir.gt.0) then
 			    !Choose direction randomly (90% up or down, 10% both directions)
          call random_number(TmpR)
          if (TmpR .lt. 0.45) then
            UpDown = -1
          elseif (TmpR .gt. 0.55) then
            UpDown = 1
          else
            UpDown = 0
          endif

          DistMaxPvtU = 0
 			    DistMaxPvtD = 0
          !We use this to return shared BinMove to the original state.
          BinMovePvt  = .true.  

          BinMove(ir) = .true.
          BinMovePvt(ir)  = .false.

          if (UpDown .ge. 0) then
            !Make the current reference worker the worker of interest.
            !We want to know how many steps up is occupied by some other worker.
            ic = ir
 			      do im = 1,DistMax
 			        
 			        if (wNxt(ic).eq.0) then
                !This is the last worker.
                exit
 			        else 
                ic = wNxt(ic) 
                if (BinMove(ic)) then
                  !Worker is being used by some other thread. Exit
                  exit
                else
                  BinMove(ic)     = .true.
                  BinMovePvt(ic)  = .false.
                  DistMaxPvtU     = DistMaxPvtU + 1
                endif
 				      endif
 				      
 				    enddo
 				  endif
 				    
	 		    if (UpDown .le. 0) then
	 		      
            ic = ir
 			      do im = 1,DistMax
 			        
 			        if (wPrev(ic).eq.0) then
                !This is the first worker.
                exit
 			        else 
                ic = wPrev(ic) 
                if (BinMove(ic)) then
                  !Worker is being used by some other thread. Exit
                  exit
                else
                  BinMove(ic)     = .true.
                  BinMovePvt(ic)  = .false.
                  DistMaxPvtD     = DistMaxPvtD + 1
                endif
 				      endif
 				      
 				    enddo
	 			  endif 

	 			  if ((DistMaxPvtU .gt. 0).or.(DistMaxPvtD .gt. 0)) then
	 			    ThreadToWork = .true.
	 			  endif
 			  endif
 			  !$OMP END CRITICAL
        if (ThreadToWork) then
          !Go to work
          exit
        endif 			    
 			enddo
 			
  		if (ThreadToWork) then
        wJmpUD = 0
        
        rS = wIdxS(ir)
        rE = wIdxE(ir)
        frS = sFVec(ir)
        frE = eFVec(ir)
        
        rWList(1:(rE-rS+1)) = wAve(rS:rE)
        rFList(FirmList(rS:rE)) = (/(ic,ic = 1,rE - rS + 1)/)
        rCList(1:(rE-rS+1)) = InvC(rS:rE)
        
        CostChgDMax = 0
        CostChgUMax = 0 
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !!!!!!!SECTIONS THIS NEXT PART
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (UpDown.ge.0) then
          icU      = ir
          ihU      = 0
          CostChgU = 0.0d0 
          do   				
            icU = wNxt(icU)
            !Increase the counter if haven't hit end of list or max distance.
            if (icU.eq.0) then
              exit
            elseif (ihU.eq.DistMaxPvtU) then
              exit
            else
              ihU = ihU + 1
            endif

            !Now see if the worker is comparable.
            if ((wAve(wIdxS(icU))).eq.0) then
              !Do nuthin this worker is not comparable to anyone.
            elseif (icU .lt. minCoWID(ir)) then
              !Do nuthin this worker is outside min worker id
            elseif (icU .gt. maxCoWID(ir)) then
              !Do nuthin this worker is outside max worker id
            elseif (frS.gt.eFVec(icU)) then
              !Do nuthin first firm of reference worker is larger than last firm of comparison worker.
            elseif (frE.lt.sFvec(icU)) then
              !Do nuthin last firm of reference worker is smaller than first firm of comparison worker.
            else
              do ccU = wIdxS(icU),wIdxE(icU)
                prFList = rFList(FirmList(ccU))
                if (prFlist .gt. 0) then
                  NumU = 0.5d0 * erf(( rWList(prFList) - wAve(ccU))/(StdNoiseRt2 * sqrt((rCList(prFList) + InvC(ccU))))) + 0.5d0
                  CostChgU = CostChgU + log(max(NumU,2d-300)) - log(max(1.0 - NumU,2d-300))
                endif
              enddo
              if (CostChgU .gt. CostChgUMax) then
                CostChgUMax = CostChgU
                wJmpUD(2,:) = (/icU,ihU/)
              endif
            endif
          enddo
        endif
                
        if (UpDown.le.0) then
          
          icD         = ir
          ihD         = 0
          CostChgD    = 0.0d0 
          do   				
            icD = wPrev(icD)

            !Increase the counter if haven't hit end of list or max distance.
            if (icD.eq.0) then
              exit
            elseif (ihD.eq.DistMaxPvtD) then
              exit
            else
              ihD = ihD + 1
            endif            

            !Now see if the worker is comparable.
            if ((wAve(wIdxS(icD))).eq.0) then
              !Do nuthin this worker is not comparable to anyone.
            elseif (icD .lt. minCoWID(ir)) then
              !Do nuthin this worker is outside min worker id
            elseif (icD .gt. maxCoWID(ir)) then
              !Do nuthin this worker is outside max worker id
            elseif (frS.gt.eFVec(icD)) then
              !Do nuthin first firm of reference worker is larger than last firm of comparison worker.
            elseif (frE.lt.sFvec(icD)) then
              !Do nuthin last firm of reference worker is smaller than first firm of comparison worker.
            else            
              do ccD = wIdxS(icD),wIdxE(icD)
                prFList = rFList(FirmList(ccD))
                if (prFlist .gt. 0) then
                  NumD = 0.5d0 * erf(( rWList(prFList) - wAve(ccD))/(StdNoiseRt2 * sqrt((rCList(prFList) + InvC(ccD))))) + 0.5d0
                  CostChgD = CostChgD - log(max(NumD,2d-300)) + log(max(1.0 - NumD,2d-300))
                endif
              enddo
              if (CostChgD .gt. CostChgDMax) then
                CostChgDMax = CostChgD
                wJmpUD(1,:) = (/icD,ihD/)
              endif
            endif
          enddo
        endif
                

        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !!!!!!!END SECTIONS HERE.
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (any(wJmpUD(:,1).gt.0)) then
          TmpR = maxval((/CostChgDMax,CostChgUMax/))
          UDMove = maxloc((/CostChgDMax,CostChgUMax/),1)

          !$OMP CRITICAL
          iMove = iMove + 1				
          if (mod(iMove,DispMove).eq.0) then 
            !write(LOGFILE,*) "Moves   :",iMove
            write(*,*) "Moves   :",iMove
          endif
          CostCol = CostCol + TmpR
          DistMaxPrev = max(DistMaxPrev,wJmpUD(UDMove,2))
                    
          if (UDMove .eq. 1) then
            TmpI = wNxt(ir)
            if (TmpI.gt.0) wPrev(TmpI) = wPrev(ir)
            TmpI = wPrev(ir)
            wNxt(TmpI) = wNxt(ir)
            TmpI = wPrev(wJmpUD(1,1))
            if (TmpI.gt.0) wNxt(TmpI) = ir
            wPrev(ir) = TmpI
            wNxt(ir) = wJmpUD(1,1)
            wPrev(wJmpUD(1,1)) = ir
          else
            TmpI = wPrev(ir)
            if (TmpI.gt.0) wNxt(TmpI) = wNxt(ir)
            TmpI = wNxt(ir)
            wPrev(TmpI) = wPrev(ir)
            TmpI = wNxt(wJmpUD(2,1))
            if (TmpI.gt.0) wPrev(TmpI) = ir
            wNxt(ir) = TmpI
            wPrev(ir)= wJmpUD(2,1)
            wNxt(wJmpUD(2,1)) = ir
          endif
          
          if (MovesToSave .gt. 0) then
            if (mod(iMove,MovesToSave).eq.0) then 
              write(*,*) "Moves   :",iMove
              call GenNAtRNow(wPrev,wNxt,FinalRank)
              write(*,*) "Outputting NRagg for this number of moves performed"
              open(unit = fid,file = 'NRAgg.txt',status = 'replace',action = 'write')
              write(fid,'(I8)') FinalRank
              close(fid)		
            endif
          endif
          !$OMP END CRITICAL
        endif
        
        BinMove  = BinMove .and. BinMovePvt
        rFList(FirmList(rs:rE)) = 0
      endif
   	enddo
   	!$OMP END PARALLEL DO 
		Cost = Cost + CostCol
		write(*,'(A,I5,A,F15.0,A,I10,A,I10)') "Cost ",i3," iter is: ",Cost," DistMax",DistMax," iMove",iMove
		!write(LOGFILE,'(A,I5,A,F15.0,A,I10,A,I10)') "Cost ",i3," iter is: ",Cost," DistMax",DistMax," iMove",iMove

		call system_clock(tend)
    
		write(*,*) "Outputting Iteration status for this iteration"
		!write(LOGFILE,*) "Time spent in iteration ",i3," is ",real(tend - tstart)/real(trate)
		write(*,*) "Time spent in iteration ",i3," is ",real(tend - tstart)/real(trate)

		if (FinalLoop.eq.1) then
      exit
		endif		
	
		write(*,*) "Checking convergence"
		if ((Cost - CostPrev)/CostPrev .lt. 1e-12) then
		  !write(LOGFILE,*) "Exiting because no more change in cost"
		  write(*,*) "Exiting because no more change in cost"
			FinalLoop = 1
	  endif

	  if (i3 >= NITERMAX) then 
    !write(LOGFILE,*) "FINAL ITERATION HIT, EXIT"
      write(*,*) "FINAL ITERATION HIT, EXIT"
      FinalLoop = 1
    endif
	  
	  costPrev = Cost
	  !write(LOGFILE,*) "Time spent on cost: ",real(tend - tstart)/real(trate)
  enddo
  
  call GenNAtRNow(wPrev,wNxt,FinalRank)
  write(*,*) "Outputting NRagg"
  open(unit = fid,file = 'NRAgg.txt',status = 'replace',action = 'write')
  write(fid,'(I8)') FinalRank
  close(fid)		
  
  deallocate(BinMove)
  

  !write(LOGFILE,*) "Ranking completed"
  write(*,*) "Ranking completed"
  return
end subroutine doFastZ

program rankW
  use GlobalPars
  use GlobalVars
  use OMP_LIB
  
  implicit none
  
  real(8)     :: costOut
  integer(4)  :: DistMax
  integer(4), dimension(:),allocatable :: FinalRank
 
  integer(4) :: i1,i2,i3,ir,i5,WPerBin,tstart,tend,trate
  real(8)    :: TmpR1,TmpR2,r1,r2,r3,r4,r5,TmpR3,TmpR4,TmpR5
  character(500) :: cwd

  call getcwd(cwd)
  write(*,*) "Working in: ",trim(cwd)  
  
  !open(unit = LOGFILE,file = '../log/rankWLog.txt',status = 'replace',action = 'write')
  
  call ReadData  
  write(*,*) "NumAgentsSim Matches : ", NumAgentsSim
  write(*,*) "SizeBI Matches : ", SizeBI
  write(*,*) "Max firm ID : ", maxFirm
  !write(LOGFILE,*) "NumAgentsSim Matches : ", NumAgentsSim
  !write(LOGFILE,*) "SizeBI Matches : ", SizeBI
  !write(LOGFILE,*) "Max firm ID : ", maxFirm  

  allocate(FinalRank(NumAgentsSim))
	costOut = 0
	call doFastZ(costOut,FinalRank,DistMaxInGlo)
  write(*,*) "CLOSING DOWN"
	!close(LOGFILE)
end program rankW 
