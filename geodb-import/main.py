import geopandas
import psycopg2

dbconfig = {
    'database': 'REDACTED',
    'port': 5432,
    'host': 'localhost',
    'user': 'REDACTED',
    'password': 'REDACTED'
}

if __name__ == '__main__':
    data = geopandas.read_file('../SPIGeoDB.gdb')

    # spatial reference ID
    print(data.crs.to_epsg())
    print(data.columns)

    try:
        with psycopg2.connect(**dbconfig) as dbconn:
            with dbconn.cursor() as cursor:
                for index, row in data.loc[:, ['DOCUMENT_REFERENCE_ID', 'geometry', 'SPI_POLYGON_ID']].iterrows():
                    cursor.execute(
                        'insert into public.imported_geo_data (spi_document_reference, spi_polygon_id, geo) values (%s, %s, %s)',
                        (row['DOCUMENT_REFERENCE_ID'], row['SPI_POLYGON_ID'], str(row['geometry'])))


    except (psycopg2.DatabaseError, Exception) as error:
        print(error)
