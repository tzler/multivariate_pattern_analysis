MVPDlib is a library of functions to calculate multivariate statistical dependence between brain regions.

The library takes as inputs functional data that have already undergone basic preprocessing (e.g. realignment, coregistration, and normalization if needed).

Calculation of multivariate statistical dependence is done in three processing stages:
1) preprocessing and noise removal (e.g. CompCorr)
2) modeling of responses in individual regions
3) modeling of statistical dependence between regions and prediction of left-out data.

MVPDlib is based on a modular, compositional structure. Each processing stage consists of a number of steps, and each step specifies a function pointer as well as the input parameters required by that step. This structure is  designed to maximize code reuse and to facilitate the combination of different steps in different orders.
