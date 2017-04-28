;***********************************************************
; Create forcing file for use in SOM run.  "Forcing" includes
;   Q-flux, oceanic mixed-layer depth, and initial SST.
;   Initial SST data for SOM run comes from existing
;   fixed-SST run.
;***********************************************************

; Auhtor:  Jim Benedict jjb278@gmail.com
; Origin:  17 Nov 2015
; Modified:
;     


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"

begin
  
  print("")
  print("--- IN NCL PROGRAM: " + get_script_name() + " ---")
  
  DENSITY_ICE = 0.917E3    ; kg/m**3
  LF_0C       = 3.337E5    ; J/kg
  
  ; User options:
  doPlot         = False
  MODELversion   = "cesm2_0_alpha06h"
;  MODELversion   = "cesm2_0_beta03"
;  MODELversion   = "cesm1_2_2"
  CAMversion     = "cam4"               ; used in output file path (cam4, cam53, cam5x)
  simType        = "_CTL"      ;"_forPerturbedCO2"
         ; for CESM2 DECK runs, type of run (external forcing), e.g.: "_CTL", "_abrupt4xCO2", "_1pctCO2"
         ; It was decided that perturbed (abrupt4xCO2 and 1pctCO2) SOM runs should use Q-fluxes from
         ;   the control fixed-SST run but an initial SST field from the equilibrium state of the
         ;   control SOM run. If TDescriptor = "Tspun", use runName4initT, inPath4initT, and
         ;   date4initT to get initial SST field from SOM control sim.  Label "simType" will be
         ;   added as suffix to "camX.som.focing.aquaplanet.*.nc" file name.
         ; Basic instructions:
         ;   * For control SOM, set simType = "_CTL"
         ;   * For perturbed SOM runs, set simType to "_forPerturbedCO2" -and-
         ;     specify runName4initT, inPath4initT, and date4initT below to point to corresponding
         ;     control SOM run.
         ; For CESM1.2.2, set to ""
;  runName        = "FC4AQUAP_c203_sstQOBS_2degFV_cam5493_4xCO2"
;  runName        = "FC4AQUAP_c203_sstQOBS_2degFV_cam5493_SSTplus4"
;  runName        = "FC4AQUAP_c203_sstQOBS_1degFV_cam5493_CTL"     ; case from which Qfluxes are computed
;  runName        = "FC5AQUAP_sstQobs_1degFV_nconst_aeroOff"
;  runName        = "FC5AQUAP_sstQobs_2degFV_nconst_aeroOff"
;  runName        = "FC4AQUAP_c155_2degFV_MLDtest"
;  runName        = "FC5AQUAP_sstQobs_2degFV_nconst_c155"          ; case used to compute q-fluxes and initial SST
;  runName        = "FC4AQUAP_sstQobs_2degFV"                ; case used to compute q-fluxes and initial SST
;  runName        = "FC4AQUAP_sstQobs_2degFV_c155"          ; case used to compute q-fluxes and initial SST
;  runName        = "FC5AQUAP_sstQobs_1degFV_nconst_c155"    ; case used to compute q-fluxes and initial SST
;  runName        = "FC4AQUAP_sstQobs_1degFV"
  runName        = "FC4AQUAP_c206a_sstQOBS_1degFV_CTL_testClean02"
  gridName       = "1deg"                             ; horiz grid resolution of above case
  inPath         = "/glade/p/umia0018/"+runName+"/run"          ; where history files for above case exist
;  inPath         = "/glade/scratch/benedict/"+runName+"/run"          ; where history files for above case exist
;  outPath        = "/glade/u/home/benedict/ys/datain/cesm1_5_5.som.forcing"    ; directory where output forcing file will be written
  outPath        = "/glade/u/home/benedict/ys/datain"                          ; (use this for CESM1_2_2 runs)
  outPathPlot    = "/glade/u/home/benedict/ys/analysis/SOM_bcs" ; output directory for any plots
  
  qDescriptor = "Qza"     ; Default should be: "Qza"
  qEvolve     = "Fix"     ; Options:  Fix, Seas
  		; Currently supported options (Descriptor & Evolve are combined):
  		; Q0Fix:  Qflux = 0 globally, fixed in time (not seasonal)
  		; QzaFix: Qflux set to zonally averaged climatological time-mean value, fixed in time (not seasonal)
  		; QzaHsymFix: Qflux set to time mean, zonally averaged, and hemispherically (N/S) averaged value such that it's hemispherically symmetric 
  hDescriptor = "h30"
  ;hDescriptor = "h30"
  hEvolve     = "Fix"     ; Options:  Fix, Seas
  		; Currently supported options (Descriptor & Evolve are combined):
  		; h50Fix: Oceanic mixed-layer depth set to 50 m globally, fixed in time (not seasonal)
  tDescriptor = "Tspun"
  tEvolve     = "Fix"     ; Options:  Fix, Seas
  runName4initT = "CAM4AQUASOM_c203_1degFV_QzaFix_h30Fix_TspunFix_CTL"    ; only used if simType .ne. "_CTL"
  inPath4initT  = "/glade/scratch/benedict/"+runName4initT+"/run"
  date4initT    = "0020-12"
  		; !!! CRITICAL !!!  Initial atmospheric state not set here, must be set separately as 'ncdata' path in user_nl_cam.
  		; !!! CRITICAL !!!  For 'Tspun', user *MUST* indicate file from which spun-up state is read using 'SST_init_file' below.
  		; Currently supported options (Descriptor & Evolve are combined):
  		; TdefFix:  Surface temp set to default value, fixed in time (not seasonal)
  		; TspunFix: Surface temp set to spun-up state (indicated by SST_init_file, below), fixed in time (not seasonal)
  		; runName4initT:  Perturbed SOM runs (e.g. abrupt4xCO2) should use init T from equilibrium of control SOM run, not fixed-SST (QOBS)

  
  ; Beginning and end months to examine (inclusive) for climatological Q-flux, where 1=Jan, 2=Feb, etc.
  ;   Ex:  For Oct-Apr range, use mnBeg=11 and mnEnd=4
  yrBeg =  1
  mnBeg =  4      ; I set to "6" here to allow a 6-month spinup for the fixed-SST (fixed-season) run
  yrEnd =  1
  mnEnd =  12
  
  qfluxName   = "qdp"       ; name of Q-flux variable in SOM forcing file template
  mldName     = "hblt"      ; name of mixed-layer depth variable in SOM forcing file template
  tempName    = "T"         ; name of surface temperature variable in SOM forcing file template
  
  
  
  ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  ;         NOTE:  SST FILE USED FOR SPUN-UP CONDITIONS MUST BE DEFINED BELOW 
  ; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  
  


  ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ; Initial prep work
  if (gridName.eq."1deg") then
    gridDescriptor      = "fv09"
    gridDescriptorFull  = "fv0.9x1.25"
    SST_init_file = inPath+"/"+runName+".cam.h0.0001-01.nc"
    if(MODELversion .ne. "cesm1_2_2" .and. simType .ne. "_CTL") then
      SST_init_file = inPath4initT+"/"+runName4initT+".cam.h0." + date4initT + ".nc"
    end if
		; This can be the final monthly SST for the fixed-SST run.
		; This should cover both CAMversion = "cam4" and CAMversion = "cam53", as long as
		;   runName is consistent with CAMversion setting.  It could be changed if SST
		;   forcing will not come from the same file from which Q-fluxes are derived.
	SOMforcTemplateFile = "/glade/u/home/benedict/ys/datain/templates/som.forcing.aquaplanet.Q0h50m.fv09.edit.fromBPM.nc"
    origSource          = "/glade/p/cesm/cseg/inputdata/ocn/docn7/SOM/pop_frc.b.c40.B1850CN.f19_g16.100105.nc"
  else if (gridName.eq."2deg") then
    gridDescriptor      = "fv19"
    gridDescriptorFull  = "fv1.9x2.5"
    SST_init_file = inPath+"/"+runName+".cam.h0.0005-12.nc"
    if(MODELversion .ne. "cesm1_2_2" .and. simType .ne. "_CTL") then
      SST_init_file = inPath4initT+"/"+runName4initT+".cam.h0." + date4initT + ".nc"
    end if
		; This can be the final monthly SST for the fixed-SST run.
		; This should cover both CAMversion = "cam4" and CAMversion = "cam53", as long as
		;   runName is consistent with CAMversion setting.  It could be changed if SST
		;   forcing will not come from the same file from which Q-fluxes are derived.
	SOMforcTemplateFile = "/glade/u/home/benedict/ys/datain/templates/som.forcing.aquaplanet.Q0h50m.fv19.fromBPM.nc"
    origSource          = "/glade/p/cesm/cseg/inputdata/ocn/docn7/SOM/pop_frc.b.c40.B1850CN.f19_g16.100105.nc"
  else
    print("Grid " + gridName + " not currently supported. Exiting.")
    exit
  end if
  end if
  
  print("")
  print("SST_init_file: " + SST_init_file)
  print("")
  
  ; Time-evolution of forcings
  if(qEvolve.eq."Fix") then
    doQfluxSeasons = False    ; if False, Qflux equals time-mean irrespective of month;
                              ; otherwise, time-mean Qflux is seasonal; in both cases, Qflux = (12,nlat,nlon)
  end if
  
  ; Forcing descriptor ~ used in output file name
  forcingDescriptor = qDescriptor + qEvolve + "_" + \
                      hDescriptor + hEvolve + "_" + \
                      tDescriptor + tEvolve
  
  print("")
  print("---------------------------------------------")
  print("USER SETTINGS:")
  print("CAMversion: " + CAMversion)
  print("runName: " + runName)
  print("gridName: " + gridName)
  print("inPath: " + inPath)
  print("outPath: " + outPath)
  print("qDescriptor: " + qDescriptor)
  print("qEvolve: " + qEvolve)
  print("hDescriptor: " + hDescriptor)
  print("hEvolve: " + hEvolve)
  print("tDescriptor: " + tDescriptor)
  print("tEvolve: " + tEvolve)
  print("CAMversion: " + CAMversion)
  print("YY/MM begin: " + yrBeg + "/" + mnBeg)
  print("YY/MM end: " + yrEnd + "/" + mnEnd)
  print("gridDescriptor: " + gridDescriptor)
  print("gridDescriptorFull: " + gridDescriptorFull)
  print("SST_init_file: " + SST_init_file)
  print("SOMforcTemplateFile: " + SOMforcTemplateFile)
  print("forcingDescriptor: " + forcingDescriptor)
  print("---------------------------------------------")
  print("")
  print("")
  



  
  
  
  ; **************************************************************************************
  ; -------------------------------------
  ; Prep (may not be used later)
  monNames  = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  monDays   = (/  31.,  28.,  31.,  30.,  31.,  30.,  31.,  31.,  30.,  31.,  30.,  31./)
  if(sum(monDays).ne.365) then
    print("Must use noleap calendar. Exiting.")
    exit
  end if
  midMnDays = new(dimsizes(monDays),"float",-9999)   ; mid-month days: 15.5, 45.0, 74.5, ..., 349.5
  begMnDays = midMnDays                              ; beginning-of-month days: 1.0, 32.0, 60.0, ...
  endMnDays = midMnDays                              ; end-of-month days: 31.0, 59.0, 90.0. ... 
  
  midMnDays(0) = monDays(0) / 2.
  begMnDays(0) = 1.
  endMnDays(0) = monDays(0)
  do i = 1,dimsizes(monDays)-1
    midMnDays(i) = (2.*sum(monDays(:i-1))+monDays(i))/2.
    endMnDays(i) = sum(monDays(:i))
    begMnDays(i) = endMnDays(i-1) + 1.
  end do
  monDayShift = endMnDays - midMnDays
  fmt = "%6.1f"
;;  print("Actual month middays, beginning days, and end days:")
;;  print( monNames + sprintf(fmt,midMnDays) + sprintf(fmt,begMnDays) + sprintf(fmt,endMnDays) )
  
  

  
  
  ; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  ; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  ; -------------------------------------
  ; Open SOM forcing template file, read data
  fSOMtemplate = addfile(SOMforcTemplateFile, "r")
  vNames       = getfilevarnames(fSOMtemplate)
  nvar         = dimsizes(vNames)
  print("")
  print("Variable names in SOM forcing template file:")
  print(vNames)
  print("")
    
  
  ; -------------------------------------
  ; Open file for dynamic writing of data
  if(MODELversion .eq. "cesm1_2_2") then
    filo = outPath + "/" + \
           CAMversion + ".som.forcing.aquaplanet." + forcingDescriptor + \
           "." + gridDescriptor + simType + ".nc"
  else
    filo = outPath + "/" + MODELversion + ".som.forcing/" + \
           CAMversion + ".som.forcing.aquaplanet." + forcingDescriptor + \
           "." + gridDescriptor + simType + ".nc"
  end if
  print("Writing data to: " + filo)
  system("/bin/rm -f " + filo)               ; remove old file if exists
  fout = addfile(filo,"c")                   ; "pointer" to output file is fout
  setfileoption(fout,"DefineMode",True)
  fAtt                = True            ; assign file attributes
  fAtt@title          = "aqua-planet SOM forcing: " + forcingDescriptor + " on " + \
                        gridDescriptorFull
  fAtt@author         = "Jim Benedict (jjb278@gmail.com)"
  fAtt@from_script    = "/glade/u/home/benedict/ys/analysis/SOM_bcs/" + get_script_name()
  fAtt@source_template_file   = SOMforcTemplateFile
  fAtt@SST_init_file = SST_init_file
  fAtt@created        = systemfunc("date")
  fileattdef( fout, fAtt )            ; copy file attributes
  setfileoption(fout,"DefineMode",False)
  delete(fAtt)
    
    
    
    
    
    
  ; -------------------------------------
  ; Loop through SOM forcing file template variables. Read each variable, computed updated
  ;   fields as necessary, and write original or updated fields to new SOM forcing file. 
  do nv = 0,nvar-1
    
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; All variables that will -NOT- be modified from SOM forcing file template 
    if(vNames(nv).ne.qfluxName .and. vNames(nv).ne.mldName .and. vNames(nv).ne.tempName) then
      xIn = fSOMtemplate->$vNames(nv)$
      fout->$vNames(nv)$ = xIn
      delete(xIn)
    end if  
      
    
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; Modified Qflux
      if(vNames(nv).eq.qfluxName) then
      
        xIn = fSOMtemplate->$vNames(nv)$      ; Original Qflux from template file
      
        cmd = "ls " + inPath + "/*cam.h0.*.nc"
        fNamesAtm = systemfunc (cmd)
        fAllAtm = addfiles(fNamesAtm, "r")
  
        print(fNamesAtm)
        print("Number of input files to be scanned: " + dimsizes(fNamesAtm))
        print("Selected time range is: " + monNames(mnBeg-1) + " Yr" + yrBeg + " to " + \
                                           monNames(mnEnd-1) + " Yr" + yrEnd)  
  
        ; -------------------------------------
        ; Loop through single (monthly) files at a time:  each file contains a single
        ;   monthly average for each variable at each spatial point: (1,lev,lat,lon)
        m    = 0   ; counter for all available files
        msub = 0   ; counter only for files within selected time range
        do nf = 0,dimsizes(fNamesAtm)-1
  
          ; -------------------------------------
          ; Retrieve relevant dimension info from representative input file
          if(m.eq.0) then
            a0    = fAllAtm[nf]->FSNS(0,:,:)    ; representative input data snapshot
            lat   = fAllAtm[nf]->lat
            lon   = fAllAtm[nf]->lon
            nlat  = dimsizes(lat)
            nlon = dimsizes(lon)
            gausswgts = fAllAtm[nf]->gw                        ; (lat)   
      
            ; Define arrays
            maxTime    = 360                                              ; max number of months expected, user can increase this
            netSfcFlux = new((/maxTime,nlat,nlon/),"float",a0@_FillValue) ; holds total net surface energy fluxes
            qflux      = new((/12,nlat,nlon/),"float",a0@_FillValue)      ; holds monthly time-mean Q-fluxes (if .not.doQfluxSeasons, all 12 values will be identical)
            years      = new(maxTime,"integer",-999)                      ; year, for each monthly time step
            months     = years                                            ; month, for each monthly time step
          end if         ; end if m.eq.0
    
          print("Scanning file: " + fNamesAtm(nf))
          timeIn = fAllAtm[nf]->time
          timeIn = (/timeIn - 1/)       ; For CAM, time stamp for 0001-01 = "31 days since 0001-01-01" which is technically 0001-02-01 00:00Z,
                                        ;   even though the monthly average data represents January.  I am subtracting 1 day from the
                                        ;   time stamp to ensure proper handling of the data
          ntimIn = dimsizes(timeIn)
          ti = calendar_decode2(timeIn, -5)
          iyr  = ti(0,0)      ; year corresponding to current file
          imon = ti(0,1)      ; month corresponding to current file (1-->12)
          print(timeIn + "    " + iyr + "    " + imon + "    " + ti(0,2))
    
    
          ; -------------------------------------
          ; Analyze only those months within desired time range, otherwise skip to next month
          if( (iyr.eq.yrBeg.and.imon.ge.mnBeg) .or. \
              (iyr.gt.yrBeg.and.iyr.lt.yrEnd)  .or. \
              (iyr.eq.yrEnd.and.imon.le.mnEnd) ) then 

            print("   Reading data for yr/month: " + iyr + "/" + imon + "...")
            netSfcFlux(msub,:,:) =   fAllAtm[nf]->FSNS(0,:,:)  \
                                   - fAllAtm[nf]->FLNS(0,:,:)  \
                                   - fAllAtm[nf]->LHFLX(0,:,:) \
                                   - fAllAtm[nf]->SHFLX(0,:,:) \
                                   - ( (fAllAtm[nf]->PRECSC(0,:,:)) * LF_0C * DENSITY_ICE ) \
                                   - ( (fAllAtm[nf]->PRECSL(0,:,:)) * LF_0C * DENSITY_ICE )         ; (0,lat,lon)
                                       ; netSfcFlux: Total net surface energy flux, -z direction (into ocean)
                                       ; FSNS: Net SW radiation at top of model, -z direction (into ocean)
                                       ; FLNS: Net LW radiation at top of model, +z direction (into atmos)
                                       ; LHFLX: Surface latent heat flux, +z direction (into atmos)
                                       ; SHFLX: Surface sensible heat flux, +z direction (into atmos)
                                       ; PRECSC:  Convective snow rate (water equivalent) (m/s)
                                       ; PRECSL:  Large-scale (stable) snow rate (water equivalent) (m/s)
            
            years(msub)  = iyr
            months(msub) = imon                
            msub         = msub + 1    ; increment counter associated with only files within selected time range
  
          else      ; else if all times in current file are NOT within desired time range
     
            print("   Skipping following file (not in desired time range): " + fNamesAtm(nf))
    
          end if    ; end if any times in current file are within desired time range
    
          ; The following exist regardless of whether file times are within selected range
          ;   and need to be deleted
          delete(timeIn)
          delete(ti)
    
          m = m + 1   ; increment counter associated with all *available* files
        end do        ; end nf loop (all input files)
        
        ; -------------------------------------
        ; Compute temporal average
        qflux        = new((/12,nlat,nlon/),typeof(a0),a0@_FillValue)
        qflux_zeroGA = qflux            ; quick way to transfer metadata
        qfluxZA      = qflux
        qfluxZA_hsym = qflux
        qflux0       = qflux
        if(qEvolve.eq."Fix") then
          do i = 0,11
            ; qflux(i,:,:) = -1. * dim_avg_n_Wrap(netSfcFlux(:,:,:),0)
            qflux(i,:,:) = dim_avg_n_Wrap(netSfcFlux(:,:,:),0)    ; sign convention requires -NO- multiplication by -1, for "ocean perspective"
              ; "0" for average over entire time dimension, "-1" factor because netSfcFlux = -qflux, trailing missing values ignored
            ; Set qflux as its zonal mean value at each longitudinal point
;            print(qflux(3,20,:))
            za     = dim_avg_Wrap(qflux(i,:,:))       ; mean of right-most dimension (lon), za = (lat)
            zaHsym = 0.5 * (za(:)+za(::-1))
;            print(za)
            qfluxZA(i,:,:)      = conform_dims(dimsizes(qflux(i,:,:)),za,0)    ; 0 b/c za matches with 0th dimension of qflux(i,:,:) (lat)
            qfluxZA_hsym(i,:,:) = conform_dims(dimsizes(qflux(i,:,:)),zaHsym,0)    ; 0 b/c za matches with 0th dimension of qflux(i,:,:) (lat)
;            print(qfluxZA(3,20,:))
            print("Check qfluxes:")
            print( sprinti("%5i",i) + sprintf("%8.3f",lat) + \
                   sprintf("%12.4f",qfluxZA(i,:,0)) + sprintf("%12.4f",qfluxZA_hsym(i,:,0)) + \
                   sprintf("%12.4f",qfluxZA(i,:,90)) + sprintf("%12.4f",qfluxZA_hsym(i,:,90)) )
            print("")
            delete([/za,zaHsym/])
            ; For attempt in which global average of Q-flux is subtracted from each spatial point (CURRENTLY OBSOLETE)
            glbAvg_qflux = wgt_areaave(qflux(i,:,:),gausswgts,1.0,0)    ; last 0 allows missing vals, none expected
            qflux_zeroGA(i,:,:) = (/qflux(i,:,:) - glbAvg_qflux/)
            delete(glbAvg_qflux)
          end do
        else if (qEvolve.eq."Seas") then
          do i = 0,11
            indMonth = ind(months.eq.(i+1))
            ; qflux(i,:,:) = -1. * dim_avg_n_Wrap(netSfcFlux(indMonth,:,:),0)
            qflux(i,:,:) = dim_avg_n_Wrap(netSfcFlux(indMonth,:,:),0)    ; sign convention requires -NO- multiplication by -1, for "ocean perspective"
              ; "0" for average over each month (i+1), "-1" factor because netSfcFlux = -qflux, trailing missing values ignored
            ; Set qflux as its zonal mean value at each longitudinal point
            za = dim_avg_Wrap(qflux(i,:,:))       ; mean of right-most dimension (lon), za = (lat)
            qfluxZA(i,:,:) = conform_dims(dimsizes(qflux(i,:,:)),za,0)    ; 0 b/c za matches with 0th dimension of qflux(i,:,:) (lat)
            delete(za)
            ; For attempt in which global average of Q-flux is subtracted from each spatial point (CURRENTLY OBSOLETE)
            glbAvg_qflux = wgt_areaave(qflux(i,:,:),gausswgts,1.0,0)    ; last 0 allows missing vals, none expected
            qflux_zeroGA(i,:,:) = (/qflux(i,:,:) - glbAvg_qflux/)
            delete(glbAvg_qflux)
          end do
        else
          print("qEvolve setting " + qEvolve + " not supported. Exiting")
          exit
        end if
        end if
        
;        exit
    
        
        ; -------------------------------------
        ; Further adjustments to Q-fluxes, if desired
        qflux0 = 0.
        
        
        ; -------------------------------------
        ; Correct Q-flux metadata and write to updated SOM forcing file
        copy_VarMeta(xIn, qflux)
        qflux@sign_convention = "Heat into ocean > 0: FSNS - FLSN - LHFLX - SHFLX - (PRECSC + PRECSL)*RHOICE*Lf"
        qflux@RHOICE          = "" + sprintf("%16.5g",DENSITY_ICE) + " kg/m**3"
        qflux@LF_0C           = "" + sprintf("%16.5g",LF_0C) + " J/kg"
        qflux@source_case     = runName
        if(qEvolve.eq."Fix") then
          qflux@avg_windowYYYYMM = sprinti("%0.4d",yrBeg) + "-" + sprinti("%0.2d",mnBeg) + " to " + \
                                   sprinti("%0.4d",yrEnd) + "-" + sprinti("%0.2d",mnEnd)
        end if
        copy_VarMeta(xIn, qfluxZA)
        qfluxZA@zonal_average = "Zonal average has been applied"
        qfluxZA@source_case     = runName
        if(qEvolve.eq."Fix") then
          qfluxZA@avg_windowYYYYMM = sprinti("%0.4d",yrBeg) + "-" + sprinti("%0.2d",mnBeg) + " to " + \
                                     sprinti("%0.4d",yrEnd) + "-" + sprinti("%0.2d",mnEnd)
        end if
        copy_VarMeta(qflux, qflux_zeroGA)
        qflux_zeroGA@method = "Global avg of time-mean Qflux subtracted from each point"
        qflux_zeroGA@source_case     = runName
        if(qEvolve.eq."Fix") then
          qflux_zeroGA@avg_windowYYYYMM = sprinti("%0.4i",yrBeg) + "-" + sprinti("%0.2i",mnBeg) + " to " + \
                                          sprinti("%0.4i",yrEnd) + "-" + sprinti("%0.2i",mnEnd)
        end if
        printVarSummary(qflux)
        copy_VarMeta(xIn, qflux0)
        qflux0@zonal_average = "Zeroed out Qflux"
        
        if (qDescriptor.eq."Q0") then
          qflux_use = qflux0
        else if (qDescriptor.eq."Qza") then
          qflux_use = qfluxZA
        else if (qDescriptor.eq."QzaHsym") then
          qflux_use = qfluxZA_hsym
        else
          print("qDescriptor setting " + qDescriptor + " not supported. Exiting.")
          exit
        end if
        end if
        end if
        
        fout->$vNames(nv)$ = qflux_use
        delete(xIn)
        delete(qflux_use)
        
;;        print("")
;;        print("Glb avg of qflux_zeroGA: ")
;;        print(wgt_areaave(qflux_zeroGA,gausswgts,1.0,0))
;;        print("")
;;        print(lat(:) + "   " + qflux(0,:,{0.}) + "     " + qflux_zeroGA(0,:,{0.}))
         
      end if      ; end if vNames(nv) .eq. qfluxName
      
      
      
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; Modified oceanic mixed-layer depth
    if(vNames(nv).eq.mldName) then
      xIn = fSOMtemplate->$vNames(nv)$
      ;printVarSummary(xIn)
      
      ocean_mld = tofloat(str_get_cols(hDescriptor,1,-1))
      xIn = (/ocean_mld/)
      ; ... Can add more sophisticated MLD code here ...
      fout->$vNames(nv)$ = xIn
      delete(xIn)
    end if    
    
    
      
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; Modified SST, if requested, for "spun-up" SST initialization
    if(vNames(nv).eq.tempName) then
        
      xIn     = fSOMtemplate->$vNames(nv)$      ; Original T from template file
      tsSpun  = xIn                             ; to quickly transfer metadata
      
      ; If spin-up state requested, modify surface temperatures (here, "ts")  
      if(tEvolve.eq."Fix") then
        if (tDescriptor.eq."Tspun") then
          fTS = addfile(SST_init_file, "r")
          tsIn = fTS->TS                   ; single month of SST data (0,lat,lon)
          do i = 0,11
            tsSpun(i,:,:) = (/tsIn(0,:,:)/)    ; apply spun-up TS to all 12 months, to conform to forcing file template
          end do
          delete(tsIn)
          if(any(tsSpun.gt.100)) then
            tsSpun = tsSpun - 273.15
          else
            print("Review units of spun-up file and forcing file. Exiting.")
          end if
          tsSpun@source = SST_init_file
          printVarSummary(tsSpun)
          t_use = tsSpun
          delete(tsSpun)
        else if (tDescriptor.eq."Tdef") then
          print("Using default initial ocean temperature conditions.")
          t_use = xIn
        else
          print("tDescriptor setting " + tEvolve + " not currently supported. Exiting.")
          exit
        end if
        end if
      else if (tEvolve.eq."Seas") then
        print("tDescriptor setting " + tEvolve + " not currently supported. Exiting.")
        exit
      else
        print("tDescriptor setting " + tEvolve + " not currently supported. Exiting.")
        exit
      end if
      end if
      
      fout->$vNames(nv)$ = t_use
      delete(xIn)
      delete(t_use)

    end if            ; end if vNames(nv) .eq. tempName 
        
        
    
  end do         ; end nv loop (number of variables in SOM forcing file template)
    
  print("")
  print("Data written to: " + filo)
  print("")
    
    
    
    
    
  ; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  ; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  if(doPlot) then 
  
    ; Add plotting routine here, if desired
  
  end if          ; end if doPlot
    

end
