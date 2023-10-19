title: Cartographic projection and resampling
---

@note
The official documentation for this code is contained in [USGS Techniques and Methods Report 6-A59](https://pubs.er.usgs.gov/publication/tm6A59). This online documentation is a work-in-progress. While we will try to keep this as up-to-date as possible, you may find occasionally find instances where the actual behavior of the code differs from the official documentation or from this online documentation. Please consider submitting an issue on the [GitHub repository](https://github.com/smwesten-usgs/swb2/issues) if you find such differences between code and documentation.
@endnote

### Cartographic Projections and Resampling

A significant feature added to SWB since the initial release is the ability to use datasets that differ from the base grid in grid cell size, cartographic projection, and geographic extent. To do this SWB incorporates a software library called PROJ to perform transformations among various map projections. PROJ was originally written by Gerald Evenden of the U.S. Geological Survey (Evenden, 1990).

The specific attributes of a projection are defined by supplying SWB with a PROJ string. A PROJ string may be assembled by specifying a combination of the appropriate PROJ parameters (table 5) to describe the cartographic projection.

**Table 5.**  List of commonly used PROJ parameter names.

| Parameter    | Definition                                                           |
| ------------ | -------------------------------------------------------------------- |
| \+a          | Semimajor radius of the ellipsoid axis.                              |
| \+alpha      | Used with Oblique Mercator and possibly a few others.                |
| \+axis       | Axis orientation.                                                    |
| \+b          | Semiminor radius of the ellipsoid axis.                              |
| \+datum      | Datum name.                                                          |
| \+ellps      | Ellipsoid name.                                                      |
| \+k          | Scaling factor (old name).                                           |
| \+k_0       | Scaling factor (new name).                                           |
| \+lat_0     | Latitude of origin.                                                  |
| \+lat_1     | Latitude of first standard parallel.                                 |
| \+lat_2     | Latitude of second standard parallel.                                |
| \+lat_ts    | Latitude of true scale.                                              |
| \+lon_0     | Central meridian.                                                    |
| \+lonc       | Longitude used with Oblique Mercator and possibly a few others.      |
| \+lon_wrap  | Center longitude to use for wrapping.                                |
| \+nadgrids   | Filename of NTv2 grid file to use for datum transforms.              |
| \+no_defs   | Do not use the /usr/share/proj/proj_def.dat defaults file.          |
| \+over       | Allow longitude output outside -180 to 180 range, disables wrapping. |
| \+pm         | Alternate prime meridian.                                            |
| \+proj       | Projection name.                                                     |
| \+south      | Denotes southern hemisphere Universal Transverse Mercator zone.      |
| \+to_meter  | Multiplier to convert map units to 1.0 meter.                        |
| \+towgs84    | 3 or 7 term datum transform parameters.                              |
| \+units      | Meter (for example, U.S. survey foot))                               |
| \+vto_meter | Vertical conversion to meter.                                        |
| \+vunits     | Vertical units.                                                      |
| \+x_0       | False easting.                                                       |
| \+y_0       | False northing.                                                      |
| \+zone       | Universal Transverse Mercator zone.                                  |

Assembling a string from several PROJ parameters results in a definition of a cartographic projection. This string is used by SWB and PROJ to transform coordinates to the base project coordinate system. Some common cartographic projections are listed in table 6. Note that the Michigan Oblique Mercator projection offers an example of a PROJ-supported projection that allows for grid rotation by means of the alpha parameter. Groundwater models are often rotated to align with underground geologic features; creating a custom oblique Mercator projection might be a clean way to allow for grid rotation while maintaining a way to reproject the results into a more common cartographic projection scheme.

**Table 6.**  PROJ strings for some commonly used cartographic projections.
[WGS84, World Geodetic System 1984]

| Projection Name | PROJ String |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unprojected, WGS84 (geographic coordinates) | +proj=lonlat +datum=WGS84 +no_defs |
| Universal Transverse Mercator (UTM), zone 18 | +proj=utm +zone=18 +north +ellps=GRS80 +datum=NAD83 +units=m +no_defs |
| Wisconsin Transverse Mercator (WTM) | +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m |
| Lambert Conformal Conic | +proj=lcc +lat_1=25.0 +lat_2=60.0 +lat_0=42.5 +lon_0=-100.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs  |
| Michigan Oblique Mercator | +proj=omerc +lat_0=45.30916666666666 +lonc=-86 +alpha=337.25556 +k=0.9996 +x_0=2546731.496 +y_0=-4354009.816 +ellps=GRS80 +datum=NAD83 +units=m +no_defs |
| North America Albers Equal Area Conic | +proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs |
| United States Contiguous Albers Equal Area Conic (U.S. Geological Survey version--note the latitude of origin) | \+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=**23** +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs |
| United States Contiguous Albers Equal Area Conic | proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=**37.5** +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs |

SWB takes the following additional steps to compute the correct coordinates for the project grid:

1.  creates an array of coordinates for the data grid in native projected coordinates, 
2.  transforms the native projected coordinates to SWB base coordinates, 
3.  determines the indices (row, column) for the data grid cell closest to each of the SWB base coordinates, 
4.  obtains the data-grid values for the set of indices in step 3, and
5.  returns an array of all the values obtained in step 4.

The process outlined in these steps is essentially a nearest-neighbor resampling scheme. A more complex process would result in much slower execution times. The SWB user, therefore, must determine whether or not a nearest-neighbor type process is acceptable.

If, for example, the data grid contains precipitation data at a 4-kilometer grid resolution and the underlying SWB base resolution is 200 meters, the execution time will not be slower by applying a nearest-neighbor approach. Interpolating this type of data could be done, but would provide only the illusion of greater accuracy-a smoother precipitation surface.

However, if the SWB base grid is 1 kilometer and the underlying data grid contains land-use data at a 90 meter resolution, the nearest-neighbor approach may or may not be acceptable. A majority filter may be invoked for integer grids, but will still characterize the land uses present in a subset of the data-grid cells corresponding to the SWB base-grid cell. In the case where the underlying data grid is of much higher resolution than the SWB computational grid, an external GIS procedure may be preferred to resample the land use to the SWB base-grid resolution; resampling with some type of mean (for real data) or modal function (for integer data) would be ideal.

Specification of a cartographic projection for an SWB model is accomplished with the `BASE_PROJECTION_DEFINITION` control file statement. For example, to specify that the coordinates of a model grid be interpreted by means of the Wisconsin Transverse Mercator projection, the following control file statement would be added:

```
BASE_PROJECTION_DEFINITION +proj=tmerc +lat_0=0.0 +lon_0=-90.0 +k=0.9996 +x_0=520000 +y_0=-4480000 +datum=NAD83 +units=m.
```