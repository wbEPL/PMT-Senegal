# This repo includes the needed code to estimate senegal pmt with 2021 survey data

First run 00_init.do

Run 00_run.do to replicate results.

## Step 1
The step 1 creates the data, it is split in several different files per topic of the survey. It creates dummy versions, numeric versions and ordinal versions (not owned, owns one, owns more than one) off all livestock and asset variables. In the models only the dummies are used.

## Step 2
This step estimates the following models:
- OLS models with similar covariates as 2015 PMT
- Lasso with all relevant covariates, assets and livestock as dummies (lasso 1). This model is used to manipulate lambda. 
- Lasso with all relevant covariates, assets and livestock as numeric (lasso 2). This model is used to manipulate lambda.
- Lasso starting with 2015 covariates (lasso 3)

I have chosen the following lambdas of lasso models 1 and 2 to graph, besides the one chosen by the lasso stata algorithm:

| Model    | Lambdas           |
| -------- | ----------------  |
| Rural 1  | 0.01, 0.03, 0.05  |
| Rural 2  | 0.02, 0.03, 0.05  |
| Urban 1  | 0.025, 0.05, 0.08 |
| Urban 2  | 0.04, 0.06, 0.08  |


## Results files:
On folder results you will find:
- accuracy2015vs2021.xlsx: accuracies all models on full sample (this is only for lasso selected lambda)
- accuracy2015vs2021_testsample.xlsx: accuracies all model on testing sample (this is only for lasso selected lambda)
- accuracies_rural1.xlsx: accuracies on testing rural sample for different lamdas for lasso 1
- accuracies_rural2.xlsx: accuracies on testing rural sample for different lamdas for lasso 2
- accuracies_urban1.xlsx: accuracies on testing urban sample for different lamdas for lasso 1
- accuracies_urban2.xlsx: accuracies on testing urban sample for different lamdas for lasso 2
- rural_coefficients.xls: rural coefficients for all models
- urban_coefficients.xls: urban coefficients for all models
- graphs: folder of cvplots, following convention cvplot_model.gph
