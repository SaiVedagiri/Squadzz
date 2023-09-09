import requests
import argparse
import os
from dotenv import load_dotenv

parser = argparse.ArgumentParser()
parser.add_argument('latitude', help='latitude of point from which to do radial search')
parser.add_argument('longitude', help='longitude of point from which to do radial search')
parser.add_argument('out', help='output directory for file with place IDs')
parser.add_argument('--radius', '-rad', help='radius to search within', default=500)
parser.add_argument('--type', '-t', help='type of location to search for', default='')
parser.add_argument('--keyword', '-kwd', help='keywords to search for', default='')

# usage: find_place_ids.py [-h] [--radius RADIUS] [--type TYPE] [--keyword KEYWORD] latitude longitude out

# positional arguments:
#   latitude              latitude of point from which to do radial search
#   longitude             longitude of point from which to do radial search
#   out                   output directory for file with place IDs

# options:
#   -h, --help            show this help message and exit
#   --radius RADIUS, -rad RADIUS
#                         radius to search within
#   --type TYPE, -t TYPE  type of location to search for
#   --keyword KEYWORD, -kwd KEYWORD
#                         keywords to search for

def get_place_ids_from_latlon(lat, lon, radius=500, type='', kwd=''):
    params = {
        'location' : '{},{}'.format(lat, lon),
        'key' : os.getenv('PENNAPPS_GOOGLE_API_KEY'), 
        'radius' : radius
    }

    if type != '':
        params['type'] = type
    if kwd != '':
        params['keyword'] = kwd

    results = requests.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', params=params).json()
    ids = [place['place_id'] for place in results['results']]
    return ids

# code to run
load_dotenv()
args = parser.parse_args()

place_ids = get_place_ids_from_latlon(args.latitude, args.longitude, args.radius, args.type, args.keyword)
with open(args.out, 'w') as file:
    for pid in place_ids:
        file.write(pid + '\n')
