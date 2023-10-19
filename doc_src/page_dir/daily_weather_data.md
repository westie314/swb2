title: Daily weather data
---

@note
The official documentation for this code is contained in [USGS Techniques and Methods Report 6-A59](https://pubs.er.usgs.gov/publication/tm6A59). This online documentation is a work-in-progress. While we will try to keep this as up-to-date as possible, you may find occasionally find instances where the actual behavior of the code differs from the official documentation or from this online documentation. Please consider submitting an issue on the [GitHub repository](https://github.com/smwesten-usgs/swb2/issues) if you find such differences between code and documentation.
@endnote

## Daily Weather Data

The most important component of the water budget when estimating net
infiltration is precipitation. The next most important component is
generally evaporation, which can be estimated from air temperature data.
SWB accepts precipitation, and minimum and maximum air temperature data
in the form of tabular or gridded files.

### Tabular Datasets

For a project that covers an area small enough to be described by a
single climate station, these data may be entered directly by use of a
table that has header and date formats the same as those shown in fig.
6.

```
    % Data obtained from ***** station in Roswell, NM
    Date        PRCP        TMIN        TMAX
    01-01-2015    0.0        20.0        26.0
    01-02-2015    1.1        25.0        30.0
    01-02-2015    0.3        24.0        29.0
    01-04-2015    0.0        23.0        28.5
```

**Figure 6.** Example of daily weather data in supplied to SWB in tabular form.

For many projects, the use of some type of gridded data may be desirable. The source of the gridded data might be a project-specific custom interpolation routine. Alternatively, a gridded data product such as Daymet (Thornton and others, 2016) can be used. Daymet uses consistent methodology to generate a continuous gridded dataset for the contiguous United States, The dataset contains precipitation, air temperature, and several other estimated data series (relative humidity, snow-water equivalent). The precomputed gridded datasets are generally much easier to use and save significant amounts of time relative to computing project-specific interpolated fields for precipitation and air temperature. Use of gridded datasets with SWB is discussed further in the "Gridded Datasets" section of this appendix.

## Gridded Datasets

SWB currently can make use of gridded data in the following three formats: Surfer, Esri Arc ASCII, or netCDF. Of these formats, only Surfer and Arc ASCII grids may be used as a source for the input data grids discussed in the previous section. All three file formats may be used to supply daily weather data to SWB. Often, one or more files constituting a time series of gridded data are required to perform a simulation. In addition, missing values are often a feature of these gridded datasets, which can cause numerical errors in the simulation results. These topics are discussed further in the following sections. The functionality and control file syntax discussed in this section applies regardless of what type of grid file is being used.

### Specifying Grid Filenames

To specify a series of grid files for use with SWB, a filename template can be used in place of a normal filename. For example, more than 43,000 individual Arc ASCII grids were supplied to make a 100-year model run for the Lake Michigan Pilot Water Availability Study. The files were given names with the pattern precip-*month*-*day*-*year*.asc; for example, precip-02-12-1967.asc. The control file syntax required to specify this file naming convention was as follows:

`PRECIPITATION ARC_GRID precip-%0m-%0d-%Y.asc.`

In the filename template, the meanings for the characters that immediately follow the percent symbol (%) are as follows: %0m, the month number (1-12), padded by a leading zero; %0d, the day of the month, padded by a leading zero; and %Y, the four-digit year value. More of these filename template values are listed in table 7.

**Table 7.**  Soil-Water-Balance (SWB) control file template values for specifying a series of filenames.

| Template value | Meaning                                                                   |
| -------------- | ------------------------------------------------------------------------- |
| %Y or %y       | Four-digit year value.                                                    |
| %m             | Month number, *not* zero padded (1-12).                                   |
| %0m            | Month number, zero padded (01-12).                                        |
| %b             | Abbreviated (three-letter) month name (jan-dec).                          |
| %B             | Full month name (january-december).                                       |
| %d             | Day of month, *not* zero padded (1-31).                                   |
| %0d            | Day of month, zero padded (01-31).                                        |
| \#             | File counter, reset each year beginning with 1.                           |
| \#000          | File counter with three positions of zero padding, reset each year (1-n). |

In addition, three modifiers may be specified in the control file if SWB is being run on a computing platform where capitalization is significant, as is the case for the Linux or MacOS operating systems (fig. 9).

`_MONTHNAMES_CAPITALIZED`
`_MONTHNAMES_UPPERCASE`
`_MONTHNAMES_LOWERCASE`

**Figure 9.**  Control file modifiers for use in specifying month name capitalization.

The modifiers are to be used in the control file prefixed by the data name. For example, to ensure uppercase month names are used in conjunction with precipitation data files, `PRECIPITATION_MONTHNAMES_UPPERCASE` can be added to the control file. When the various control- file modifiers are used together, SWB can locate and use a variety of files without requiring that the files be renamed. Some common file naming patterns and corresponding SWB template statements are listed in table 8.

**Table 8.**  Examples showing the use of filename templates.

| Example filename         | Template              | Control file modifier entry             |
| ------------------------ | --------------------- | --------------------------------------- |
| prcp09Jan2010.asc        | prcp%0d%b%Y.asc       | PRECIPITATION_MONTHNAMES_CAPITALIZED. |
| tmin_2011.nc4           | tmin_%Y.nc4          | None.                                   |
| tasmax-02-22-1977.asc    | tasmax-%0m-%0d-%Y.asc | None.                                   |
| precip_january_1981.nc | precip_%B_%Y.nc     | PRECIPITATION_MONTHNAMES_LOWERCASE.   |

## Options for Gridded Datasets

SWB has a set of common control file directives that may be used with
any input gridded dataset. For each of the applicable gridded datasets,
a standard set of suffixes may be added to the dataset name to control
how SWB treats the dataset. The dataset prefixes understood by SWB 2.0
are given in the previous section. The suffixes understood by SWB are
listed in table 2-9.

9.  Control file suffixes for modifying gridded data input to
    Soil-Water-Balance (SWB) code.
[<, less than; <=, less than or equal to; >, greater than; >= greater than or equal to\]

| Suffix                      | Argument              | Description                                                                                                                                                                                    |
| --------------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| _SCALE_FACTOR             | real value            | Amount to multiply raw-grid value by prior to use.                                                                                                                                             |
| _ADD_OFFSET               | real value            | Amount to add to the raw-grid value following application of the scale factor, if any.                                                                                                         |
| _NETCDF_X_VAR            | string                | Name of the variable to be used as the x axis.                                                                                                                                                 |
| _NETCDF_Y_VAR            | string                | Name of the variable to be used as the y axis.                                                                                                                                                 |
| _NETCDF_Z_VAR            | string                | Name of the variable to be used as the z (value) axis.                                                                                                                                         |
| _NETCDF_TIME_VAR         | string                | Name of the variable to be used as the time axis.                                                                                                                                              |
| _NETCDF_VARIABLE_ORDER   | "xyt or txy"          | Description of the order in which the gridded data were written.                                                                                                                               |
| _NETCDF_FLIP_VERTICAL    | none                  | If present, gridded data will be flipped around the vertical axis.                                                                                                                             |
| _NETCDF_FLIP_HORIZONTAL  | none                  | If present, gridded data will be flipped around the horizontal axis.                                                                                                                           |
| _PROJECTION_DEFINITION    |                       | PROJ string describing the geographic projection of the dataset.                                                                                                                             |
| _MINIMUM_ALLOWED_VALUE   | real value            | Ceiling to be applied to the data; data above this value will be reset to this amount.                                                                                                         |
| _MAXIMUM_ALLOWED_VALUE   | real value            | Floor to be applied to the data; data beneath this value will be reset to this amount.                                                                                                         |
| _MISSING_VALUES_CODE     | real or integer value | Value.                                                                                                                                                                                         |
| _MISSING_VALUES_OPERATOR | \<, \<=, \>, \>=      | Operator to use for comparison to the _MISSING_VALUES_CODE.                                                                                                                                 |
| _MISSING_VALUES_ACTION   | mean or zero          | Supplying the keyword "mean" will substitute the mean value calculated over the remaining valid cells; supplying the keyword "zero" will substitute a value of 0.0 in place of missing values. |

More information regarding the use of some of the control file suffixes to handle missing data is in the "Treatment of Missing Values" and "Conversion Factors" sections.

### Supported File Types

The following three file formats are supported as input to SWB: Surfer ASCII grids, Arc ASCII grids, and netCDF files. Both the Surfer and Arc ASCII grids amount to a rectangular matrix of data with several lines of header information prepended; any software could be used to create the data matrices as long as the header information can be provided. Each format is discussed further in the following sections.

#### Surfer ASCII Grid

Golden Software's ASCII grid format consists of a five-line header followed by the data values arranged in a matrix. An example Surfer ASCII grid file is shown in figure 10.

```
DSAA
14    5
0.5   7.0
-0.4  0.0
0.0   7.0
0.50  1.0  1.5  2.0  2.5  3.0  3.5  4.0  4.5  5.0  5.5  6.0  6.5  7.0
0.45  0.9  1.4  1.9  2.4  2.9  3.4  3.9  4.4  4.9  5.4  5.9  6.4  6.9
0.40  0.8  1.3  1.8  2.3  2.8  3.3  3.8  4.3  4.8  5.3  5.8  6.3  6.8
0.36  0.7  1.2  1.7  2.2  2.7  3.2  3.7  4.2  4.7  5.2  5.7  6.2  6.7
0.32  0.6  1.1  1.6  2.1  2.6  3.1  3.6  4.1  4.6  5.1  5.6  6.1  6.6
```

**Figure 10.** Example showing a Golden Software Surfer ASCII grid file.

The header values contain the following information.

1.  "DSAA", a label identifying the file format as a Golden Software ASCII grid,
2.  Number of columns (number of X values), number of rows (number of Y values),
3.  Minimum X value, maximum X value,
4.  Minimum Y value, maximum Y value,
5.  Minimum Z value, maximum Z value.

For the file shown in figure 10, the coordinate system has its origin in the lower left-hand corner, with x and y coordinates increasing toward the upper right-hand corner. Surfer files are not explicitly georeferenced to real-world coordinate systems.

#### Arc ASCII Grid

The publishers of ArcMap and ArcView software, Esri, developed one of the most commonly used raster-data formats in use. Esri's Arc ASCII grid format is a matrix representation of the gridded dataset with a short header tacked to the top of the file (U.S. Library of Congress, 2015). In an Arc ASCII grid, the data are arranged as though a user is viewing the data from above. The coordinates for the lower left-hand corner of the lower left-hand grid cell are specified as xllcorner and yllcorner in figure 2-11. The value stored in the lower left-hand grid cell is a 7, which is shown in the bottom row and left-most column of figure 11.

    ncols        34
    nrows        4
    xllcorner    739475.0
    yllcorner    2314000.0
    cellsize     10.0
    NODATA_value -9999
    9 9 9 9 9 9 9 9 9 9 9 8 8 8 8 8 8 8 9 9 9 9 9 9 8 8 8 8 8 8 8 8 9 9
    7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 6 6 6 7 7 7 6 6 6 6 6 6 6 6 6 6 6 6 6
    7 7 7 7 6 6 6 7 7 7 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6
    7 7 7 7 7 7 7 7 7 7 6 6 6 7 7 7 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6

**Figure 11.** Example showing an Arc ASCII grid file.

Note that SWB does not process the NODATA_ value codes as given in the Arc ASCII grid files; missing values should be handled through the use of user-supplied, control-file directives, discussed later in this section.

#### netCDF

NetCDF is a file format commonly used by researchers in atmospheric and oceanic sciences. A key benefit of netCDF files is that they are designed to be platform independent; in other words, a netCDF file generated on a Macintosh computer by an application compiled with the GNU compiler collection gfortran compiler should be able to be read by an application that is compiled with the Intel compiler and running on Windows. In addition, netCDF files are able to store arbitrary combinations of data. This ability allows for substantial metadata to be stored in the netCDF file along with the variable of interest.

A set of conventions, known as the Climate and Forecast Metadata Conventions, gives recommendations regarding the type and nature of metadata to be included along with the primary variable within a netCDF file (Eaton and others, 2011). SWB outputs written to netCDF files attempt to adhere to the Climate and Forecast Metadata Conventions version 1.6 (CF 1.6) to maximize the number of third-party netCDF tools that will work with SWB output.

In addition to these benefits of netCDF file use, the fact that dozens of open-source tools are available to read, write, and visualize netCDF files makes them a good format for use with SWB. A basic tool called ncdump--a program to dump the contents of a netCDF file--is distributed by Unidata, the maintainer of netCDF file format. Issuing the command `ncdump -h` along with the filename will cause the header information and other various metadata to be printed to the screen.

As an example, one useful source for gridded daily weather data is the Daymet product containing gridded daily precipitation and air temperature for the conterminous United States on a 1 kilometer grid-cell spacing (Thornton and others, 2016). The metadata stored in the file reveals a variety of useful information about the file contents (fig. 12).

```
netcdf daymet_v3_prcp_2010_na {
dimensions:
        x = 7814 ;
        y = 8075 ;
        time = UNLIMITED ; // (365 currently)
        nv = 2 ;
variables:
        float x(x) ;
                x:units = "m" ;
                x:long_name = "x coordinate of projection" ;
                x:standard_name = "projection_x_coordinate" ;
        float y(y) ;
                y:units = "m" ;
                y:long_name = "y coordinate of projection" ;
                y:standard_name = "projection_y_coordinate" ;
        float lat(y, x) ;
                lat:units = "degrees_north" ;
                lat:long_name = "latitude coordinate" ;
                lat:standard_name = "latitude" ;
        float lon(y, x) ;
                lon:units = "degrees_east" ;
                lon:long_name = "longitude coordinate" ;
                lon:standard_name = "longitude" ;
        float time(time) ;
                time:long_name = "time" ;
                time:calendar = "standard" ;
                time:units = "days since 1980-01-01 00:00:00 UTC" ;
                time:bounds = "time_bnds" ;
        short yearday(time) ;
                yearday:long_name = "yearday" ;
        float time_bnds(time, nv) ;
        short lambert_conformal_conic ;
                lambert_conformal_conic:grid_mapping_name = "lambert_conformal_conic" ;
                lambert_conformal_conic:longitude_of_central_meridian = -100. ;
                lambert_conformal_conic:latitude_of_projection_origin = 42.5 ;
                lambert_conformal_conic:false_easting = 0. ;
                lambert_conformal_conic:false_northing = 0. ;
                lambert_conformal_conic:standard_parallel = 25., 60. ;
                lambert_conformal_conic:semi_major_axis = 6378137. ;
                lambert_conformal_conic:inverse_flattening = 298.257223563 ;
        float prcp(time, y, x) ;
                prcp:_FillValue = -9999.f ;
                prcp:long_name = "daily total precipitation" ;
                prcp:units = "mm/day" ;
                prcp:missing_value = -9999.f ;
                prcp:coordinates = "lat lon" ;
                prcp:grid_mapping = "lambert_conformal_conic" ;
                prcp:cell_methods = "area: mean time: sum" ;

// global attributes:
                :start_year = 2010s ;
                :source = "Daymet Software Version 3.0" ;
                :Version_software = "Daymet Software Version 3.0" ;
                :Version_data = "Daymet Data Version 3.0" ;
                :Conventions = "CF-1.6" ;
                :citation = "Please see http://daymet.ornl.gov/ for current Daymet data citation information" ;
                :references = "Please see http://daymet.ornl.gov/ for current information on Daymet references" ;
}
```
**Figure 12.** Metadata embedded in a Daymet, version 3 precipitation netCDF file (Thornton and others, 2016).

The file whose metadata are shown in figure 12 contains three classes of metadata pertaining to dimensions, variables, and global attributes. Four dimensions are defined: `x`, `y`, `time`, and `nv`. For this file, the `x` and `y` dimensions may be thought of in terms of Cartesian coordinates; `x` refers to the number of cells along a east-west axis, and `y` refers to the number of cells along a north-south axis. The dimension `time` is declared unlimited; this file could contain many days of daily weather data. In this case, the time dimension is of size 365, which means the file contains one year of data. Dimension `nv` is of size two and exists so that the variable time_bnds can contain a starting and ending date and a time stamp.

Each of the nine variables defined is referenced in terms of the dimensions. The main variable of interest in the file is named `prcp`, the daily precipitation value. The daily precipitation value is defined at each time (day) in the file for all values of `x` and `y`. Note the way that dates and times are specified in the netCDF file-as a real-valued number of days since 1980-01-01 00:00:00 UTC.

The grid-cell location is specified in the following two ways: in terms of projected (x, y) coordinates, as well as in geographic (longitude, latitude) coordinates. Often netCDF files will be written so that both projected and geographic coordinates are provided, ensuring that third-party software applications will be able to correctly interpret the location of each data value.

SWB does not make use of much of the metadata included in the netCDF file header. *The user is responsible for being aware of the physical units that each of the datasets is stored in, and must supply control file directive to SWB to ensure that the data are used correctly.* In order to make SWB correctly interpret the values for the file shown in figure 12, for example, control file directives  must be inserted into the SWB control file to cause it to convert precipitation in metric units (millimeters per day) to inches per day. The authors recommend examining the SWB output values of air temperature and precipitation to verify that any such unit conversions have been done correctly. Some of the temperature conversion suffixes are particularly easy to forget, which leads to disastrous SWB results. SWB will still run with the incorrect daily weather values. For example, if air temperatures are given in degrees Celsius but no offset or scale factor values are provided, the air temperatures processed by SWB will never exceed a numerical value of 30 or 40 degrees Celsius; SWB will process these values as though the values are given in degrees Fahrenheit, which results in considerable snowfall and snowmelt and unrealistically elevated net infiltration values.

In addition, SWB cannot parse the netCDF variables and attributes associated with any map projection that may have been used when the netCDF file was created. The user needs to be aware of the geographic projection (if any) that was used. If the gridded data do not match the SWB project bounds exactly, a PROJ string must be provided to enable SWB to translate between project coordinates and the netCDF file coordinates.

As an example, look again at the metadata included in figure 12. The creators of this dataset have provided a variable (lambert_conformal_conic) and have attached several attributes to the variable to help ensure correct georeferencing of the coordinate values. The PROJ string can be constructed from the metadata attached to the lambert_conformal_conic variable (fig. 13).

    +proj=lcc +lat_1=25.0 +lat_2=60.0 +lat_0=42.5 +lon_0=-100.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs

**Figure 13.** PROJ string for a Daymet, version3 netCDF file (Thornton and others, 2016).

The netCDF file metadata does not include any details about the ellipse (PROJ keyword ellps) or datum associated with this projection. However, the semi_major_axis and inverse_flattening" attribute values are consistent with the GRS80 definition (Moritz, 2000). In this example, the standard parallels as defined by `lat_1` and `lat_2` in figure 13 differ from the standard parallels of 33 degrees and 45 degrees as described in Snyder (1987). Supplying the standard values in the SWB control file, at best, would cause SWB to issue a warning about a mismatch between the data coverage and the model domain and, at worst, would run anyway, supplying incorrect daily weather data to the model. In other words, SWB checks to see that numerically valid coordinates are present and that the weather data cover the region defined by the base grid. However, SWB cannot detect an incorrect user-supplied PROJ string. Users are encouraged to examine the SWB output files containing air temperature and precipitation data to verify that daily weather data are being correctly interpreted by SWB.

An explicit definition of the grid spacing is not included as an attribute in the header of the netCDF file (fig. 12). However, grid spacing can be gleaned from the coordinate variable values themselves. Running the command-line utility ncdump with the option -v x (ncdump -v x daymet_v3_prcp_2014_na.nc4) produces the output shown in figure 14.

```
    3232750, 3233750, 3234750, 3235750, 3236750, 3237750, 3238750, 3239750,
    3240750, 3241750, 3242750, 3243750, 3244750, 3245750, 3246750, 3247750,
    3248750, 3249750, 3250750, 3251750, 3252750 ;
```

**Figure 14.** Partial listing of the x variables embedded in a Daymet, version 3
    netCDF file (Thornton and others, 2016).

By subtracting two adjacent x coordinate values, the grid spacing in the x direction is 1,000 meters. Subtracting two adjacent y coordinate values (not shown) also produces 1,000 meters; therefore, the grid cells are square and measure 1 kilometer on a side.

### Treatment of Missing Values

Missing values in datasets can be an issue during a SWB simulation. Generally, SWB will detect most obvious issues, such as numerical values outside of a reasonable range of values. However, missing values that are within the expected normal range of values for the dataset could lead to unexpected results. For example, an air temperature value that is interpreted as zero rather than being treated as a missing value would result in a cell being simulated with permanent winter conditions.

SWB has a few actions that may be taken to deal with the issue of missing values. These actions are triggered through a set of control file directives that are supplied as suffixes to the dataset they pertain to (table 10).

**Table 10.** Control file suffixes for treatment of missing data.
[<, less than; <=, less than or equal to; >, greater than; >=, greater than or equal to]

| Suffix                      | Argument              | Description                                                                                                                                                                                    | Default value               |
| --------------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| _MINIMUM_ALLOWED_VALUE   | Real value            | Ceiling to be applied to the data; data above this value will be reset to this amount.                                                                                                         | _MINIMUM_ALLOWED_VALUE   |
| _MAXIMUM_ALLOWED_VALUE   | Real value            | Floor to be applied to the data; data beneath this value will be reset to this amount.                                                                                                         | _MAXIMUM_ALLOWED_VALUE   |
| _MISSING_VALUES_CODE     | Real or integer value | Value.                                                                                                                                                                                         | _MISSING_VALUES_CODE     |
| _MISSING_VALUES_OPERATOR | \<, \<=, \>, \>=      | Operator to use for comparison to the _MISSING_VALUES_CODE.                                                                                                                                 | _MISSING_VALUES_OPERATOR |
| _MISSING_VALUES_ACTION   | mean or zero          | Supplying the keyword "mean" will substitute the mean value calculated over the remaining valid cells; supplying the keyword "zero" will substitute a value of 0.0 in place of missing values. | _MISSING_VALUES_ACTION   |

For example, gridded weather datasets typically end abruptly at the edge of a large waterbody, which from the perspective of interpolations is done for valid reasons. However, a dataset that ends abruptly at the edge of a large water body often leads to extreme edge effects on the SWB results.

A crude but effective way to overcome this limitation in the climate dataset is to enforce some type of value substitution for the affected cells. For example, to eliminate zones of zero precipitation around a large waterbody, control file statements might be added to inform SWB that the mean value is to be used in place of missing data values (fig. 15).

```
PRECIPITATION_MISSING_VALUES_CODE           0.0
PRECIPITATION_MISSING_VALUES_OPERATOR         <
PRECIPITATION_MISSING_VALUES_ACTION        MEAN
```

**Figure 15.** Control file statements used to request that Soil Water Balance (SWB) code substitute mean daily air temperatures in areas of missing data.

Including this syntax in the control file would result in the mean value of the valid cells being substituted for the missing values across the model grid for a day.

## Conversion Factors

SWB still uses U.S. customary units for many dimensions (inches, degrees Fahrenheit), primarily for historical reasons. Most available gridded climate data are encoded in metric units. In order for SWB to make use of these data sources, conversion factors or offsets, or both must be provided. In theory, to craft a code that would read the standard climate forecast elements from the metadata of a netCDF file should be possible; however, in practice, too many gridded datasets are still in existence that do not adhere to the standards. For now (2017), the user must handle unit conversion explicitly in the control file. The control-file syntax is listed in table 11.

**Table 11.** Control file suffixes for use in performing unit conversions of values read from grids.

| Suffix          | Argument   | Description                                                                    |
| --------------- | ---------- | ------------------------------------------------------------------------------ |
| _SCALE_FACTOR | Real value | Amount to multiply raw grid value by prior to use.                             |
| _ADD_OFFSET   | Real value | Amount to add to the raw grid value following application of the scale factor. |

For example, most air-temperature data are stored with units of degrees Celsius. To make use of this data grid with SWB, control-file syntax would be added to specify the scale factor and offset to apply to the data. The scale factor and offset values as applied to minimum air-temperature data (TMIN) are shown in figure 16.

```
TMIN_SCALE_FACTOR         1.8
TMIN_ADD_OFFSET          32.0
```

**Figure 16.** Control file syntax for conversion of temperature data from degrees Celsius to degrees Fahrenheit.

This syntax will cause SWB to convert all values in the minimum air temperature grid from Celsius to Fahrenheit before performing any water balance calculations.

## Inactive Grid Cells

Grid cells outside the area of interest to the user may be inactivated. SWB will use information from certain standard grids to determine which grid cells should remain active during the course of a simulation; namely, the land-use, soil-type, and available water-capacity grids. **A negative value in the land-use, soil-type, or available water-capacity grids causes SWB to mark the cell as inactive; the cell will be removed from further calculations.** The missing value treatments discussed in the previous section could interfere with this interpretation; the user is discouraged from using the missing value treatments to these grids. Because integer grids with missing values are often encoded with -9999, these negative values were used to help define active and inactive grid cells.
If the user does not wish to have cells with missing values inactivated, some GIS preprocessing will be needed to ensure that SWB can separate inactive cells from those with missing values. A strategy might be to convert active-cell missing values to an extremely large positive number, then use SWB's control file directives to find these values and convert them to appropriate values.
