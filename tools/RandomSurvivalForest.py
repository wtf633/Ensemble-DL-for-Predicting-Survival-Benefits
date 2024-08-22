import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
import pathlib
import scipy.io as sio
import warnings
import os
import shutil
import datetime
import numpy as np
import joblib
from openpyxl import load_workbook
import matplotlib.pyplot as plt
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import GridSearchCV, StratifiedKFold, cross_val_score
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier, StackingClassifier
from sklearn.calibration import CalibratedClassifierCV
from multiprocessing import cpu_count
warnings.simplefilter(action='ignore')
from sksurv.ensemble import RandomSurvivalForest, GradientBoostingSurvivalAnalysis
from sklearn.preprocessing import StandardScaler
# root_dir = pathlib.Path.cwd()

root_dir = pathlib.Path("Q:/sample/dataset")
directory = "Q:/sample/result"
# Check if the directory exists, if not, create it
if not os.path.exists(directory):
    os.makedirs(directory)
'''-----Training data-----'''
train_path = os.path.join(root_dir, 'OS', "train_cohort.csv")
df_train = pd.read_csv(train_path)
x_train = df_train.loc[:, 'Network1':'Network3']
x_train = x_train.to_numpy('float32')

'''convert y labels to structured array'''
os_status = df_train['OS_status'].tolist()
os_time = df_train['OS_time'].tolist()
y_train = np.zeros(len(df_train), dtype={'names': ('OS_status', 'OS_time'),
                                         'formats': ('bool', 'f8')})
y_train['OS_status'] = os_status
y_train['OS_time'] = os_time
del os_status, os_time, df_train

'''-----validation data-----'''
valid_path = os.path.join(root_dir, 'OS', "valid_cohort.csv")
df_valid = pd.read_csv(valid_path)
x_valid = df_valid.loc[:, 'Network1':'Network3']
x_valid = x_valid.to_numpy('float32')
## convert y labels to structured array
os_status = df_valid['OS_status'].tolist()
os_time = df_valid['OS_time'].tolist()
y_valid = np.zeros(len(df_valid), dtype={'names': ('OS_status', 'OS_time'),
                                         'formats': ('bool', 'f8')})
y_valid['OS_status'] = os_status
y_valid['OS_time'] = os_time
del os_status, os_time, df_valid

'''-----testing data-----'''
test_path = os.path.join(root_dir, 'OS', "test_cohort.csv")
df_test = pd.read_csv(test_path)
x_test = df_test.loc[:, 'Network1':'Network3']
x_test = x_test.to_numpy('float32')
## convert y labels to structured array
os_status = df_test['OS_status'].tolist()
os_time = df_test['OS_time'].tolist()
y_test = np.zeros(len(df_test), dtype={'names': ('OS_status', 'OS_time'),
                                       'formats': ('bool', 'f8')})
y_test['OS_status'] = os_status
y_test['OS_time'] = os_time
del os_status, os_time, df_test
'''-----TCGA data-----'''
TCGA_path = os.path.join(root_dir, 'OS', "TCGA_cohort.csv")
df_TCGA = pd.read_csv(TCGA_path)

x_TCGA = df_TCGA.loc[:, 'Network1':'Network3']
x_TCGA = x_TCGA.to_numpy('float32')

random_state = 88
rsf = RandomSurvivalForest(n_estimators=500,  # 500
                           min_samples_split=5,  # 5
                           min_samples_leaf=2,  # 2
                           max_features="sqrt",
                           n_jobs=None,
                           max_depth=2,  # 6 2
                           random_state=random_state)
rsf.fit(x_train, y_train)
train_ci = rsf.score(x_train, y_train)
valid_ci = rsf.score(x_valid, y_valid)
test_ci = rsf.score(x_test, y_test)
print("Train CI: ", round(train_ci, 2))
print("Valid CI: ", round(valid_ci, 2))
print("Test CI: ", round(test_ci, 2))

risk_train = rsf.predict(x_train)
risk_valid = rsf.predict(x_valid)
risk_test = rsf.predict(x_test)
risk_TCGA = rsf.predict(x_TCGA)

risk_train_path = os.path.join(directory, "risk_train.csv")
risk_valid_path = os.path.join(directory, "risk_valid.csv")
risk_test_path = os.path.join(directory, "risk_test.csv")
risk_TCGA_path = os.path.join(directory, "risk_TCGA.csv")

pd.DataFrame(risk_train, columns=["risk_train"]).to_csv(risk_train_path, index=False)
pd.DataFrame(risk_valid, columns=["risk_valid"]).to_csv(risk_valid_path, index=False)
pd.DataFrame(risk_test, columns=["risk_test"]).to_csv(risk_test_path, index=False)
pd.DataFrame(risk_TCGA, columns=["risk_TCGA"]).to_csv(risk_TCGA_path, index=False)

print("Risk predictions for the train set saved to:", risk_train_path)
print("Risk predictions for the validation set saved to:", risk_valid_path)
print("Risk predictions for the test set saved to:", risk_test_path)
