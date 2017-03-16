
    ;===================================================================  
    ; This ncl script creates an initial condition file for 
    ; the FV/Eul CAM dynamical core
 
    ; Default initial condition set up (icase=0) is for the 
    ; dry adiabatic baroclinic instability test case of Polvani et al
    ; 2004 (dabip2004) (Polvani, Scott and Thomas, MWR, 132, 2539--2552)

    ; Setting icase=1 produces a 250K isothermal initial state with zero 
    ; winds for initializing a Held-Suarez test case.

    ; Adapted by Isla Simpson 10 01 15 
    ; Modifiations specific to the dabip2004 test case are within
    ; ****dabip2004
    ;
    ; ****
    ; Modifications specify to the Held-Suarez initial conditions are within
    ; ****hs1994
    ; 
    ; ****
    ; to generate a new test case, these sections can be modified
    ;==================================================================== 

    ;===================================================================  
    ;  load constants and functions
    ;===================================================================  

       ;icase=0 ;for Polvani et al (2004) 
       icase=1 ;for Held-Suarez (isothermal, zero wind)

       load "./physical_constants.ncl"

       ; vertical level options
       nlev = 30
       ;nlev = 40
       ;nlev = 60
       ;nlev = 120
       load "./levels.ncl"

       ; horizontal resolution options
       ;res = "64x128"
       res = "128x256"
       ;res = "256x512"
       ;res = "512x1024"
       load "./gaus_horizontal_grid.ncl"
 
       load "./constants.ncl"

       load "./functions.ncl"

    ;===================================================================  
    ;  Create File
    ;===================================================================  

       setfileoption("nc","Format","LargeFile")
       diro = "./"                         ; Output directory
  
       if (icase.eq.0) then 
        filo = "DABIp2004."+res+".L"+nlev+".nc"                 ; Output file name
       end if

       if (icase.eq.1) then
        filo = "HS1994."+res+".L"+nlev+".nc"
       end if 

       system("/bin/rm -f " + diro + filo) ; remove if exists
       fout  = addfile (diro + filo, "c")  ; open output file

    ;===================================================================
    ;  Time coordinate
    ;===================================================================
 
       ntime = 1

       time = (/0.d0/)
       time!0 = "time"
       time@long_name = "time" 
       time@units = "days since 2005-01-01 00:00:00" 
       time@calendar = "noleap" 
       time@bounds = "time_bnds" 

       date = (/20050101/)
       date!0="time"
       date@long_name = "current date (YYYYMMDD)" 

       datesec = (/0/)
       datesec!0="time"
       datesec@long_name = "current seconds of current date" 
      
    ;===================================================================
    ;  Pressure values
    ;===================================================================

       P0!0="ncl_scalar"
       P0@long_name = "reference pressure"
       P0@units = "Pa"

       PS = onedtond(fspan(P0,P0,ntime*nlat*nlon),(/ntime,nlat,nlon/))
       PS!0 = "time"
       PS!1 = "lat"
       PS!2 = "lon"
       PS@long_name = "Surface pressure"
       PS@units = "Pa"

       pressure_cross_section = new ( (/nlev,nlat/),"double")
       do i = 0,nlev-1
       do j = 0,nlat-1
          pressure_cross_section(i,j) = P0*(hyam(i)+hybm(i))
       end do
       end do

       ;****dabip2004
       if (icase.eq.0) then 
         x = hrefdabip2004*log(P0/pressure_cross_section)
       end if 
       if (icase.eq.1) then
         x = hrefdabip2004*log(P0/pressure_cross_section)
       end if
       ;**** 

    ;===================================================================
    ;  met fields
    ;===================================================================

       ; fields, dimensions, atts
       U = new((/ntime,nlev,nlat,nlon/), "double")
       U!0="time"
       U!1="lev"
       U!2="lat"
       U!3="lon"
       U@mdims = 1
       U@units = "m/s"
       U@long_name = "Zonal wind, staggered"
       U@cell_methods = "time: mean"

       V = new((/ntime,nlev,nlat,nlon/), "double")
       V!0="time"
       V!1="lev"
       V!2="lat"
       V!3="lon"
       V@mdims = 1
       V@units = "m/s"
       V@long_name = "Meridional wind, staggered"
       V@cell_methods = "time: mean"

       ;****dabip2004
       if (icase.eq.0) then 
         u_l = new( (/nlev,nlat/), "double")
         do plat = 0,nlat-1
           u_l(:,plat) = (/computeUdabip2004(x(:,plat),lat(plat))/)
         end do
       end if
       ;****

       ;****hs1994
       if (icase.eq.1) then 
         u_l = new( (/nlev,nlat/), "double")
         do plat = 0,nlat-1
            u_l(:,plat)=(/0.d0/)
         end do
       end if
       ; ****

       do ilat = 0,nlat-1
       do iilev = 0,nlev-1
          U(:,iilev,ilat,:)= (/u_l(iilev,ilat)/)
       end do
       end do

       V(:,:,:,:)= (/0.d0/)

    ;===================================================================
    ; Temperature, Potential Temp
    ;===================================================================

       T = onedtond(fspan(300.d,300.,ntime*nlev*nlat*nlon),(/ntime,nlev,nlat,nlon/))
       al_temp = onedtond(fspan(0.d,0.,nlev*nlat),(/nlev,nlat/))
       do plat = 0, nlat-1
         ;****dabip2004
         if (icase.eq.0) then 
           al_temp(:,plat) = computeTdabip2004(x(:,plat),lat(plat))
         end if
         ;****
       end do


       al_temp!0 = "lev"
       al_temp!1 = "lat"

       ;****dabip2004
       if (icase.eq.0) then 

         TUS=new((/nlev/),"double")
         TUS(:)=computeTUSdabip2004(x(:,0))
         do plev=0,nlev-1
          do plon=0,nlon-1 
           do plat=0,nlat-1
            T(:,plev,plat,plon)=al_temp(plev,plat)
           end do
          end do
          TGM=computeGlobalMean(T(0,plev,:,:),lon,lat)
          TCONST=TUS(plev)-TGM

          do plat=0,nlat-1
           do plon=0,nlon-1 
            if (lon(plon).le.180) then
             T(0,plev,plat,plon)= T(0,plev,plat,plon) + \
              t_hat*(1./(cosh(degtorad*( (lon(plon)-lambda0)/alph))^(2.)))* \
              (1./cosh(degtorad*( (lat(plat)-phi0)/bet))^(2.)) + TCONST
            else
             T(0,plev,plat,plon)= T(0,plev,plat,plon) + \
              t_hat*(1./(cosh(degtorad*((lon(plon)-360.)/alph))^(2.)))* \
              (1./cosh(degtorad*((lat(plat)-phi0)/bet))^(2.)) +TCONST
            end if
           end do
          end do   
 
         end do
        end if       
        ;****

       ;*****HS1994
       if (icase.eq.1) then 
         T(:,:,:,:)=250.0
       end if
       ;***************


       T!0="time"
       T!1="lev"
       T!2="lat"
       T!3="lon"
       T@long_name = "Temperature" 
       T@mdims = 1 
       T@units = "K" 

       fac = (1.d0/(hyam+hybm))^(kappa)
       potentialT = onedtond(fspan(300.d,300.,ntime*nlev*nlat*nlon),(/ntime,nlev,nlat,nlon/))
       do plev = 0,nlev-1
         potentialT(:,plev,:,:)=T(:,plev,:,:)*fac(plev)
       end do
       potentialT!0="time"
       potentialT!1="lev"
       potentialT!2="lat"
       potentialT!3="lon"
       potentialT@long_name = "Potential Temperature"
       potentialT@units = "K" 

  ;===================================================================  
  ; diagnostic values for debugging
  ;===================================================================  
 if( False ) then
  dudz_l = new((/nlev,nlat/),"double")
  do plat = 0,nlat-1
    dudz_l(:,plat) = (/computeDUDZ(pressure_cross_section(:,plat),lat(plat))/)
  end do
  dudz_l@long_name = "dudz_l"
  dudz_l!0="lev"
  dudz_l!1="lat"


  utanphi = new((/nlev,nlat/),"double")
  do plat = 0,nlat-1
    utanphi(:,plat) = (/computeU(pressure_cross_section(:,plat),lat(plat))/)*tan(degtorad*lat(plat))
  end do
  utanphi@long_name = "utanphi"
  utanphi!0="lev"
  utanphi!1="lat"


  aomegasinphi = new((/nlev,nlat/),"double")
  do plat = 0,nlat-1
    aomegasinphi(:,plat) = re*omega*sin(degtorad*lat(plat))
  end do
  aomegasinphi@long_name = "aomegasinphi"
  aomegasinphi!0="lev"
  aomegasinphi!1="lat"

  integrand = new((/nlev,nlat/),"double")
  do plat = 0,nlat-1
    integrand(:,plat) = -2*href/R*(aomegasinphi(:,plat)+utanphi(:,plat))*dudz_l(:,plat)
  end do
  integrand@long_name = "integrand"
  integrand!0="lev"
  integrand!1="lat"

 end if

    ;===================================================================
    ;  Diagnostics
    ;===================================================================

       du = new((/ntime,nlev,nlat,nlon/), "double")
       du!0="time"
       du!1="lev"
       du!2="lat"
       du!3="lon"
       du@mdims = 1
       du@units = "m/s"
       du@long_name = "Zonal wind, staggered"
       du@cell_methods = "time: mean"

       du_l = new ( (/nlev,nlat/), "double")
       do plat = 0,nlat-1
         du_l(:,plat) = (/du_dtheta(x(:,plat),lat(plat))/)
       end do

       do ilat = 0,nlat-1
       do iilev = 0,nlev-1
          du(:,iilev,ilat,:)= du_l(iilev,ilat)/re
       end do
       end do

    ;===================================================================
    ;  Potential vorticity
    ;===================================================================

       ph  = pres_hybrid_ccm (PS(:,:,:), P0, hyam, hybm)
       ph@long_name="Pressure"
       ph@units="Pa"

       dthetadp = center_finite_diff_n(potentialT,ph,False,0,1)
       dthetadp!0="time"
       dthetadp!1="lev"
       dthetadp!2="lat"
       dthetadp!3="lon"

       vrt = new((/ntime,nlat,nlev,nlon/), "double")
       earthrot = 2*omega*sin(lat*pi/180)
       do i = 0,nlev-1
         do j = 0,nlon-1
           vrt(0,:,i,j)   = (/du(0,i,:,j)/) + earthrot
         end do
       end do

       wrt = new((/ntime,nlat,nlev,nlon/), "double")
       wrt!0="time"
       wrt!1="lat"
       wrt!2="lev"
       wrt!3="lon"
       wrt@mdims = 1
       ; cam can only transport mass mixing ratios
       wrt@units = "kg/kg"
       wrt@long_name = "Potential vorticity, evolved as a mass mixing ratio"
       wrt@cell_methods = "time: mean"
       wrt@long_name="Potential Vorticity"
       wrt@units="kg/kg"
       wrt = vrt * dthetadp(time|:,lat|:,lev|:,lon|:) * (-9.81) * 1.e6 / 10000
       ; cam can only transport positive mixing ratios
       wrt=where(wrt.lt.0,0,wrt)

    ;===================================================================
    ;  tracer spec
    ;===================================================================

       tropo = new((/ntime,nlat,nlev,nlon/), "double")
       tropo!0="time"
       tropo!1="lat"
       tropo!2="lev"
       tropo!3="lon"
       tropo@mdims = 1
       tropo@units = "kg/kg"
       tropo@long_name = "tracer in the troposphere"
       tropo@cell_methods = "time: mean"
       tropo(:,:,:,:) = 0

       strat = new((/ntime,nlat,nlev,nlon/), "double")
       strat!0="time"
       strat!1="lat"
       strat!2="lev"
       strat!3="lon"
       strat@mdims = 1
       strat@units = "kg/kg"
       strat@long_name = "tracer in stratosphere"
       strat@cell_methods = "time: mean"
       strat(:,:,:,:) = 0

       th320 = new((/ntime,nlat,nlev,nlon/), "double")
       th320!0="time"
       th320!1="lat"
       th320!2="lev"
       th320!3="lon"
       th320@mdims = 1
       th320@units = "kg/kg"
       th320@long_name = "Tracer layer for theta between 310 and 330K"
       th320@cell_methods = "time: mean"
       th320(:,:,:,:) = 0

       th340 = new((/ntime,nlat,nlev,nlon/), "double")
       th340!0="time"
       th340!1="lat"
       th340!2="lev"
       th340!3="lon"
       th340@mdims = 1
       th340@units = "kg/kg"
       th340@long_name = "Tracer layer for theta between 330 and 350K"
       th340@cell_methods = "time: mean"
       th340(:,:,:,:) = 0

       ; lat_t is lat(ilev) at for simple linear Strat/Trop boundary for 290<theta<380
       lat_t  = conform_dims( (/ntime,nlat,nlev,nlon/), (55.-(2./3.)* href * log (1./(hyam+hybm))), 2)
       lat_ll = conform_dims( (/ntime,nlat,nlev,nlon/), lat, 1) ; latitude as a function of lat and lev

       one  = new((/ntime,nlat,nlev,nlon/), "double")
       one  = 1.
       zero = new((/ntime,nlat,nlev,nlon/), "double")
       zero = 0.

       strat = where( (potentialT(time|:,lat|:,lev|:,lon|:) .ge. 380.) .or. ((potentialT(time|:,lat|:,lev|:,lon|:) .ge. 290.) .and. (lat_ll.ge.lat_t)), one, zero)
       tropo = one - strat

       th320 = where( (potentialT(time|:,lat|:,lev|:,lon|:) .ge. 310.) .and. (potentialT(time|:,lat|:,lev|:,lon|:) .lt. 330.), one, zero )
       th340 = where( (potentialT(time|:,lat|:,lev|:,lon|:) .ge. 330.) .and. (potentialT(time|:,lat|:,lev|:,lon|:) .lt. 350.), one, zero )


    ;===================================================================
    ; explicitly declare file definition mode. Improve efficiency.
    ;===================================================================

        setfileoption(fout,"DefineMode",True)

    ;===================================================================
    ; create global attributes of the file
    ;===================================================================

        fAtt               = True            ; assign file attributes
	fAtt@title         = "Initial condition file for lc1 case of Polvani"
	fAtt@source_file   = "ncl script"
	fAtt@Conventions   = "None"   
	fAtt@creation_date = systemfunc ("date")        
	fileattdef( fout, fAtt )             ; copy file attributes    

    ;===================================================================
    ; predefine the coordinate variables and their dimensionality
    ;===================================================================

       dimNames = (/"time", "lat", "lon", "lev","ilev"/)  
       dimSizes = (/ -1   ,  nlat,  nlon, nlev, nilev/) 
       dimUnlim = (/ True , False, False, False, False/)   
       filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;===================================================================
    ; predefine the the dimensionality of the variables to be written out
    ;===================================================================

       filevardef(fout,        "time" ,typeof(time)          ,getvardims(time)) 
       filevardef(fout,        "date" ,typeof(date)          ,getvardims(date))          
       filevardef(fout,     "datesec" ,typeof(datesec)       ,getvardims(datesec))          

       filevardef(fout,         "lev" ,typeof(lev)           ,getvardims(lev) ) 
       filevardef(fout       , "ilev" ,typeof(ilev)          ,getvardims(ilev) )
       filevardef(fout,        "hyai" ,typeof(hyai)          ,getvardims(hyai))          
       filevardef(fout,        "hyam" ,typeof(hyam)          ,getvardims(hyam))          
       filevardef(fout,        "hybi" ,typeof(hybi)          ,getvardims(hybi))          
       filevardef(fout,        "hybm" ,typeof(hybm)          ,getvardims(hybm))          
       filevardef(fout,          "P0" ,typeof(P0)            ,getvardims(P0))          
       filevardef(fout,          "PS" ,typeof(PS)            ,getvardims(PS))          

       filevardef(fout,         "lat" ,typeof(lat)           ,getvardims(lat))                   
       filevardef(fout,         "lon" ,typeof(lon)           ,getvardims(lon))                     
       filevardef(fout,          "gw" ,typeof(gw)            ,getvardims(gw))          

       filevardef(fout,          "T" ,typeof(T)            ,getvardims(T))    
       ;filevardef(fout,          "potentialT" ,typeof(potentialT)            ,getvardims(potentialT))    
       filevardef(fout,          "U" ,typeof(U)            ,getvardims(U))          
       filevardef(fout,          "V" ,typeof(V)            ,getvardims(V))          

      ; filevardef(fout,       "strat" ,typeof(strat)         ,getvardims(strat))
      ; filevardef(fout,       "tropo" ,typeof(tropo)         ,getvardims(tropo))
      ; filevardef(fout,      "th320" ,typeof(th320)         ,getvardims(th320))
      ; filevardef(fout,      "th340" ,typeof(th340)         ,getvardims(th340))
      ; filevardef(fout,         "wrt" ,typeof(wrt)            ,getvardims(wrt))

    ;===================================================================
    ; Copy attributes associated with each variable to the file
    ; All attributes associated with each variable will be copied.
    ;====================================================================

       filevarattdef(fout,"time" ,time)                ; copy time attributes
       filevarattdef(fout,"date" ,date)                ; copy   date attributes
       filevarattdef(fout,"datesec",datesec)           ; copy   datesec attributes

       filevarattdef(fout,"lev"  ,lev)                 ; copy  lev attributes
       filevarattdef(fout,"ilev" ,ilev)                ; copy ilev attributes
       filevarattdef(fout,"hyai" ,hyai)                ; copy   hyai attributes
       filevarattdef(fout,"hyam" ,hyam)                ; copy   hyam attributes
       filevarattdef(fout,"hybi" ,hybi)                ; copy   hybi attributes
       filevarattdef(fout,"hybm" ,hybm)                ; copy   hybm attributes
       filevarattdef(fout,"P0"   ,P0)                  ; copy   P0 attributes
       filevarattdef(fout,"PS"   ,PS)                  ; copy   PS attributes

       filevarattdef(fout,"lat"  ,lat)                 ; copy  lat attributes
       filevarattdef(fout,"lon"  ,lon)                 ; copy  lon attributes
       filevarattdef(fout,"gw"   ,gw)                  ; copy   gw attributes

       filevarattdef(fout,"T"  ,T)                  ; copy    T attributes
       ;filevarattdef(fout,"potentialT"  ,potentialT)                  ; copy    T attributes
       filevarattdef(fout,"U"  ,U)                  ; copy   U attributes
       filevarattdef(fout,"V"  ,V)                  ; copy   V attributes

;       filevarattdef(fout,"strat" ,strat)            ; copy   strat attributes
;       filevarattdef(fout,"tropo" ,tropo)            ; copy   tropo attributes
;       filevarattdef(fout,"th320",th320)           ; copy   th320 attributes
;       filevarattdef(fout,"th340",th340)           ; copy   th340 attributes
;       filevarattdef(fout,"wrt"   ,wrt)              ; copy   wrt attributes

    ;===================================================================
    ; explicitly exit file definition mode.
    ;===================================================================

        setfileoption(fout,"DefineMode",False)

    ;===================================================================
    ; output the data values since the dimensionality and attributes have
    ; been predefined. The "(/", "/)" syntax tells NCL to only output the
    ; data values to the predefined locations on the file.
    ;====================================================================

       fout->time         = (/time/)     
       fout->date         = (/date/)
       fout->datesec      = (/datesec/)

       fout->lev          = (/lev/)
       fout->ilev         = (/ilev/)
       fout->hyai         = (/hyai/)
       fout->hyam         = (/hyam/)
       fout->hybi         = (/hybi/)
       fout->hybm         = (/hybm/)
       fout->P0           = (/P0/)
       fout->PS           = (/PS/)

       fout->lat          = (/lat/)
       fout->lon          = (/lon/) 
       fout->gw           = (/gw/)

       fout->T            = (/T/)
       ;fout->potentialT            = (/potentialT/)
       fout->U            = (/U/)
       fout->V            = (/V/)

;       fout->strat   = (/strat/)
;       fout->tropo   = (/tropo/)
;       fout->th320  = (/th320/)
;       fout->th340  = (/th340/)
;       fout->wrt     = (/wrt/)
