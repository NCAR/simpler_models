begin
  ;***************************************************
  ;* Script for testing the output of the dabip2004  *
  ;* testcase.                                       * 
  ;*                                                 * 
  ;* Plotting:                                       *
  ;*  (1) relative vorticity on sigma=0.975 at       *
  ;*      midnight day 12                            *
  ;*  (2) vertical velocity at sigma=0.5, 45N and    * 
  ;*      midnight day 12                            * 
  ;*                                                 * 
  ;*  These are intended to replicate Figs 4 and 9   * 
  ;*  of Polvani et al 2004, MWR, 132, 2539-2553     *
  ;*                                                 *
  ;*  Replace cdf_path and cdf_name below to point   *
  ;*  toward your dabi test case output              * 
  ;*                                                 * 
  ;*  Isla Simpson 11 15 15                          * 
  ;***************************************************
 
  ; set output path and filename for dabi test case
  ; read in dimensions, U, V and OMEGA at midnight, day 12
  dayplot=12


  ;!!!!modify these paths to point toward your model output
  cdf_path = "/scratch/cluster/islas/archive/T85L30_test1/atm/hist/"
  cdf_name = "T85L30_test1.cam.h0.0001-01-01-00000.nc"

  in=addfile(cdf_path+cdf_name,"r") ; open netcdf
  lon=in->lon
  lat=in->lat
  lev=in->lev
  time=in->time(dayplot)
  hybm=in->hybm
  u=in->U(dayplot,:,:,:)
  v=in->V(dayplot,:,:,:)
  om=in->OMEGA(dayplot,:,:,:)

  ; calculate vorticity
  vort=new(dimsizes(u),typeof(u))
  div=new(dimsizes(u),typeof(u))
  uv2vrdvg(u,v,vort,div)

  ; obtain vorticity on sigma=0.975.  Note, assumes sigma levels 
  ; are used as in the default initial conditions i.e. hybm=sigma, 
  ; hyam=0. with the exception of the upper most level
  sigplot=0.975
  vort_0p975=linint1_n(hybm,vort,False,sigplot,0,0)

  ; obtain omega at 45N, sigma=0.5.  Note, assumes sigma levels.
  sigplotom=0.5
  latplotom=45.
  om45=linint1_n(lat,om,False,latplotom,0,1)
  om45_0p5=linint1_n(hybm,om45,False,sigplotom,0,0)

  ; open output file
  page=gsn_open_wks("pdf","dabiout") 

  ;*******************set up plot specs
  ; Color map : www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
  gsn_define_colormap(page,"GMT_polar")

  res                   = True
  res@gsnMaximize         = False         ; Maximize size of plot in frame
  res@gsnSpreadColors     = True         ; Use full colormap
  res@cnSpanFillPalette   = True
  res@cnFillOn            = True         ; Turn on contour fill
  res@cnFillMode          = "AreaFill"   ; Style of fill. 
  res@cnLinesOn           = True         ; Use contour lines
  res@cnLineLabelsOn      = False         ; No contour labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@lbBoxLinesOn        = True         ; labelbar box lines.
  res@lbTitleString       = "~F21~Vorticity (s~S~-1~N~)"
  res@lbTitlePosition     = "Bottom" 
  res@lbTitleFontHeightF = 0.02
  res@lbLabelFontHeightF = 0.015 
  res@pmLabelBarHeightF = 0.1
  res@lbBoxMinorExtentF = 0.2
  res@mpOutlineOn          = False
  res@mpFillOn             = False

  ; Plot region in Polvani et al 2004, MWR, Fig 4
  res@mpCenterLonF=180. 
  res@mpMinLatF = 20
  res@mpMaxLatF = 80
  res@mpShapeMode  = "FreeAspect"
  res@vpWidthF      = 0.8
  res@vpHeightF     = 0.4

  ; ***Plot Vorticity on sigma=0.975
  varplot=vort_0p975(0,:,:)
  varplot!1="lon"
  varplot!0="lat"
  varplot&lon=lon
  varplot&lat=lat

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = -7.5e-5
  res@cnMaxLevelValF = 7.5e-5
  res@cnLevelSpacingF = 1e-5

  res@tiMainString 	= "~F21~Vorticity, ~F33~s ="+sigplot+"~F21~, day="+time
  contour = gsn_csm_contour_map(page,varplot,res)

  ; ***Plot omega at sigma=0.5, 45N
  varplot2=om45_0p5(0,0,:)

  res2 	= True
  res2@tiMainString = "Testing"
  res2@trXMaxF = 360
  res2@tiMainString = "~F21~Vertical Velocity, ~F33~s = "+sigplotom+"~F21~, ~F33~f ~F21~= 45N, day="+time
  res2@tiMainFontHeightF = 0.021
  res2@tiXAxisString = "Longitude"
  res2@tiXAxisFontHeightF = 0.018
  res2@tiYAxisString = "Vertical Velocity (Pa s~S~-1~N~)"
  res2@tiYAxisFontHeightF = 0.018 
  res2@xyLineThicknesses = (/2.0/)

  y=(/-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2/)
  res2@tmYLMode = "Explicit"
  res2@tmYLValues = y
  res2@tmYLLabels = y

  printVarSummary(lon)
 
  plot = gsn_csm_xy(page,lon,varplot2,res2)


end
