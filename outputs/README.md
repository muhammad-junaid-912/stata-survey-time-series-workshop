 encode month, gen(month_t)
. order month_t netsales rdintensity month
. gen depvar=ln(netsales)
. gen indpvar=ln(rdintensity)

. edit

. graph twoway (line depvar month_t)

. 
. graph twoway (line indpvar month_t)

. 
. 
. 
. 
. 
. *********

. 
. *STEP-3

. 
. *********

. 
. 
. 
. *Formal Testing of Non-Stationarity - Determining the Order of Integration of Net Sales and R&D Intensity

. 
. *---------------------------------------------------------------------------------------------------------

. 
. 
. 
. *Let's now test the order of integration of two time-series. The purpose of conducting unit root testing is to figure (i) if the 

. 
. *two series contain unit root, (ii) how many? and, (iii) for how many times we need to difference the series to make it stationary 

. 
. *and thus eligble for our regression analysis.

. 
. 
. 
. *********

. 
. *STEP-3A

. 
. *********

. 
. 
. 
. *Augmented Dickey-Fuller (ADF) Unit Root Testing for Net_Sales (Dependent Variable)

. 
. *-------------------------------------------------------------------------------

. 
. 
. 
. *First, I'll test my dep variable (net_sales) if the series is stationary or not.

. 
. 
. 
. *For this purpose I use ADF unit root test. The null hypothesis of the test assumes unit root (non-stationarity) in the data series 

. 
. *whereas the alternative hypothesis assumes the series to be stationary.

. 
. 
. 
. 
. 
. generate t=tm(2013m07)+_n-1

. 
. tsset month_t
        time variable:  month_t, 1 to 36
                delta:  1 unit

. 
. dfuller depvar, trend regress

Dickey-Fuller test for unit root                   Number of obs   =        35

                               ---------- Interpolated Dickey-Fuller ---------
                  Test         1% Critical       5% Critical      10% Critical
               Statistic           Value             Value             Value
------------------------------------------------------------------------------
 Z(t)             -4.178            -4.288            -3.560            -3.216
------------------------------------------------------------------------------
MacKinnon approximate p-value for Z(t) = 0.0048

------------------------------------------------------------------------------
D.depvar     |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      depvar |
         L1. |  -.6563434    .157101    -4.18   0.000    -.9763476   -.3363392
      _trend |   .0062128   .0019452     3.19   0.003     .0022505    .0101751
       _cons |     13.164   3.152847     4.18   0.000     6.741863    19.58614
------------------------------------------------------------------------------

. 
. 
. 
. *NOTE: You may run the test without including a trend. However, I decided to include a trend based on my visual analysis showing

. 
. *clear time trend in Net Sales series.

. 
. 
. 
. *The results are very ASTONISHING!!!!!! Though we saw a clear trend movement in net sales, the ADF test statistics reveal that the 

. 
. *series is stationari in levels, I(0), at better than 5% statistical significance. I strngly doubt ADF results for being suffering 

. 
. *from serial correlation, which normally proves a data series stationary wheras it is non-stationary actually.

. 
. 
. 
. *Let's see the correlatogram of Net Sales series to see if we find any evidence of serial correlation. Let's consider a maximum of 1
> 2 lags.

. 
. 
. 
. corrgram depvar, lags(12)

                                          -1       0       1 -1       0       1
 LAG       AC       PAC      Q     Prob>Q  [Autocorrelation]  [Partial Autocor]
-------------------------------------------------------------------------------
1        0.6825   0.6936   18.207  0.0000          |-----             |-----   
2        0.5612   0.2194   30.878  0.0000          |----              |-       
3        0.3648  -0.1279   36.396  0.0000          |--               -|        
4        0.2932   0.1255   40.071  0.0000          |--                |-       
5        0.3882   0.4102    46.72  0.0000          |---               |---     
6        0.3572   0.0117   52.537  0.0000          |--                |        
7        0.2983  -0.1132   56.735  0.0000          |--                |        
8        0.1874   0.0316   58.451  0.0000          |-                 |        
9        0.1299   0.1945   59.305  0.0000          |-                 |-       
10       0.0834  -0.2095   59.671  0.0000          |                 -|        
11       0.0581  -0.0995   59.856  0.0000          |                  |        
12       0.0162   0.0356   59.871  0.0000          |                  |        

. 
. 
. 
. *We can see that at 2nd lag, the spikes show a signigicant drop and this drop contnues till further lag addition of lags. 

. 
. *So, let's assume 2 lags for our ADF test regression, respectively, and re-estimate the ADF test.

. 
. 
. 
. dfuller depvar, lag(2) trend regress

Augmented Dickey-Fuller test for unit root         Number of obs   =        33

                               ---------- Interpolated Dickey-Fuller ---------
                  Test         1% Critical       5% Critical      10% Critical
               Statistic           Value             Value             Value
------------------------------------------------------------------------------
 Z(t)             -3.207            -4.306            -3.568            -3.221
------------------------------------------------------------------------------
MacKinnon approximate p-value for Z(t) = 0.0831

------------------------------------------------------------------------------
D.depvar     |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      depvar |
         L1. |  -.7076444   .2206737    -3.21   0.003    -1.159674   -.2556147
         LD. |    .109302   .2141641     0.51   0.614    -.3293933    .5479974
        L2D. |    .248576   .1716927     1.45   0.159    -.1031206    .6002726
      _trend |   .0064194   .0025283     2.54   0.017     .0012404    .0115984
       _cons |   14.19567   4.424096     3.21   0.003     5.133319    23.25802
------------------------------------------------------------------------------

. 
. 
. 
. *See, the series now turns out to be non-stationary, even at 5% statistical significance. Thus, I conclude that the dependent variab
> le for my model 

. 
. *is non-stationary in levels.

. 
. 
. 
. *Let's now see if the series become stationary upon considering it in its first-differenced form.

. 
. 
. 
. *First, we need to generate differenced dependent variable

. 
. 
. 
. *depvar_t - depvar_t-1

. 
. 
. 
. gen ddepvar=D.depvar
(1 missing value generated)

. 
. edit

. 
. 
. 
. *Now, test the differenced depvar series for unit root through ADF test

. 
. 
. 
. dfuller ddepvar, lag(2) trend regress

Augmented Dickey-Fuller test for unit root         Number of obs   =        32

                               ---------- Interpolated Dickey-Fuller ---------
                  Test         1% Critical       5% Critical      10% Critical
               Statistic           Value             Value             Value
------------------------------------------------------------------------------
 Z(t)             -4.379            -4.316            -3.572            -3.223
------------------------------------------------------------------------------
MacKinnon approximate p-value for Z(t) = 0.0024

------------------------------------------------------------------------------
D.ddepvar    |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     ddepvar |
         L1. |   -1.69572   .3872595    -4.38   0.000     -2.49031   -.9011288
         LD. |   .3673626   .3043404     1.21   0.238    -.2570923    .9918176
        L2D. |   .2322996   .1770767     1.31   0.201    -.1310316    .5956309
      _trend |  -.0002976   .0018271    -0.16   0.872    -.0040464    .0034513
       _cons |   .0205053   .0375134     0.55   0.589    -.0564658    .0974765
------------------------------------------------------------------------------

. 
. 
. 
. *The series now turns out to be stationary at better than 1% statistical significance.

. 
. 
. 
. *IMPLICATIONS: After conducting ADF test for net_sales series, I come to know that the series is first difference stationary that is
>  in its oriiginal

. 
. *state it is non-stationary. Alawys remember that never use a non-stationary data series is your regression model directly. Differen
> ce it first,

. 
. *make it stationary and then use it in your regression modelling.

. 
. 
. 
. *********

. 
. *STEP-3B

. 
. *********

. 
. 
. 
. *Augmented Dickey-Fuller (ADF) Unit Root Testing for R&D Intensity (Independent Variable)

. 
. *-----------------------------------------------------------------------------------------

. 
. 
. 
. *It's now time to determine the stationarity (no-stationarity) of our independent variable that R&D_Intensity. To cut short the disc
> ussion, I repeated all 

. 
. *the steps and procedures (which I did for knowing the stationarity (non-stationarity) in net sales) and found he R&D Intensity seri
> es also first 

. 
. *differenced stationary, I(1).

. 
. 
. 
. *I show you the ADF test results for differenced R&D Intensity series

. 
. 
. 
. gen dindpvar=D.indpvar
(1 missing value generated)

. 
. 
. 
. dfuller dindpvar, lag(2)trend regress

Augmented Dickey-Fuller test for unit root         Number of obs   =        32

                               ---------- Interpolated Dickey-Fuller ---------
                  Test         1% Critical       5% Critical      10% Critical
               Statistic           Value             Value             Value
------------------------------------------------------------------------------
 Z(t)             -5.776            -4.316            -3.572            -3.223
------------------------------------------------------------------------------
MacKinnon approximate p-value for Z(t) = 0.0000

------------------------------------------------------------------------------
D.dindpvar   |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    dindpvar |
         L1. |  -3.115785   .5394656    -5.78   0.000    -4.222677   -2.008893
         LD. |   1.033742   .3984837     2.59   0.015     .2161212    1.851363
        L2D. |   .2790665   .1881596     1.48   0.150    -.1070052    .6651382
      _trend |   .0000178   .0017765     0.01   0.992    -.0036272    .0036629
       _cons |   .0172361   .0369569     0.47   0.645    -.0585932    .0930655
------------------------------------------------------------------------------

. 
. 
. 
. *I can reject the null of non-stationarity (unit root) at very high statistical significance (bettern than 1% level).

. 
. 
. 
. *IMPLICATIONS: After conduction ADF test for R&D Intensity series, I come to know that the series is first difference stationary tha
> t is in its oriiginal

. 
. *state it is non-stationary, just like Net Sales series. These results point to estimate my proposed regression model for net sales 
> and R&D Intensity by 

. 
. *considering the two series in differenced form. 

. 
. 
. 
. ********

. 
. *STEP-4

. 
. ********

. 
. 
. 
. *Estimating the Regression Model

. 
. **********************************

. 
. 
. 
. *Let's now regress depvar on indepvar by considering the two series in differenced form. 

. 
. 
. 
. reg depvar indpvar

      Source |       SS           df       MS      Number of obs   =        36
-------------+----------------------------------   F(1, 34)        =      8.03
       Model |  .106259526         1  .106259526   Prob > F        =    0.0077
    Residual |  .450044689        34  .013236609   R-squared       =    0.1910
-------------+----------------------------------   Adj R-squared   =    0.1672
       Total |  .556304215        35  .015894406   Root MSE        =    .11505

------------------------------------------------------------------------------
      depvar |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     indpvar |   .5641542   .1991142     2.83   0.008     .1595054    .9688029
       _cons |   11.92792   2.928881     4.07   0.000     5.975723    17.88013
------------------------------------------------------------------------------

. 
. 
. 
. *The coefficient on indpvar (R&D Intensity) turns out to be statistically significant (at better than 5% statistical significance), 
> holding 

. 
. *a value of 0.28. This implies that two variables hold a direct relationship with each other that is as R&D Intensity increases volu
> me of 

. 
. *net sales grow and vice versa, a behavior highly compatible with economic theory. The coefficient value of R&D Intensity can be int
> erpreted 

. 
. *as 1 % rise (or fall) in R&D Intensity induces a rise (or fall) of 0.28% in net sales. 

. 
.   
. 
. *Let's analyse the scatter plot of residuals (by predicting the actual regression function and estimating the gap/difference between
>  our fitted

. 
. *(or estimated)regression with the actual regression. Here we plot the predicted residuals (in squared form as required by least squ
> ares regression) 

. 
. *against time. 

. 
. 
. 
. *Generating residuals

. 
. predict u, residual

. 
. edit

. 
. 
. 
. *Generating squared residuals

. 
. gen u2=u*u

. 
. edit

. 
. 
. 
. *Plotting squared residuals against indpvar (R&D Intensity)

. 
. 
. 
. scatter u2 indpvar

. 
. 
. 
. *From the visual analysis, plausiable presence of heteroskedasticity is not evident, since the variablity in errors 

. 
. *is pretty high at the start of our sample period and does not grow as the value of R&D Intensity(independent variable) increases.

. 
. 
. 
. 
. 
. ********

. 
. *STEP-4

. 
. ********

. 
. 
. 
. *Testing for Heteroskedasticity (Non-Constant Variance of Errors) in the Errors of Estimated Regression

. 
. ********************************************************************************************************

. 
. 
. 
. *Let's conduct the formal hetero test, i.e., Breusch Pagan Godfrey (BPG) test of heteroskedasticity. 

. 
. *The null hypothesis of the tests assumes homoskedasticity.

. 
. 
. 
. estat hettest

Breusch-Pagan / Cook-Weisberg test for heteroskedasticity 
         Ho: Constant variance
         Variables: fitted values of depvar

         chi2(1)      =     4.03
         Prob > chi2  =   0.0446

. 
. 
. 
. *Looking at the chi statistics of the tests and the probability value, we accept the null of homoskedasticity. 

. 
. *Thus, there's no issue of heteroskedasticity in our estimated regression errors. Error of the variance is certainly constant, a con
> dition 

. 
. *mandatory for obtaining consistent and robust regression estimates.

. 
. 
. 
. ********

. 
. *STEP-5

. 
. ********

. 
. 
. 
. *Testing for Auto/Serial Correlation (Correlated Errors) in the Errors of Estimated Regression

. 
. ***********************************************************************************************

. 
. 
. 
. *Let's conduct the formal hetero test that is Breusch-Godfrey LM test for autocorrelation. 

. 
. *The null hypothesis of the tests assumes no serial correlation in errors.

. 
. 
. 
. estat bgodfrey

Breusch-Godfrey LM test for autocorrelation
---------------------------------------------------------------------------
    lags(p)  |          chi2               df                 Prob > chi2
-------------+-------------------------------------------------------------
       1     |         13.619               1                   0.0002
---------------------------------------------------------------------------
                        H0: no serial correlation

. 
. 
. 
. *Looking at the chi statistics of the tests and the probability value, we reject the null of no serial correlation at 5% sttistical 
> significance. 

. 
. *Thus, there certainly exists issue of heteroskedasticity in our estimated regression errors. Error of the variance are certainly co
> rrelated, 

. 
. *a situation violating the mandatory condition of 'no auto/serial correlation' for obtaining consistent and robust regression estima
> tes.

. 
. 
. 
. *CONTROLLING FOR HETEROSKEDASTICITY AND SERIAL CORRELATION - ROBUST REGRESSION MODELS

. 
. **************************************************************************************

. 
. 
. 
. *As we have talked earlier, in the presence of heter and/or auto, the standard Ordinary Least Squares regression model does not

. 
. *generate efficient and consistent estimates. In case both or any of these two mandatory conditions are not fully met, we seek

. 
. *help from robust regression models 

. 
. 
. 
. *********************************************************

. 
. *MODEL-I: Regression with White's Robust Standard Errors

. 
. *********************************************************

. 
. 
. 
. *Under this type of robust regression, we adjust the standard errors to ficx the issue of heteroskedasticity only.

. 
.  
. 
. *Specifying the vce(robust) option is equivalent to requesting for the White-corrected standard errors in the presence of heterosked
> asticity. 

. 
. *Thus here we favor the robust standard errors,i.e., obtaining robust variance estimates.

. 
. 
. 
. regress ddepvar dindpvar, vce(robust)

Linear regression                               Number of obs     =         35
                                                F(1, 33)          =       4.65
                                                Prob > F          =     0.0385
                                                R-squared         =     0.1296
                                                Root MSE          =     .09527

------------------------------------------------------------------------------
             |               Robust
     ddepvar |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    dindpvar |    .285075   .1322477     2.16   0.039     .0160151    .5541349
       _cons |  -.0003295   .0164808    -0.02   0.984    -.0338601     .033201
------------------------------------------------------------------------------

. 
. 
. 
. * Where 'vce' stands for variance consistent errors.

. 
. 
. 
. *NOTE

. 
. 
. 
. *(i) Use this type of model only when you firmly beleive that the errors are suffering from heteroskedasticity

. 
. *(ii) Observe that coefficient estimates from simple and robust regression models are exactly same, and the issue 

. 
. *of hetero is fixed through adjustments in S.Es.

. 
. 
. 
. 
. 
. *****************************************************************

. 
. *Regression with Hetero anu Auto Consistent(HAC) Standard Errors

. 
. *****************************************************************

. 
. 
. 
. *Under this type of robust regression model, we make an adjustment of 

. 
. 
. 
. *(a) Standard errors (just like previous model of robust regression) to fix the issue of heteroskedasticity

. 
. 
. 
. *(b) Include a certain number of lags to fix the problem of serial correlation 

. 
. *Newey –West standard errors for coefficients estimated by OLS regression. 

. 
. 
. 
. *NOTE: Use this type of model only when you firmly beleive that the errors are suffering from heteroskedasticity 

. 
. *and possibly autocorrelation up to some specific number of lags.

. 
. 
. 
. * Supposidly, for the relationship between net sales and R&D Intensity, we beleive that autocorrelation exists upto 2 lags. We now w
> ish to fit an OLS model but want to obtain

. 
. *Newey –West HAC standard errors allowing for a lag of up to 2.

. 
. 
. 
. newey ddepvar dindpvar, lag(2)

Regression with Newey-West standard errors      Number of obs     =         35
maximum lag: 2                                  F(  1,        33) =       3.88
                                                Prob > F          =     0.0574

------------------------------------------------------------------------------
             |             Newey-West
     ddepvar |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    dindpvar |    .285075   .1448093     1.97   0.057    -.0095417    .5796918
       _cons |  -.0003295    .014287    -0.02   0.982    -.0293968    .0287377
------------------------------------------------------------------------------

. 
. 
. 
. *NOTE: If we put lag(0) in Newey West OLS, the resultant regression will be simply the vce(robust) model estimated above. 

. 
. 
. 
. 
. 

