Aquaplanet User Guide (QP and QS compsets)
==========================================

Aquaplanets are configurations of global atmospheric models that have no landmasses and saturated lower boundaries. The aquaplanet compsets in CESM2 provide a convenient way to configure CAM with prescribed, zonally symmetric SST, a user-supplied SST dataset, or a slab-ocean lower boundary. The surface is controlled through the data ocean model. There are a standard set based on the AquaPlanet Experiment project (APE; Neale & Hoskins [NH]_, Williamson et al. [W]_). The advantage of an aquaplanet configuration is that it allows the user to run the full CAM parameterization suite while retaining much simpler surface conditions than the complex combination of land, ocean, and sea-ice in the real world.  The CAM5 aquaplanet configuration is described by Medeiros et al. [MWO]_

There are six Q compsets available in CESM2:

* QPC6
* QPC5
* QPC4
* QSC6
* QSC5
* QSC4

where the P stands for Prescribed SST and the S stands for Slab-Ocean
Model, and the number is the physics package that is used (i.e., CAM4, CAM5,
CAM6).


Example 1: Default Aquaplanet with prescribed SST
-----------------------------------------------------------
To run the standard CAM6 aquaplanet, simply supply the compset name::

  cd cime/scripts
  ./create_newcase --case aqua_case --compset QPC6 --res f09_f09_mg17
  cd aqua_case
  ./case.setup
  ./case.build
  ./case.submit

By default initial conditions from a previous aquaplanet simulation are used. The SST pattern is the APE "QOBS" option, which is used in APE and CFMIP protocols. The atmospheric ozone is specified to be that used for APE. Aerosol emissions are neglected except for sea salt (which is diagnostic), see Medeiros et al. [MWO]_ for details.

Example 2: Default Aquaplanet with Slab-Ocean Model
-----------------------------------------------------------
To run the standard CAM6 aquaplanet with a 30 m uniform slab-ocean, simply supply the compset name::

  cd cime/scripts
  ./create_newcase --case aqua_case --compset QSC6 --res f09_f09_mg17
  cd aqua_case
  ./case.setup
  ./case.build
  ./case.submit

Note that the slab-ocean model has no ocean heat transport by default; the user must specify an appropriate "qflux" file. To specify such a file::

  ./xmlchange --file env_run.xml --id DOCN_SOM_FILENAME --val path/to/file.nc


Example 3: Aquaplanet with alternate prescribed SST
-----------------------------------------------------------
All of the APE SST profiles are available. To use them invoke the long compset name with the user compset option::

  cd cime/scripts
  ./create_newcase --case cam5_3keq --compset 2000_CAM50_SLND_SICE_DOCN%AQP7_SROF_SGLC_SWAV --user-compset --res f09_f09_mg17 --run-unsupported
  cd cam5_3keq
  ./case.setup
  ./case.build
  ./case.submit

The example uses the 3KEQ SST pattern, which is specified with "AQP7" in the compset name. Also note this example switched to CAM5 physics by specifying "CAM50" in the compset name. The run-unsupported flag is required.

Example 4: Aquaplanet with user-specified SST dataset
-----------------------------------------------------------
An arbitrary SST dataset can be specified instead of the default APE SST. To do that, start with the default case, and then change the data ocean mode and specify the file::

  cd cime/scripts
  ./create_newcase --case aqua_sst_case --compset QPC4 --res f19_f19_mg17  --run-unsupported
  cd aqua_case
  ./case.setup
  ./xmlchange --file env_run.xml --id DOCN_MODE --val sst_aquapfile
  ./xmlchange --file env_run.xml --id DOCN_AQP_FILENAME --val sst.nc
  ./case.build
  ./case.submit

Where sst.nc is the user-supplied SST file, which follows the same conventions as SST files used for F compsets. Note this example swtiches to CAM4 physics on a 2-degree grid, so requires the run-unsupported flag.


.. [MWO] Medeiros, B., D. L. Williamson, and J. G. Olson, 2016: Reference aquaplanet climate in the com- munity atmosphere model, version 5. Journal of Advances in Modeling Earth Systems, doi: 10.1002/2015MS000593

.. [NH] Neale, R. B. and B. J. Hoskins, 2000a: A standard test for AGCMs including their physical parametrizations. I: The proposal. Atmos. Sci. Lett., 1, 101-107.

.. [W] David L. Williamson and Co-Authors, 2012: The APE Atlas. Technical report, National Center for Atmospheric Research. URL http://nldr.library.ucar.edu/repository/collections/TECH-NOTE-000-000-000-865.
