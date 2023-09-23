import numpy as np
import csv
from sklearn.model_selection import train_test_split
from catboost import CatBoostClassifier, Pool

output_folder = 'dataset'
gests = ['fire', 'water', 'stone', 'wind', 'kon']
X = {}

for gest in  gests:
    file = open(output_folder + '/' + 'gest_' + gest + '.csv')
    X[gest] = []
    for row in file:
        X[gest].append(np.array(row.split(','), dtype= float))

for gest in gests:
    X[gest] = np.array(X[gest])
    print(len(X[gest]))

data = {}
for gest in gests:
    data[gest] = np.hstack([X[gest][:-2], X[gest][1:-1], X[gest][2:]])

X = []
y = []

for i, gest in enumerate(gests):
    for feature in data[gest]:
        X.append(feature)
        y.append(i)

X = np.array(X)
y = np.array(y)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size= 0.1, shuffle= True)
eval_pool = Pool(X_test, y_test)
model = CatBoostClassifier(loss_function= 'MultiClass')

model.fit(X_train, y_train, eval_set= eval_pool, early_stopping_rounds= 10)
print(model.score(X_test, y_test))
print(model.predict_proba(X_test))
print(y_test)

model.save_model('gest_model')
