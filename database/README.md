# Data
This folder contains all the data used at the two stages of the project.
1. **raw-data** folder: Contains the Dataset as downloaded from [Kaggle](https://www.kaggle.com/datasets/mexwell/famous-paintings/data).
2. **processed-data** folder: Contains the Dataset after the Data Cleaning & Preparation phase. This is the Dataset used in **PGAdmin4**

## Data Cleaning & Preparation
In this phase we perform multiple steps:
- Data Loading and Inspection.
- Data Cleaning and Formatting.
- Data Validation and Accuracy

We need to make sure that the format of all the `.csv` is suitable to be imported into the tables in **PGAdmin4**. 
We are going to need to work with a Dataset that is as similar as possible to the one on [Kaggle](https://www.kaggle.com/datasets/mexwell/famous-paintings/data). This means that **Handling Missing values** is not the something we perform on this Dataset as some of the questions to be solved will need this *NULL* values to be present.

The `work.csv` file is the only file that needs **Data Cleaning and Formatting**. The reason are the quotations present on some strings in the `name` column. In this project, the approach to handle this is to remove the quotations on every row. This does not have an impact on the results or the way that the Dataset has to be handle.
