import os
import requests
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-address', nargs='+')

args = parser.parse_args()

def getCoords():

    response = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params={"address": args.address[0], "key": os.getenv("GOOGLE_MAPS_Api_KEY")})
    resp = response.json()

    print(resp["results"][0]["geometry"]["location"]["lat"], resp["results"][0]["geometry"]["location"]["lng"])
    sys.stdout.flush()