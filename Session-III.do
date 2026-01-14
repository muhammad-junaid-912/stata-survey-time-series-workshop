
*Converting the Column of Month from String to Numeric Variable
****************************************************************
encode month, gen(month_t)
order month_t netsales rdintensity month

*ESTIMATING THE LINEAR REGRESSION FUNCTION

********
*STEP-1
********

*Let's analyse the following industry relationship, employing Sitara Chemical Data

*        Net Sales (Dependent Variable) = f(R&D Intensity)
*        Net_Sale = f(R&D_Intensity)

*First of all, we'll title two variables as dependent variable (depvar) and independent variable (indpvar), respectively.

gen depvar=ln(netsales)
gen indpvar=ln(rdintensity)

*Let's see how the two series look like after taking their log

edit

********
*STEP-2
********

*Detecting Non-Stationarity in Industry Data through Visual Inspection - Time Plots of Net Sales and R&D Intensity 
*------------------------------------------------------------------------------------------------------------------

*If two series rise and/or fall along time, i.e., they display a clear time trend, such a behavior can be taken as an 
*evidence in favor of their non-stationary nature.

graph twoway (line depvar month_t)
graph twoway (line indpvar month_t)

*From the graphs, we may clearly see that both series trend upwards over the sample period. Thus, it is highly likely that
*the to series are no-stationary.

*********
*STEP-3
*********

*Formal Testing of Non-Stationarity - Determining the Order of Integration of Net Sales and R&D Intensity
*---------------------------------------------------------------------------------------------------------

*Let's now test the order of integration of two time-series. The purpose of conducting unit root testing is to figure (i) if the 
*two series contain unit root, (ii) how many? and, (iii) for how many times we need to difference the series to make it stationary 
*and thus eligble for our regression analysis.

*********
*STEP-3A
*********

*Augmented Dickey-Fuller (ADF) Unit Root Testing for Net_Sales (Dependent Variable)
*-------------------------------------------------------------------------------

*First, I'll test my dep variable (net_sales) if the series is stationary or not.

*For this purpose I use ADF unit root test. The null hypothesis of the test assumes unit root (non-stationarity) in the data series 
*whereas the alternative hypothesis assumes the series to be stationary.


generate t=tm(2013m07)+_n-1
tsset month_t
dfuller depvar, trend regress

*NOTE: You may run the test without including a trend. However, I decided to include a trend based on my visual analysis showing
*clear time trend in Net Sales series.

*The results are very ASTONISHING!!!!!! Though we saw a clear trend movement in net sales, the ADF test statistics reveal that the 
*series is stationari in levels, I(0), at better than 5% statistical significance. I strngly doubt ADF results for being suffering 
*from serial correlation, which normally proves a data series stationary wheras it is non-stationary actually.

*Let's see the correlatogram of Net Sales series to see if we find any evidence of serial correlation. Let's consider a maximum of 12 lags.

corrgram depvar, lags(12)

*We can see that at 2nd lag, the spikes show a signigicant drop and this drop contnues till further lag addition of lags. 
*So, let's assume 2 lags for our ADF test regression, respectively, and re-estimate the ADF test.

dfuller depvar, lag(2) trend regress

*See, the series now turns out to be non-stationary, even at 5% statistical significance. Thus, I conclude that the dependent variable for my model 
*is non-stationary in levels.

*Let's now see if the series become stationary upon considering it in its first-differenced form.

*First, we need to generate differenced dependent variable

*depvar_t - depvar_t-1

gen ddepvar=D.depvar
edit

*Now, test the differenced depvar series for unit root through ADF test

dfuller ddepvar, lag(2) trend regress

*The series now turns out to be stationary at better than 1% statistical significance.

*IMPLICATIONS: After conducting ADF test for net_sales series, I come to know that the series is first difference stationary that is in its oriiginal
*state it is non-stationary. Alawys remember that never use a non-stationary data series is your regression model directly. Difference it first,
*make it stationary and then use it in your regression modelling.

*********
*STEP-3B
*********

*Augmented Dickey-Fuller (ADF) Unit Root Testing for R&D Intensity (Independent Variable)
*-----------------------------------------------------------------------------------------

*It's now time to determine the stationarity (no-stationarity) of our independent variable that R&D_Intensity. To cut short the discussion, I repeated all 
*the steps and procedures (which I did for knowing the stationarity (non-stationarity) in net sales) and found he R&D Intensity series also first 
*differenced stationary, I(1).

*I show you the ADF test results for differenced R&D Intensity series

gen dindpvar=D.indpvar

dfuller dindpvar, lag(2)trend regress

*I can reject the null of non-stationarity (unit root) at very high statistical significance (bettern than 1% level).

*IMPLICATIONS: After conduction ADF test for R&D Intensity series, I come to know that the series is first difference stationary that is in its oriiginal
*state it is non-stationary, just like Net Sales series. These results point to estimate my proposed regression model for net sales and R&D Intensity by 
*considering the two series in differenced form. 

********
*STEP-4
********

*Estimating the Regression Model
**********************************

*Let's now regress depvar on indepvar by considering the two series in differenced form. 

reg depvar indpvar

*The coefficient on indpvar (R&D Intensity) turns out to be statistically significant (at better than 5% statistical significance), holding 
*a value of 0.28. This implies that two variables hold a direct relationship with each other that is as R&D Intensity increases volume of 
*net sales grow and vice versa, a behavior highly compatible with economic theory. The coefficient value of R&D Intensity can be interpreted 
*as 1 % rise (or fall) in R&D Intensity induces a rise (or fall) of 0.28% in net sales. 
  
*Let's analyse the scatter plot of residuals (by predicting the actual regression function and estimating the gap/difference between our fitted
*(or estimated)regression with the actual regression. Here we plot the predicted residuals (in squared form as required by least squares regression) 
*against time. 

*Generating residuals
predict u, residual
edit

*Generating squared residuals
gen u2=u*u
edit

*Plotting squared residuals against indpvar (R&D Intensity)

scatter u2 indpvar

*From the visual analysis, plausiable presence of heteroskedasticity is not evident, since the variablity in errors 
*is pretty high at the start of our sample period and does not grow as the value of R&D Intensity(independent variable) increases.


********
*STEP-4
********

*Testing for Heteroskedasticity (Non-Constant Variance of Errors) in the Errors of Estimated Regression
********************************************************************************************************

*Let's conduct the formal hetero test, i.e., Breusch Pagan Godfrey (BPG) test of heteroskedasticity. 
*The null hypothesis of the tests assumes homoskedasticity.

estat hettest

*Looking at the chi statistics of the tests and the probability value, we accept the null of homoskedasticity. 
*Thus, there's no issue of heteroskedasticity in our estimated regression errors. Error of the variance is certainly constant, a condition 
*mandatory for obtaining consistent and robust regression estimates.

********
*STEP-5
********

*Testing for Auto/Serial Correlation (Correlated Errors) in the Errors of Estimated Regression
***********************************************************************************************

*Let's conduct the formal hetero test that is Breusch-Godfrey LM test for autocorrelation. 
*The null hypothesis of the tests assumes no serial correlation in errors.

estat bgodfrey

*Looking at the chi statistics of the tests and the probability value, we reject the null of no serial correlation at 5% sttistical significance. 
*Thus, there certainly exists issue of heteroskedasticity in our estimated regression errors. Error of the variance are certainly correlated, 
*a situation violating the mandatory condition of 'no auto/serial correlation' for obtaining consistent and robust regression estimates.

*CONTROLLING FOR HETEROSKEDASTICITY AND SERIAL CORRELATION - ROBUST REGRESSION MODELS
**************************************************************************************

*As we have talked earlier, in the presence of heter and/or auto, the standard Ordinary Least Squares regression model does not
*generate efficient and consistent estimates. In case both or any of these two mandatory conditions are not fully met, we seek
*help from robust regression models 

*********************************************************
*MODEL-I: Regression with White's Robust Standard Errors
*********************************************************

*Under this type of robust regression, we adjust the standard errors to ficx the issue of heteroskedasticity only.
 
*Specifying the vce(robust) option is equivalent to requesting for the White-corrected standard errors in the presence of heteroskedasticity. 
*Thus here we favor the robust standard errors,i.e., obtaining robust variance estimates.

regress ddepvar dindpvar, vce(robust)

* Where 'vce' stands for variance consistent errors.

*NOTE

*(i) Use this type of model only when you firmly beleive that the errors are suffering from heteroskedasticity
*(ii) Observe that coefficient estimates from simple and robust regression models are exactly same, and the issue 
*of hetero is fixed through adjustments in S.Es.


*****************************************************************
*Regression with Hetero anu Auto Consistent(HAC) Standard Errors
*****************************************************************

*Under this type of robust regression model, we make an adjustment of 

*(a) Standard errors (just like previous model of robust regression) to fix the issue of heteroskedasticity

*(b) Include a certain number of lags to fix the problem of serial correlation 
*Newey –West standard errors for coefficients estimated by OLS regression. 

*NOTE: Use this type of model only when you firmly beleive that the errors are suffering from heteroskedasticity 
*and possibly autocorrelation up to some specific number of lags.

* Supposidly, for the relationship between net sales and R&D Intensity, we beleive that autocorrelation exists upto 2 lags. We now wish to fit an OLS model but want to obtain
*Newey –West HAC standard errors allowing for a lag of up to 2.

newey ddepvar dindpvar, lag(2)

*NOTE: If we put lag(0) in Newey West OLS, the resultant regression will be simply the vce(robust) model estimated above. 


