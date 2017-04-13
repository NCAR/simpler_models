=========================================
Aquaplanet Slab Ocean Model Documentation
=========================================

The aquaplanet SOM default configuration differs slightly from the standard SOM. First, the sea ice is removed by default by specifying a stub ice model in the compset definition. Second, the slab ocean is given a uniform 30 m depth in the default forcing file, following the TRACMIP specification [1]_. Finally, the forcing file contains the bottom-of-the-slab Q-fluxes that are not computed from a fully-coupled simulation. Instead, the "test" cases (e.g., EC6AQUAPtest) contain a default forcing file with zero Q-fluxes; these may be replaced by user-defined forcing via the ``DOCN_SOM_FILENAME`` variable in the docn namelist. In the scientifically supported compsets (e.g., EC6AQUAP), a default forcing file is used that contains Q-flux values computed from a prescribed SST aquaplanet. The method is from Kiehl et al. (2006) [2]_, termed the "old way" in the `SOM Forcing document`_. The equation that is used to derive the Q-flux is

.. math::
  \rho c_p h \frac{\partial \mathrm{SST}}{\partial t} = F_{\mathrm{net}} + Q_{\mathrm{flx}}

In the prescribed SST aquaplanet, however, the SST is constant, so the expression reduces to

.. math::
    F_{\mathrm{net}} = -Q_{\mathrm{flx}}

so the Q-flux is the inverse of the net ocean surface energy budget, which can be written

.. math::
   -F_{\mathrm{net}} = Q_{\mathrm{flx}} = R_{\mathrm{net}} - H - L_vE - L_f \rho_{\mathrm{ice}} P_{\mathrm{ice}}

where the rhs terms are the net downward radiative flux, the sensible heat flux, the latent heat flux, and the heat required to melt frozen precipitation, respectively.  The aquaplanet Q-flux is derived from monthly output from a 5-year simulation, then averaged over time and longitude. An NCL script to calculate the Q-flux is provided on the `CESM Simpler Models`_ github site.

Other variables in the SOM forcing file are set to zero (e.g., U, V), global average values (e.g., S), or to aquaplanet-appropriate values (e.g., mask = 1 everywhere). 

Aspects of the simulated climate in the SOM Aquaplanet are documented by Benedict et al. [3]_.



.. _Kiehl et al. (2006): http://dx.doi.org/10.1175/JCLI3747.1
.. _Voigt et al., 2016: http://dx.doi.org/10.1002/2016MS000748
.. _SOM Forcing document: http://www.cesm.ucar.edu/models/ccsm4.0/data8/SOM.pdf
.. _CESM Simpler Models: https://github.com/NCAR/simpler_models


.. [1] Voigt, A., et al., 2016: The tropical rain belts with an annual cycle and a continent model intercom- parison project: TRACMIP. Journal of Advances in Modeling Earth Systems, 8 (4), 1868–1891, doi: 10.1002/2016MS000748, URL http://dx.doi.org/10.1002/2016MS000748.
.. [2] Kiehl, J. T., C. A. Shields, J. J. Hack, and W. D. Collins, 2006: The climate sensitivity of the community climate system model version 3 (CCSM3). Journal of Climate, 19 (11), 2584–2596, doi:10.1175/JCLI3747.1, URL http://dx.doi.org/10.1175/JCLI3747.1.
.. [3] Benedict, J. J., B. Medeiros, A. C. Clement, and A. Pendergrass, 2017: Sensitivities of the Hydrologic Cycle to Model Physics, Grid Resolution, and Ocean Type in the Aquaplanet Community Atmosphere Model. Journal of Advances in Modeling Earth Systems, *submitted*. 
