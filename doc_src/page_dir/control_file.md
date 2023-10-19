title: Control file
---

@note
The official documentation for this code is contained in [USGS Techniques and Methods Report 6-A59](https://pubs.er.usgs.gov/publication/tm6A59). This online documentation is a work-in-progress. While we will try to keep this as up-to-date as possible, you may find occasionally find instances where the actual behavior of the code differs from the official documentation or from this online documentation. Please consider submitting an issue on the [GitHub repository](https://github.com/smwesten-usgs/swb2/issues) if you find such differences between code and documentation.
@endnote

SWB requires a combination of gridded and tabular files as input and produces several gridded netCDF files and logfiles as output. This section discusses the control file required by SWB.

Several different input files must be in place for an SWB simulation to work. The most important of these files is the SWB control file. The control file specifies the location of input data grids and climate datasets and is the place where the user may select specific program options. A lookup table, or possibly several lookup tables, are required to relate SWB model parameters to the land use or hydrologic soil group, or both. Input-data grids are used to provide SWB with a map of land-use and soil-related information. Finally, daily weather data must be provided in either tabular or gridded form. These input files are discussed in greater detail in the following sections.

### Control File

The SWB control file contains all details about the grid specifications, gridded and tabular datasets to be used, and the location and name of lookup tables. SWB does not require the control file entries to be made in any particular order. The control file statements do not need to be in uppercase letters; `Lookup_table` works as well as `LOOKUP_TABLE`. Note that in SWB version 2.0 the cartographic projection of the SWB project grid is required to be supplied by means of the `BASE_PROJECTION_DEFINITION` directive in the form of a PROJ string (fig. 2).
```
## SWB 2 will ignore lines that begin with one of the following:  #%!+=
## also, SWB doesn't care about blank lines
## the order of lines makes no difference to SWB; however, it is useful for
## users to see the definition of the underlying grid up front

! Define model domain extent, origin coordinates, and resolution
!-----------------------------------------------------------------------------
!       nx    ny          xll            yll      resolution
!----------+-----+------------+--------------+---------------
GRID   400   346       545300.       432200.             90.

! where:      nx, ny          are the number of columns and number of rows
!             xll, yll        are the coordinates for the lower left-hand corner of the *grid*
!             res             is the grid cell resolution

% SWB grid projection *must* be defined in SWB 2.0
% projection in this example is Wisconsin Transverse Mercator(!)
BASE_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m

% Select which methods SWB should use
%-----------------------------------------------------------------------------
INTERCEPTION_METHOD             BUCKET
EVAPOTRANSPIRATION_METHOD       HARGREAVES
RUNOFF_METHOD                   CURVE_NUMBER
SOIL_MOISTURE_METHOD            FAO-56_TWO_STAGE
FOG_METHOD                      NONE
FLOW_ROUTING_METHOD             NONE
IRRIGATION_METHOD               FAO-56
ROOTING_DEPTH_METHOD            DYNAMIC
CROP_COEFFICIENT_METHOD         FAO-56
DIRECT_RECHARGE_METHOD          NONE
SOIL_STORAGE_MAX_METHOD         CALCULATED
AVAILABLE_WATER_CONTENT_METHOD  GRIDDED

% Define input weather data grids
%-----------------------------------------------------------------------------
! precipitation: converting mm to inches
PRECIPITATION NETCDF ../Daymet_V3_2016/daymet_v3_prcp_%y_na.nc4
PRECIPITATION_GRID_PROJECTION_DEFINITION +proj=lcc +lat_1=25.0 +lat_2=60.0 +lat_0=42.5 +lon_0=-100.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
PRECIPITATION_NETCDF_Z_VAR   prcp
PRECIPITATION_SCALE_FACTOR    0.03937008

! maximum air temperature: converting degrees Celsius to degrees Fahrenheit
TMAX NETCDF ../Daymet_V3_2016/daymet_v3_tmax_%y_na.nc4
TMAX_GRID_PROJECTION_DEFINITION +proj=lcc +lat_1=25.0 +lat_2=60.0 +lat_0=42.5 +lon_0=-100.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
TMAX_SCALE_FACTOR    1.8
TMAX_ADD_OFFSET     32.0

! minimum air temperature: converting degrees Celsius to degrees Fahrenheit
TMIN NETCDF ../Daymet_V3_2016/daymet_v3_tmin_%y_na.nc4
TMIN_GRID_PROJECTION_DEFINITION +proj=lcc +lat_1=25.0 +lat_2=60.0 +lat_0=42.5 +lon_0=-100.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
TMIN_SCALE_FACTOR                 1.8
TMIN_ADD_OFFSET                  32.0
TMIN_MISSING_VALUES_CODE     -9999.0
TMIN_MISSING_VALUES_OPERATOR   \<=
TMIN_MISSING_VALUES_ACTION     mean

% Continuous Forzen Ground Index initial value and upper and lower limits
%-----------------------------------------------------------------------------
INITIAL_CONTINUOUS_FROZEN_GROUND_INDEX CONSTANT 100.0
UPPER_LIMIT_CFGI 83.
LOWER_LIMIT_CFGI 55.

% Define flow direction, hydrologic soils group, land-use, available
% water-content grids
%-----------------------------------------------------------------------------
FLOW_DIRECTION ARC_GRID ../swb/input/d8_flow_direction.asc
FLOW_DIRECTION_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m

HYDROLOGIC_SOILS_GROUP ARC_GRID ../swb/input/hydrologic_soils_group.asc
HYDROLOGIC_SOILS_GROUP_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m

LANDUSE ARC_GRID ../swb/input/landuse.asc
LANDUSE_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m

AVAILABLE_WATER_CONTENT ARC_GRID ../swb/input/available_water_capacity.asc
AVAILABLE_WATER_CONTENT_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m

% Specify lookup tables; this is where most model parameters are defined
%-----------------------------------------------------------------------------

% SWB 2.0 can accommodate multiple lookup tables; however, column names
% may not be repeated from one table to another. Thus, if the land-use code column
% heading in the land use lookup table has the name LU_CODE, the irrigation lookup
% table heading could be called LU_CODE2

LANDUSE_LOOKUP_TABLE std_input/landuse_table_SWB2.txt
IRRIGATION_LOOKUP_TABLE std_input/irrigation_table_SWB2.txt

% Irrigation mask file can be used to definitively activate or inactivate
% simulation of irrigation inputs on a cell-by-cell basis
%-----------------------------------------------------------------------------
IRRIGATION_MASK ARC_GRID ../swb/input/irrigation_mask_from_cdl.asc
IRRIGATION_MASK_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m


% Specify some initial conditions
%-----------------------------------------------------------------------------
INITIAL_PERCENT_SOIL_MOISTURE CONSTANT 100.0
% initial snow storage as liquid water; at a rough 10:1 ratio of
% snow to liquid water, 10 inches of snow would be roughly 1.0 inches of
% liquid water
INITIAL_SNOW_COVER_STORAGE CONSTANT      1.0

% this option is good for debugging, but might be useful when one wants a lot of
% detail about what SWB is doing

DUMP_VARIABLES COORDINATES 563406. 454630.
DUMP_VARIABLES COORDINATES 552982. 439512.

% for SWB 2.0, the start and end dates need not follow calendar year bounds;
% the run may start and end on any arbitrary day.

START_DATE 01/01/2013
END_DATE 12/31/2014
```

**Figure 2.** Annotated SWB2 control file.

The section of the SWB control file in figure 2 shows how the `SCALE_FACTOR` and `ADD_OFFSET` suffixes can be used to ensure that gridded data in the International System of Units (millimeter, degrees Celsius) are converted to U.S. customary units (inch, degrees Fahrenheit) as the grids are read in by SWB. Toward the end of the control file syntax shown in figure 2 are several directives that need additional explanation. The `INITIAL_PERCENT_SOIL_MOISTURE` directive allows the user to set the percent of soil saturation for each grid cell in the model. Likewise, the `INITIAL_SNOW_COVER_STORAGE` directive allows the user to set the amount of snow as water equivalent for each grid cell in the model. Both of these directives may be specified as `CONSTANT` values or may be specified as `Arc_Grid` or `Surfer` grids. If gridded values are supplied, the grids must be in the same cartographic projection and of the same dimensions as the SWB project grid *or a projection must be supplied for the grid*. 

The choice regarding the use of a constant value instead of a gridded set of initial conditions for these values is project-specific. If the first year of a simulation is to be discarded as a spool-up period (a period in which soil-moisture and snow-depth values lose the memory of their initial condition values), then reasonable values suitable for average project area conditions may be specified as `CONSTANT` values. For a project in the northern Midwest of the United States, the `INITIAL_PERCENT_SOIL_MOISTURE` might be set to 70 percent, and the `INITIAL_SNOW_COVER_STORAGE` might be set to 1.0 inches. Alternatively, SWB could be run for several years with the last day of the simulation ending just before the start date of the period of interest. The soil-moisture and snow-storage values on the last day of such a simulation could be extracted and supplied as initial conditions to SWB for the run covering the time period of interest.
