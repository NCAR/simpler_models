load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ;
  ; user set variables
  ;
  vnames  = (/"iCL","iCL2","iCLy"/)
  horizontal_resolution = "f09_f09" ; -res setting
  compset="FKESSLER"                ; compset used
  iday  = 12                        ; plot day
  output_format = "pdf"             ; output format

;******************************************************
; create plot
;******************************************************


  fnames =  systemfunc("ls *.h1.*")
  wks = gsn_open_wks(output_format,"terminator")
  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  fcnt = dimsizes(vnames)
  print("fcnt="+fcnt)
  print(fnames)


  time= fall[0]->time(iday)
  lon = fall[0]->lon
  lat = fall[0]->lat
  nlon=dimsizes(lon)
  nlat=dimsizes(lat)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap

  res                     = True         ; plot modifications desired
  res@gsnSpreadColors     = True         ; Use full colormap, but start
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True         ; Turn on contour fill
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@mpOutlineOn     = False       ; No continents
  res@mpCenterLonF = 180.0           ; Rotate the projection.

  plot = new(fcnt,graphic) 
  do k=0,fcnt-1
    print("plot "+k)
    var  = fall[0]->$vnames(k)$(iday,:,:)    ; Read some data; convert to 1D.i

    if (vnames(k).eq."iCLy") then
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF  = 3.98E-6
      res@cnMaxLevelValF  = 4.02E-6
      res@cnLevelSpacingF = 0.0015E-6
    end if

    plot(k) = gsn_csm_contour_map_ce(wks,var,res)
    delete(var)
  end do

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnMaximize         = True         ; Maximize size of plot in frame
  resP@txString   = "Day "+time+" (-compset "+compset+" -res "+horizontal_resolution+")"
  gsn_panel(wks,plot,(/fcnt,1/),resP)            ; now draw as one plot
  txres               = True
  frame(wks)
end
