# GEODB Import

This directory is a Python package for importing the contents of a GeoDB into a temporary table for use by the import
scripts using GeoPandas.

Run in a Virtualenv and use pip to install the requirements

eg:

`virtualenv venv`
`source ./venv/bin/activate`
`pip3 install -r requirements.txt`

Edit `main.py` to set GeoDB file location and PostgreSQL login as appropriate for your environment.
and run `python3 main.py`

When complete, the table `imported_geo_data` should contain an accurate representation of the contents of the GeoDB
ready for linking.
