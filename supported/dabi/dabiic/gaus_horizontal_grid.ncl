    ;===================================================================
    ;  Define horizontal grid
    ;===================================================================

       if (res .eq. "8x16") then
           nlat = 8 
           nlon = 16 
       end if

       if (res .eq. "64x128") then
           nlat = 64 
           nlon = 128 
       end if

       if (res .eq. "128x256") then
           nlat = 128
           nlon = 256 
       end if

       if (res .eq. "256x512") then
           nlat = 256 
           nlon = 512 
       end if

       if (res .eq. "512x1024") then
           nlat = 512
           nlon = 1024
       end if

       gaus_info = gaus(nlat/2) ;fspan(-90.0d0+90.0d0/nlat,90.0d0-90.d0/nlat,(/nlat/))

       lat = gaus_info(:,0)
       lat!0="lat"
       lat@long_name = "latitude"
       lat@units = "degrees_north"

       gw = gaus_info(:,1)
       gw!0 = "lat"
       gw@long_name = "gauss weights"

       lon = fspan(0.d0,360.-360./nlon,(/nlon/))
       lon!0 = "lon"
       lon@long_name = "longitude"
       lon@units = "degrees_east"

