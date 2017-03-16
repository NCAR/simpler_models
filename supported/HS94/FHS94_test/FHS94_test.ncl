;***********************************************************
;* NCL script for testing the output of the FHS94 compset  *
;*                                                         *
;* Reading in 6 hourly instantaneous output (default) and  *
;* plotting..                                              *
;* 	Zonal mean zonal wind                              *
;*      Zonal mean eddy temperature variance               *
;*      Zonal mean northward eddy momentum flux            *
;*      Zonal mean northward eddy heat flux                *
;*                                                         *
;* all averaged over days 200 to 1200 of the integration   *
;*                                                         *
;* Replace cdf_path below to point toward the directory    *
;* containing your FHS94 test case output                  *
;*                                                         *
;* Isla Simpson 08 07 16                                   *
;***********************************************************   

;*************plotting procedure
procedure contour_zm_linearp(wks,data[*][*]:numeric,ci[1]:numeric, \
cmin[1]:numeric,cmax[1]:numeric,plots[*]:graphic, \
iplot[1]:numeric)

begin
;set up contour levels
 ncontours=toint((cmax-cmin)/ci)+1
 levels=ispan(0,ncontours-1,1)
 flevels=tofloat(levels)
 flevels=cmin + flevels*ci

;place line at every second contour, exclude zero
 lconts=new(ncontours,string)
 lconts(:)="NoLine"
 izero=ncontours/2
 lconts(izero::2)="LineandLabel"
 lconts(izero:0:-2)="LineandLabel"

;define colour map
 gsn_define_colormap(wks,"BlueWhiteOrangeRed")

;set up plotting resources
 res     = True
 res@gsnDraw = False ; do not draw until the end
 res@gsnFrame = False ; do not automatically advance 'frame'

 res@trYReverse  = True ; reverse Y axis

 res@cnFillOn = True ; color fill

 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels = flevels
 ; contour every second line
 res@cnMonoLevelFlag=False
 res@cnLevelFlags = lconts
 res@gsnContourZeroLineThicknessF=0. ;don't plot zero line
 res@gsnContourNegLineDashPattern = 2
 res@cnLineThicknessF=2.

 ;contour labelling
 res@cnLineLabelsOn = True
 res@cnExplicitLineLabelsOn=False

;controlling label bar
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@lbBoxLinesOn        = True         ; labelbar box lines.
  res@lbTitlePosition     = "Bottom"
  res@lbTitleFontHeightF = 0.02
  res@lbLabelFontHeightF = 0.015
  res@pmLabelBarHeightF = 0.1
  res@lbBoxMinorExtentF = 0.2
  res@lbBoxSeparatorLinesOn=False

  plots(iplot)=gsn_csm_contour(wks,data,res)
  return(plots)
end
;*************end plotting procedure



;*************MAIN PROGRAM STARTS HERE
begin

  ; !!!modify this paths to point toward your model output
  cdf_path="/scratch/cluster/islas/archive/HS_T42L30/atm/hist/"
 
  ; opening up 6 hourly files 
  ncfiles=systemfunc("ls "+cdf_path+"*h1*.nc")
  nfiles=dimsizes(ncfiles)

  f=addfiles(ncfiles,"r")

  timetotal=f[:]->time
  lon=f[0]->lon
  lat=f[0]->lat
  lev=f[0]->lev

  ntimetot=dimsizes(timetotal)
  nlev=dimsizes(lev)
  nlat=dimsizes(lat)
  nlon=dimsizes(lon)
 
  counttime=0
  ; loop over h1 netcdfs
  do ifile=0,nfiles-1
    print ( (/ncfiles(ifile)/) )
    ut:=f[ifile]->U
    uprime:=dim_rmvmean_Wrap(ut) ; deviation from the zonal mean

    if ( ifile.eq.0 ) then 
      vptp=new( (/ntimetot,nlev,nlat/),typeof(ut))
      upvp=new( (/ntimetot,nlev,nlat/),typeof(ut))
      tptp=new( (/ntimetot,nlev,nlat/),typeof(ut))
      u=new( (/ntimetot,nlev,nlat/),typeof(ut))
    end if

    vt:=f[ifile]->V
    vprime:=dim_rmvmean_Wrap(vt) ; deviation from the zonal mean

    tt:=f[ifile]->T
    tprime:=dim_rmvmean_Wrap(tt) ; deviation from the zonal mean

    time:=f[ifile]->time

    ;calculate v'T'
    vptptemp=uprime
    vptptemp=(/vprime*tprime/)

    ; calculate u'v'
    upvptemp=uprime
    upvptemp=(/uprime*vprime/)

    ; calculate T'T'
    tptptemp=uprime
    tptptemp=(/tprime*tprime/)

    ;calculate zonal mean of U and eddy fluxes
    vptpzm=dim_avg_Wrap(vptptemp(time|:, lev|:, lat|:, lon|:))
    tptpzm=dim_avg_Wrap(tptptemp(time|:, lev|:, lat|:, lon|:))
    upvpzm=dim_avg_Wrap(upvptemp(time|:, lev|:, lat|:, lon|:))
    uzm=dim_avg_Wrap(ut(time|:, lev|:, lat|:, lon|:))

    delete(vptptemp)
    delete(tptptemp)
    delete(upvptemp)
    delete(ut)

    ; accumulate u and eddy fluxes from each file
    vptp(counttime:counttime+dimsizes(time)-1,:,:)=vptpzm(:,:,:)
    tptp(counttime:counttime+dimsizes(time)-1,:,:)=tptpzm(:,:,:)
    upvp(counttime:counttime+dimsizes(time)-1,:,:)=upvpzm(:,:,:)
    u(counttime:counttime+dimsizes(time)-1,:,:)=uzm(:,:,:)

    delete(vptpzm)
    delete(tptpzm)
    delete(upvpzm)
    delete(uzm)

    counttime=counttime+dimsizes(time)
  end do

  ; assign time axes to variables
  vptp&time=timetotal
  tptp&time=timetotal
  upvp&time=timetotal
  u&time=timetotal  
  
  ; grab out days 200 to 1200
  ntimeuse=1000*4
  vptp:=vptp(200*4:200*4+ntimeuse-1,:,:)
  tptp:=tptp(200*4:200*4+ntimeuse-1,:,:)
  upvp:=upvp(200*4:200*4+ntimeuse-1,:,:)
  u:=u(200*4:200*4+ntimeuse-1,:,:)

  ; take the time average
  vptpclim=dim_avg_Wrap(vptp(lev|:, lat|:, time|:))
  tptpclim=dim_avg_Wrap(tptp(lev|:, lat|:, time|:))
  upvpclim=dim_avg_Wrap(upvp(lev|:, lat|:, time|:))
  uclim=dim_avg_Wrap(u(lev|:, lat|:, time|:))

  ;set units and long_name for plotting purposes
  vptpclim@long_name="Northward eddy heat flux"
  vptpclim@units="Km/s"

  tptpclim@long_name="Eddy temperature variance"
  tptpclim@units="K^2"

  upvpclim@long_name="Northward eddy momentum flux"
  upvpclim@units="m^2/s^2"

  uclim@lon_name="Zonal mean zonal wind"
  uclim@units="m/s"

  ;open up workspace
  wks=gsn_open_wks("pdf","FHS94_test")

  ; plot the plots
  plots=new(4,graphic)
  contour_zm_linearp(wks,uclim,1,-40,40,plots,0)
  contour_zm_linearp(wks,tptpclim,5,-40,40,plots,1)
  contour_zm_linearp(wks,upvpclim,4,-120,120,plots,2)
  contour_zm_linearp(wks,vptpclim,1,-40,40,plots,3)

 
  resp=False
  gsn_panel(wks,plots,(/2,2/),resp)

end
