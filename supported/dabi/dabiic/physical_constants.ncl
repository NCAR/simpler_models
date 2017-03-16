    ;===================================================================
    ; math
    ;===================================================================

       pi = 3.141592653589793238462643383279502
       degtorad      = pi/180.d0      ; convert degrees(CAM) to radians

    ;===================================================================
    ; gas laws
    ;===================================================================

       SHR_CONST_BOLTZ   = 1.38065d-23; Boltzmann's constant
       SHR_CONST_AVOGAD  = 6.02214d26 ; Avogadro's number
       SHR_CONST_RGAS    = SHR_CONST_AVOGAD*SHR_CONST_BOLTZ
       SHR_CONST_MWDAIR  = 28.966d0 ; molar mass of dry air
       ; R_specific for dry air J/kg/K 
       ;R = SHR_CONST_RGAS/SHR_CONST_MWDAIR ; 287.04d0
       R=287.00d0
       kappa = 2.d0/7.d0;
       ;cp = R/kappa;

    ;===================================================================
    ; typical atmospheric model constants
    ;===================================================================

       href = 7.5d0 ; reference scale height
       hrefdabip2004 = 7.34d0 ; reference scale height for Polvani et al (2004) DABI case

       secondsperday = 86400          ; seconds per day
       re=6.371d6                   ; CAM radius of earth meters
       secondsperday_true = 86164.0d0
       g     = 9.806d+0;            ; acceleration of gravity (surface)
       omega = 7.292e-5             ; angular rotation earth

    ;===================================================================
    ; Shear Flow constants
    ;===================================================================

       lat_rad_s = 35.d0*degtorad
       delta_s = 20.d0*degtorad
       u_s_peak = 45.d0

