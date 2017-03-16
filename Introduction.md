Welcome to the CESM Simpler Models github repo.
================================


How to use this repo
------------------------
The Simpler Models project *is not* a software package. 

We will be populating the repo with useful information about current and developmental "simpler" configurations of CESM. As we do so, we will try to keep the documentation up to date. Documentation can be found in the [gh-pages branch](http://ncar.github.io/simpler_models/doc/build/html/index.html) of the repository.

Please use the "issues" feature of github to discuss all aspects of CESM simpler models. Use labels to mark your issues to alert interested parties. The "issues" can be ideas for new configurations, questions about current configurations, discussion of developmental configurations, actual software issues, etc. Also, thoughts for how we should use this repository; including what form the documentation web pages should take versus what should the wiki contain and what kind of code/information/recipes/data/etc should be hosted. 

There will be wiki pages added as needed.


Supported Configurations
------------------------
With the release of CESM2, there will be several supported simpler configurations.
- [Aquaplanet](http://www.cesm.ucar.edu/models/simpler-models/aquaplanet.html) 
  + "APE" (aka fixed SST)
  + "SOM" (slab-ocean model)
  + Available for use with CAM4, CAM5, or CAM6 physics packages. Compsets use the finite volume dynamics (SE can be easily configured.)
- [Dry Dynamical Core](http://www.cesm.ucar.edu/models/simpler-models/dry-dynamical-core.html)
  + Adiabatic (baroclinic lifecycle)
  + Held-Suarez/Ideal Physics

In Development Configurations
-----------------------------
There are some additional configurations that are functional in the CESM2 release, but are not fully supported. [See the in development page](http://www.cesm.ucar.edu/models/simpler-models-indev/).
- Moist baroclinic wave with Kessler microphysics
- Toy terminator chemistry
