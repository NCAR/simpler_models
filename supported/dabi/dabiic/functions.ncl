function du_dtheta(x:numeric,phi:numeric)
begin
  ; derivative of u wrt latitude
  nlev = dimsizes(x)
  dU = new((/nlev/),"double")

  if (phi .lt. 0) then
     dU(:) = (/0/)
     return dU
  end if

  muu = sin(phi*degtorad)
  lat_rad = phi * degtorad

  muu = sin(lat_rad)
  arg = pi*muu*muu

  dU(:) = umax * x * exp(- 0.5 * (x^2 - 1.d0)) *3*(sin(arg))^2*cos(arg)*pi*2*sin(lat_rad)*cos(lat_rad)

  return dU
end

;****dabip2004
function computeUdabip2004(x:numeric,phi:numeric)
; NOTE: x in km, phi in degrees
; returne U(1:nlev at latitude phi
begin
  BigU = new((/nlev/),"double")
  F = new((/nlev/),"double")

  if (phi.lt.0) then 
     BigU(:) = (/0/)
     return BigU
  end if

  muu = sin(phi*degtorad)
  if (phi.ge.0) then
    F(:)=0.5*( 1 - (tanh( (x(:)-z0)/delz0 )^(3.)) ) * sin( pi* x(:) / z1)     
    BigU(:)=u0*( sin(pi*muu^(2.)) )^(3.) * F(:)
    return BigU
  end if
end
;****


;****dabip2004
function computeDUDZdabip2004(x:numeric,phi:numeric)
begin
  DU = new( (/nlev/),"double")

  if (phi.lt.0) then 
    DU(:) = (/0.d0/)
    return DU
  end if

  muu = sin(phi*degtorad)
 
  DU(:)=0.5*u0*sin(pi*muu^(2.))^(3.) * ( \
   (pi/z1)*cos(pi*x(:)/z1) - \
   (pi/z1)*cos(pi*x(:)/z1)*(tanh( (x(:)-z0)/delz0))^(3.) - \
   sin(pi*x(:)/z1)*3.*(tanh( (x(:)-z0)/delz0))^(2.)*\
   ( 1. - (tanh( (x(:)-z0)/delz0))^(2.))*(1./delz0) )
    
  return DU 
end
;****  

;****dabip2004
function computeTUSdabip2004(z_col:numeric)
local t
begin

  zi = (/ 0, 11, 20, 32, 47, 51, 71, 80 /)
  dTdzi = (/ -6.5, 0., 1.0, 2.8, 0, -2.8, -2.0, 0 /)

  t_colr = new ( (/nlev/),"double")
  t_col = new ( (/nlev/),"double")
  z_colr = new ( (/nlev/),"double")
  z_colr = z_col(::-1)
  Tus = new ( (/8/),"double")

  Tus(0)=288.15
  do i=1,7
   Tus(i)=Tus(i-1) + dTdzi(i-1)*(zi(i)-zi(i-1))
  end do

  t_colr(:)=Tus(0) 
  do plev=0,nlev-1
   z=z_colr(plev)
   do i=0,6
    if ( (z.gt.zi(i)).and.(z.le.zi(i+1)) ) then 
     t_colr(plev)=Tus(i) + dTdzi(i)*(z-zi(i))
    end if
    if (z.gt.zi(7)) then 
     t_colr(plev)=Tus(7) + dTdz*(z-zi(7))
    end if 

   end do 
  end do

  t_col=t_colr(::-1)
  return t_col
end
;****


;*****dabip2004
function computeTdabip2004(x:numeric ,phi:numeric )
; phi is latitude at which to to compute T in degrees
; x is -Hlog(p/p0) (km)
; perform Gauss-Lobatto quadrature since we have ncl access to integration points and weights

local mu_gq, nu_gq, BigT, T_0

begin

  BigT=new( (/nlev/),"double")

  ;***********Southern Hemisphere
  BigT(:) = 0.
  if (phi.lt.0) then
    return BigT(:) 
  end if

  ;***********Northern Hemisphere
  gau_info = gaus_lobat(nquad)
  mm = gau_info(:,0)/90. ; quadrature points partitioning (-1,1)
  ww = gau_info(:,1)/ 2. ; weights (summing to 1.0)

  ; compute integration points running from 0 to phi
  integ_points = ( 1. + mm ) / 2 * phi
  integ_points_rad = integ_points*degtorad

  mu_gq  = sin(integ_points_rad);
  nu_gq  = tan(integ_points_rad);

  u = new((/nquad,nlev/),"double")
  do j = 0,nquad-1
    u(j,:)    = (/computeUdabip2004(x,integ_points(j))/)
  end do

  dudz = new((/nquad,nlev/),"double")
  do j = 0,nquad-1
    dudz(j,:) = (/computeDUDZdabip2004(x,integ_points(j))/)
  end do

  integrand = new((/nlev/),"double")
  integrand(:) = 0.d0
  do j = 0,nquad-1
    integrand(:) = integrand(:) + ww(j) * (omega * re * mu_gq(j) + u(j,:) * nu_gq(j)) * dudz(j,:)
  end do

  BigT(:) = -2.d0 * ( hrefdabip2004 / R ) * integrand(:) * phi * degtorad;

  return BigT
end
;****

;****computing global mean T (Isla 10 01 15)
function computeGlobalMean(tval:numeric,lon,lat)
begin
  nlon=dimsizes(lon)
  nlat=dimsizes(lat)
  latrad=lat*degtorad
  xwgt=new( (/nlon/),"double")
  ywgt=new( (/nlat/),"double")
  xwgt(:)=1.
  ywgt(:)=cos(latrad(:))
  gav=wgt_areaave(tval,ywgt,xwgt,0)
  return gav
end
;****
