# App

Preprocess csv file to dedupe.

## Installation

```
$ git clone git@github.com:tmartin8080/preprocess-csv.git
$ cd preprocess-csv
```

## Example Data

There is an example `data.csv` in the app root, that has some
issues in it.
- There are spaces between the columns.
- There are a few duplicates by email and phone.
- One line has an extra field.
- Different case emails.

## Mix Task

The preprocessor is set up as a mix task with 2 args:

```
$ mix app.preprocess_users <filepath>  <dedup-strategy>

Example:
$ mix app.preprocess_users data.csv email
```

This processed file will be exported to:

```
priv/preprocessed/processed-<filename>-<date>.csv
```

## Run Tests

```
$ mix test
```
