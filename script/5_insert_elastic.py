from elasticsearch import Elasticsearch
from elasticsearch import helpers
import psycopg2
import pandas as pd
import sys

INPUT_CODE_COMMENTS_CSV = 'filtered_data.csv'
ES_INDEX = 'docker_code_comments'
ES_BULK_SIZE = 10000

db = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
host = sys.argv[4]
port = sys.argv[5]

db_params = {
    'database': db,
    'user': user,
    'password': password,
    'host': host,
    'port': port
}

es_params = {
    'host': 'localhost',
    'port': 9200
}

es_mapping = {
    "mappings": {
        "properties": {
            "dockerfile_sha1": {
                "type": "keyword"
            },
            "comment_clean": {
                "type": "text"
            },
            "dockerfile_blob": {
                "type": "text"
            }
        }
    }
}


def setup_es(es):
    es.indices.create(
        index=ES_INDEX,
        body=es_mapping
    )


def main(es):
    df = pd.read_csv(INPUT_CODE_COMMENTS_CSV, engine="c")
    df.dropna(inplace=True)

    con = psycopg2.connect(**db_params)
    cur = con.cursor()
    query = "SELECT b.content FROM blob as b WHERE b.sha1=%s"

    actions = list()
    for index, row in df.iterrows():
        print(f'{index+1}')
        cur.execute(query, (row['dockerfile_sha1'],))
        row['dockerfile_blob'] = cur.fetchone()[0]
        actions.append({"_id": index, "_index": ES_INDEX, "_source": row.to_dict()})
        if len(actions) == ES_BULK_SIZE:
            helpers.bulk(es, actions)
            actions = list()

    helpers.bulk(es, actions)

    print('*** done ***')


if __name__ == '__main__':
    es = Elasticsearch(hosts=[es_params])
    if not es.indices.exists(ES_INDEX):
        setup_es(es)
    main(es)