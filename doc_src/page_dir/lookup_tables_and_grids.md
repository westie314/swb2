title: Lookup tables and grids
---

@note
The official documentation for this code is contained in [USGS Techniques and Methods Report 6-A59](https://pubs.er.usgs.gov/publication/tm6A59). This online documentation is a work-in-progress. While we will try to keep this as up-to-date as possible, you may find occasionally find instances where the actual behavior of the code differs from the official documentation or from this online documentation. Please consider submitting an issue on the [GitHub repository](https://github.com/smwesten-usgs/swb2/issues) if you find such differences between code and documentation.
@endnote


### Lookup Tables

In addition to the gridded data, one or more lookup tables must be provided to supply parameter values to the SWB methods. Many parameters are specified for specific combinations of land-use categories and hydrologic soil groups. At a minimum, a SWB application requires the user to supply parameter values for the Soil Conservation Service curve number, the maximum recharge rate, the growing and nongrowing season interception values, and the rooting depths; except for the interception values, these parameters are specified for each combination of land use category and hydrologic soil group.

SWB version 2.0 uses keywords to identify parameter values within the table; the new lookup tables allow parameters to be supplied in any arbitrary column order. A separate column of parameter values must be supplied for each soil type. A snippet of the new table format is listed in table 2-1). Of the field values listed, the land-use code (LU_Code) is the key that relates the table values back to the land-use grid. The "Description" field is ignored by SWB, and the remaining fields specify the maximum surface storage for a given land use and the range of curve numbers for combinations of land-use categories and hydrologic soil groups. Tables could be easily prepared using spreadsheet software such as Microsoft Excel; however, tables should be saved as a tab-delimited text file for use with SWB.

**Table 1.**  Extract from the Soil-Water-Balance (SWB) version 2.0 table format.
[CN, curve number; LU, landuse]

| LU_code | Description                | Surface_storage_max | CN_1 | CN_2 | CN_3 | CN_4 |
| -------- | -------------------------- | --------------------- | ----- | ----- | ----- | ----- |
| 0        | Background                 | 0                     | 100   | 100   | 100   | 100   |
| 2        | Pineapple                  | 0                     | 42    | 64    | 76    | 81    |
| 3        | Coffee                     | 0                     | 52    | 70    | 80    | 84    |
| 4        | Diversified agriculture    | 0                     | 55    | 72    | 82    | 85    |
| 5        | Macadamia                  | 0                     | 44    | 65    | 77    | 82    |
| 6        | Fallow_grassland          | 0                     | 37    | 61    | 74    | 79    |
| 7        | Developed open space       | 0                     | 37    | 61    | 74    | 79    |
| 8        | Developed low intensity    | 0                     | 60    | 75    | 84    | 87    |
| 9        | Developed medium intensity | 0.25                  | 70    | 82    | 88    | 91    |
| 10       | Developed high intensity   | 0.25                  | 81    | 88    | 92    | 94    |

In SWB 2.0, each column should be clearly identified so that the proper parameters may be linked to their respective process methods. Parameters that are tied to land use and to soil type are identified in the header in the form `parameter_name_#`, where `#` is the index value of the hydrologic soil group and must correspond to the values given in that grid. There must be a column for each index value found in the grid file. 

Soil types (hydrologic soil groups) are assumed to be numbered from 1 to *n*, where *n* is the number of different soil groupings. If a soil with five distinct hydrologic soil groups is supplied, the lookup table would need curve numbers for each land use and soil type combination; the column names for these curve numbers would be CN_1, CN_2, CN_3, CN_4, and CN_5. If multiple lookup tables are used, the row ordering must be consistent from one table to the next; SWB will perform some basic sanity checks on the table values, but will assume that values from all tables are defined relative to the order of land-use codes read from the first table that the SWB checks.

### Input Data Grids

Several input data grids are required to perform a basic SWB run. As a SWB model, basic information about the soils is required. The typically required data grids are discussed in the following sections. Choosing other optional process methods may negate the need for the grids discussed in this section; however, additional gridded data types may be required.

#### Hydrologic Soil Group

The hydrologic soil group grid is an integer-valued grid that contains the soil group for each cell in the model. Any number of soils may be used in this grid, but frequently SWB models use the integers 1, 2, 3, and 4 to represent the 4 standard hydrologic soil groups defined as part of the curve number literature. The U.S. Department of Agriculture, Natural Resources Conservation Service, formerly the Soil Conservation Service, has categorized more than 14,000 soil series within the United States into 1 of 4 hydrologic soil groups (A-D) on the basis of infiltration capacity. Hydrologic soil group information may be input to the model as an Arc ASCII or Surfer integer grid with values ranging from 1 (soil group A) to 4 (soil group D). Soils in hydrologic soil group A have a high infiltration capacity and, consequently, a low overland flow potential. In contrast, soils in hydrologic soil group D, have a low infiltration capacity and, consequently, a high overland flow potential (table 2).

**Table 2.**  Infiltration rates for hydrologic soil groups and associated Soil-Water-Balance (SWB) grid values.

| Hydrologic soil group | Infiltration rate              | Integer grid value |
| --------------------- | ------------------------------ | ------------------ |
| A                     | Greater than 0.3 inch per hour | 1                  |
| B                     | 0.15-0.3 inch per hour         | 2                  |
| C                     | 0.05-0.15 inch per hour        | 3                  |
| D                     | Less than 0.05 inch per hour   | 4                  |

#### Available Water Capacity

SWB needs one or more datasets for use in assigning the size of the soil-storage reservoirs. The user can specify gridded datasets of either (1) maximum soil-water capacity in inches, or (2) available-water-capacity in inches per foot, along with tabular values of the rooting depth in feet. Traditionally SWB uses the gridded available water capacity and tabular rooting depth to calculate a maximum soil water-holding capacity for each grid cell. The maximum soil-water capacity is calculated as in equation 1.
(1)

If the maximum soil-water capacity is not specified directly, each grid cell within the model area must be assigned an available water capacity and each combination of land use and soil type assigned a rooting depth in the lookup table. Soil classifications, which include an estimate of the available water capacity or textural information, are typically available through the state offices of the Natural Resources Conservation Service or on the [NRCS website](https:\\soils.usda.gov). If data for available water capacity are not available, the user can use soil texture to assign a value, listed in table 2-3 (original source table 10, Thornthwaite and Mather, 1957).

**Table 3.**  Estimated available water capacities for various soil-texture groups.

| Soil texture         | Available water capacity (inches per foot of thickness) |
| -------------------- | ------------------------------------------------------- |
| Sand                 | 1.20                                                    |
| Loamy sand           | 1.40                                                    |
| Sandy loam           | 1.60                                                    |
| Fine sandy loam      | 1.80                                                    |
| Very fine sandy loam | 2.00                                                    |
| Loam                 | 2.20                                                    |
| Silt loam            | 2.4                                                     |
| Silt                 | 2.55                                                    |
| Sandy clay loam      | 2.70                                                    |
| Silty clay loam      | 2.85                                                    |
| Clay loam            | 3.00                                                    |
| Sandy clay           | 3.20                                                    |
| Silty clay           | 3.40                                                    |
| Clay                 | 3.60                                                    |

The available water capacity of a soil is typically given as inches of
water-holding capacity per foot of soil thickness. For example, if a
soil type has an available water capacity of 2 inches per foot and the
root-zone depth of the cell under consideration is 2.5 feet, the maximum
water capacity of that grid cell would be 5.0 inches. The 5.0 inches is
the maximum amount of soil-water storage that can take place in the grid
cell. Water added to the soil column in excess of this value will become
recharge.

A grid containing the maximum soil-water capacity may be input directly
into the SWB code, bypassing the internal calculation of the maximum
soil-water capacity.

#### Land-Use Code

The model uses land-use information, together with the soil-available,
water-capacity information, to calculate surface runoff and assign a
maximum soil-moisture holding capacity for each grid cell. The original
model required that land-use classifications follow a modified Anderson
Level II Land Cover Classification (Anderson and others, 1976). SWB can
handle any arbitrary land-use classification method as long as the
accompanying land-use lookup table contains curve-number, interception,
maximum-recharge, and rooting-depth data for each land-use type
contained in the grid. Data from the Multi-Resolution Land
Characteristics Consortium (<https://www.mrlc.gov/>) are a common source
for land-use data, but any suitable gridded dataset may be used.

#### D8 Surface-Water-Flow Direction

The SWB code requires an integer flow-direction grid for the entire
model domain when the flow-routing method is enabled. SWB uses the
flow-direction grid to determine how to route overland flow between
cells. The user must create the flow-direction grid consistent with the
D8 flow-routing algorithm (O'Callaghan and Mark, 1984), with flow
directions defined as shown in figure 1*B*. The original algorithm
assigns a unique flow direction to each grid cell by determining the
steepest slope between the central cell and its eight neighboring cells.
For the cells shown in figure 1*A*, the steepest descent algorithm
results in flow from the central cell to the southwest; the
corresponding cell figure 1*B*, located to the southwest of the
central cell, contains the number 8. By convention, therefore, the D8
flow direction for the cell shown in figure 1*A* is 8.

<img src=images/Combined_elevation_and_D8_flow_direction_plot_fig_5__cropped.png width=100%>

Figure 1.  Example (a) elevation grid values, in meters, and (b) resulting D8
    flow-direction encoding.

Many GIS software implementations of the D8 algorithm generate grids whereby flow to more than one neighboring cell is assigned a special flow-direction encoding. A cell for which all neighboring cells are of equal or greater elevation is a cell that Jenson and Domingue (1988) called a condition 4 cell. For example, if the cells to the east, southeast, south, and southwest of the central cell in figure 5*A* all share the same elevation as the central cell (109), water might be expected to flow to any one of the neighboring cells; the flow direction is indeterminate. The flow direction for such a cell might be encoded as 15 (the sum of 1, 2, 4, and 8). A flow direction that is not a power of 2 is most likely to be generated from an unfilled digital elevation model. 

SWB interprets cells for which the flow-direction value is not a power of 2 (as shown in fig. 1*B*) as indicating closed depressions. The SWB code does not attempt to split flows between two or more cells; if a cell has more than one possible flow direction, the cell is identified as a closed depression. The SWB code allows no further surface runoff to be generated or ponding to occur. The SWB code, instead, requires water in excess of the soil-moisture capacity to contribute to net infiltration, with net infiltration in excess of any maximum net-infiltration rate extracted from the model domain and tracked as runoff_outside.

For best results, the user must carefully consider whether the D8 flow-direction grid should be generated from an unfilled or a filled digital elevation model and if SWB's treatment of flow-direction grid values that are not a power of 2 (as a depression) is acceptable. In addition, some researchers suggest that the traditional filling procedure used to prepare grids for use in determining D8 flow direction may be inappropriate for glaciated areas of the country where large areas of internal drainage reduce the size of the contributing area to streams. The presence of large areas of internal drainage may result in overestimation of surface-water runoff (Macholl and others, 2011; Richards and Brenner, 2004).

