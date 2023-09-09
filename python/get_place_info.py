import requests
import argparse
import os
from dotenv import load_dotenv
import json

parser = argparse.ArgumentParser()
parser.add_argument('id', help='google place id to collect information about')

# stores output to the file: <place>.json
# usage: get_place_info.py [-h] id out

# positional arguments:
#   id          google place id to collect information about
#   out         output directory for json file with place information

# options:
#   -h, --help  show this help message and exit

def get_info_from_id(id):
    ret_fields = ['name', 'delivery', 'dine_in', 'price_level', 'rating', 'reservable', 'serves_breakfast', 'serves_brunch', 'serves_dinner', 'serves_lunch', 'serves_vegetarian_food', 'takeout', 'reviews']
    params = {
        'place_id' : id,
        'key' : os.getenv('PENNAPPS_GOOGLE_API_KEY'),
        'fields' : ','.join(ret_fields),
        'reviews_sort' : 'most_relevant'
    }
    results = requests.get('https://maps.googleapis.com/maps/api/place/details/json', params=params).json()
    name = results['result']['name']
    info = {}
    reviews = []
    for rev in results['result']['reviews']:
        rating_review = {}
        rating_review['rating'] = rev['rating']
        rating_review['review'] = rev['text']
        reviews.append(rating_review)
    info['reviews'] = reviews

    # add other fields
    for f in ret_fields[:-1]:
        if f in results['result']:
            f_new = f
            if '_' in f:
                f_new = ' '.join(f.split('_'))
            info[f_new] = results['result'][f]

    return name, info

# code to run
load_dotenv()
args = parser.parse_args()

name, info = get_info_from_id(args.id)
with open('{}.json'.format(name), 'w') as file:
    json.dump(info, file)