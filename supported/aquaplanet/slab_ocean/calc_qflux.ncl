function calc_qflux(FSNS, FLNS, LHFLX, SHFLX, PRECSC, PRECSL)
local LF_0C, DENSITY_ICE
begin
  ;; constants:
  LF_0C = 3.337e5 ; AMS Glossary value, J/kg
  DENSITY_ICE = 0.9167/1000. ;  kg/cm3  Wikipedia referencing CRC
  ;; calculation, requires inputs to be same size:
  qflux = (FSNS - FLNS) - LHFLX - SHFLX - (PRECSC*LF_0C*DENSITY_ICE) - (PRECSL*LF_0C*DENSITY_ICE)
  copy_VarCoords( FSNS, qflux ) ;; works even if there are no coords
  qflux@long_name = "derived qflux based on surface energy budget"
  qflux@units = "W m-2"
  return(qflux)  
end




begin

;; dT/dt = (1/(h*rho*cp))*(Fnet + Qflx)
;; we want to keep dT/dt = 0
;; => Qflx = -Fnet



;; USER: load your data
;;   SWnet  net downward shortwave (W/m2)
;;   LWnet  net upward longwave (W/m2)
;;   LH     latent heat flux (W/m2)
;;   SH     sensible heat flux (W/m2)
;;   PRECSC convective snow (m/s)
;;   PRECSL large-scale snow (m/s)
  

;; designate some variable that will be template for coords:

  lon = SH&lon
  lat = SH&lat
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  rlat = 4.*atan(1.)*lat/180.
  wgt = cos(rlat)
  wgt!0 = "lat"
  wgt&lat = lat


;; calculate Q-flux from input fields:
  Qflux = calc_qflux( SWnet, LWnet, LH, SH, PRECSC, PRECSL)

;; calc time and zonal average:
;;   assumes [time lat lon] are named dims
  tza = dim_avg_n( Qflux(lat|:, lon|:, time|:), (/1,2/) ) 
  
;; INFORMATION: check on the global average qflux:
;;    note: we do not adjust the global mean value to be zero.
  ga = wgt_areaave( Qflux, wgt, 1., 0 )
  
;; weigted global sum:
;; q_gsum = dim_sum_n( Fnet*conform( Fnet, wgt, 1), (/1,2/) )
;; print( q_gsum )
  
;; Expand to be 12 x lat x lon:
  Qout = new( (/12, nlat, nlon/), typeof(Qflux) )
  Qout!0 = "time"
  Qout!1 = "lat"
  Qout!2 = "lon"
  Qout&time = ispan(1, 12, 1)
  Qout&lat = lat
  Qout&lon = lon
  Qout@long_name = "ocean heat flux convergence"
;; EXPECTATION: This will be put into an existing SOM forcing file.
  
;; fill in values
  Qout = (/ conform( Qout, tza, 1 ) /)
  

;; write to output file:
;;   USER: specify the file you want to write.
;; Fout->qdp = Qout

end