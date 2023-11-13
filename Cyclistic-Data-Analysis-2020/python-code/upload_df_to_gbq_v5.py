from google.cloud import bigquery
from google.cloud.exceptions import NotFound
import pandas as pd
import glob
import pandas_gbq
import os.path



def check_path(path):
    """_summary_

    Args:
        path (any): dir or file path

    Raises:
        KeyError: when path_type=-2, not applicable file type (expect csv or csv.gzip)
        KeyError: when path_type=-1, path does not exist

    Returns:
        int: to enumarate expected path types (csv, csv.gzip, and dir/folder)
    """
    # EXPECT: csv, csv.gzip, folder
    if os.path.isdir(path):
        path_type = 0 
    elif os.path.isfile(path):
        if path[-4:] == ".csv":
            path_type = 1
        elif path[-9:] == ".csv.gzip":
            path_type = 2
        else:
            path_type = -2 # unknown file type
            print("\n-------[ERROR]: not applicable file type-------\n")
            raise KeyError(path)
    else:
        path_type = -1 
        print("\n-------[ERROR]: input path does not exist-------\n")
        raise KeyError(path)
    return path_type

def get_df_from_(path):
    """_summary_

    Args:
        path (any): path_dir or path_to_file

    Returns:
        DataFrame: df_out to upload to GBQ
    """
    path_type = check_path(path)
    if path_type==1: 
        #get df from csv
        df_out = pd.read_csv(path)
    elif path_type==2:
        #get df from csv.gzip file
        df_out = pd.read_csv(path, compression = 'gzip')
    else:
        #--path is folder
        #get all csv file names in path folder
        allFiles = glob.glob(path + "/*.csv") #excludes '.csv.gzip'
        allFiles.sort()
        #extra dfs from allFiles into df_out
        df_out = pd.DataFrame()
        for i, fname in enumerate(allFiles):
            if i != 0:
                df = pd.read_csv(fname, skiprows = 0)
            else:
                df = pd.read_csv(fname)
            df_out = pd.concat((df, df_out), axis=0)
    return df_out

def view_table_prop(table):
    schema_len = len(table.schema)
    if schema_len > 0:
        schema_names = ["{}".format(schema.name) for schema in table.schema] # table.schema is list of SchemaField(...)
        schema_field_types = ["{}".format(schema.field_type) for schema in table.schema] 
        result = pd.DataFrame({"schema_name": schema_names, "field_type": schema_field_types})
        print("==================================")
        print(result)
    print("==================================")
    print("Table has {} total schema_fields".format(schema_len))
    print("Table has {} rows".format(table.num_rows))
    print("==================================")

def update_table_view(table_id):
    try:
        table = client.get_table(table_id)  # Make an API request.
        # print("Table {} already exists.".format(table_id))
        view_table_prop(table)
    except:
        print("Table \"{}\" is not found.".format(table_id))
        
    

def upload_to_gbq(path, table_id, project_id):
    print("getting df...")
    df_out = get_df_from_(path)
    print("uploading to gbq...")
    pandas_gbq.to_gbq(df_out, table_id, project_id=project_id)
    print("done.")

def main(path, table_id, project_id):
    print("====================================================================")
    try:
        table = client.get_table(table_id)  # Make an API request.
        print("Table {} already exists.".format(table_id))
        # View Table Properties
        view_table_prop(table)
        if (len(table.schema)==0 and table.num_rows==0):
            #populate empty table
            print("populating empty table...")
            upload_to_gbq(path, table_id=table_id, project_id=project_id)
            update_table_view(table_id)
        else:
            print("Full table id: \`{}\`".format(table_id))
            print("==================================")
            user_yn = input('Would you like to replace table? (y/n)\n')
            if user_yn.lower() == 'y':
                print("deleting old table...")
                client.delete_table(table_id)
                print("creating new table...")
                client.create_table(table_id)
                upload_to_gbq(path, table_id=table_id, project_id=project_id)
                update_table_view(table_id)
        
    except NotFound:
        print("Table \"{}\" is not found.".format(table_id))
        user_yn2 = input('Would you like to create table? (y/n)\n')
        if user_yn2.lower() == 'y':
            print("Creating new table...")
            table = bigquery.Table(table_id) #, schema=schema) 
            table = client.create_table(table)  # Make an API request.
            print("Done.")
            upload_to_gbq(path, table_id=table_id, project_id=project_id)
            update_table_view(table_id)

##################################################################################################################################

if __name__ == '__main__':
    #======================================================
    # Manage credentials in COMMAND PROMPT if necessary
    # gcloud auth application-default login
    # gcloud auth application-default revoke
    #======================================================
    client = bigquery.Client()
    
    #=======================================================================
    ## TODO: Set project_id to your Google Cloud Platform project ID.
    project_id = "case-study1-bike-share"
    ## TODO: Set table_id to the full destination table ID.
    # ----> table_id = 'project.dataset.table'
    dataset_name = "divvy_trips_2020_data"
    table_name = input('Please name the table you wish to create table?\n') #"divvy_trips_2020_12"
    table_name = table_name.strip() #remove leading & trailing whitespaces
    table_id = project_id + '.' + dataset_name + '.' + table_name
    #=======================================================================
    ## TODO: Set path of csv/folder to upload
    path = r"C:\Users\Cristian Arevalo\Downloads\Divvy_Trips_2020_Bucket"
    path = path + r"\Divvy_Trips_2020_Q1"
    path_type = check_path(path) #just to see
    # print('\n----\npath_type = ' + str(path_type) + ' (csv=1, csv_gzip=2, folder = 0)\n----')
    #=======================================================================
    
    main(path, table_id, project_id)
    
    # FIXME: BIG MISTAKE
    # CHANGE SCHEMA BEFORE BLAST OFF to avoid extra work
    # This has to be fix after getting df from file(s)