import os
import requests
import math
from dotenv import load_dotenv
from global_land_mask import globe
import numpy as np

load_dotenv()
KANSAS="Lebanon, Kansas"
R = 6378.137 # radius in km

def getCoords(address: str) -> tuple:

    response = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params={"address": address, "key": os.getenv("GOOGLE_MAPS_Api_KEY")})
    resp = response.json()
    return(resp["results"][0]["geometry"]["location"]["lat"], resp["results"][0]["geometry"]["location"]["lng"])


def getAddress(coord: tuple) -> str:

    response = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params={"latlng": str(coord[0]) + ", " + str(coord[1]), "key": os.getenv("GOOGLE_MAPS_Api_KEY")})
    resp = response.json()

    return(resp["results"][0]["formatted_address"])


def getDistanceMatrix(origins: list[str], destinations: list[str]) -> dict:

    response = requests.get("https://maps.googleapis.com/maps/api/distancematrix/json", params={"origins": '|'.join(origins), "destinations": '|'.join(destinations), "key": os.getenv("GOOGLE_MAPS_Api_KEY")})
    resp = response.json()

    return resp

def coorInOcean(coord: tuple) -> bool:

    is_on_land = globe.is_land(coord[0], coord[1])
    return not is_on_land


def getDistance(point1: tuple, point2: tuple) -> float:

    lat1, lng1, lat2, lng2 = point1[0], point1[1], point2[0], point2[1]

    dLat = lat2 * math.pi / 180 - lat1 * math.pi / 180
    dLon = lng2 * math.pi / 180 - lng1 * math.pi / 180
    a = math.sin(dLat/2) * math.sin(dLat/2) + math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.sin(dLon/2) * math.sin(dLon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    d = R * c
    return d * 1000; # meters


def findMidpoint(addresses: list[str], coords: list[tuple]) -> str:

    lat = [coord[0] for coord in coords]
    lng = [coord[1] for coord in coords]

    midpoint = (sum(lat)/len(lat), sum(lng)/len(lng))

    return midpoint, getAddress(midpoint)

if __name__ == "__main__":

    # addresses = ['21 W Clarke Ave, Milford, DE 19963', '140 Main St, Cedarville, NJ 08311']
    addresses = ['7301-7399 NW 14th Ave, Miami, FL 33147', 'Center St, Bangor, ME']
    coords = [getCoords(ad) for ad in addresses]

    n = len(addresses)

    midpointCoord, midpoint = findMidpoint(addresses, coords)
    kansasCoord = (39.809995, -98.555394)

    print(midpointCoord)
    print()

    # print([getDistance(midpointCoord, getCoords(ad)) for ad in addresses])

    if (not coorInOcean(midpointCoord)):
        matrix = getDistanceMatrix([midpoint], addresses)

        print(matrix)
        print()

        times = [matrix["rows"][0]["elements"][i]["duration"]["value"] for i in range(n)]
        prettyTimes = [matrix["rows"][0]["elements"][i]["duration"]["text"] for i in range(n)]
        distances = [matrix["rows"][0]["elements"][i]["distance"]["value"] for i in range(n)]

        print(prettyTimes)
        print(distances)
        print()

        minTime = 10000000000
        totalTimes = []

        for i in range(10):
            longestTime = times.index(max(times))
            longestPlace, longestDistance, longestCoord = addresses[longestTime], distances[longestTime], coords[longestTime]
            
            print(longestTime, longestPlace, longestDistance)
            print()

            new_latitude = midpointCoord[0] + (longestCoord[0]-midpointCoord[0])/25
            new_longitude = midpointCoord[1] + (longestCoord[1]-midpointCoord[1])/25

            # new_latitude = midpointCoord[0] + ((longestDistance/50000) / R) * (180 / math.pi)
            # new_longitude = midpointCoord[1] + ((longestDistance/50000) / R) * (180 / math.pi) / math.cos(midpointCoord[0] * math.pi/180)

            print(new_latitude, new_longitude)
            print()

            midpointCoord, midpoint = (new_latitude, new_longitude), getAddress((new_latitude, new_longitude))

            matrix = getDistanceMatrix([midpoint], addresses)

            print(matrix)
            print()

            times = [matrix["rows"][0]["elements"][i]["duration"]["value"] for i in range(n)]
            prettyTimes = [matrix["rows"][0]["elements"][i]["duration"]["text"] for i in range(n)]
            distances = [matrix["rows"][0]["elements"][i]["distance"]["value"] for i in range(n)]

            sumTime = sum(times)/60
            totalTimes.append(sumTime)
            if sumTime < minTime:
                minTime = sumTime
                bestLoc = midpoint
                bestDistances = distances
                bestPrettyTimes = prettyTimes

            print(prettyTimes)
            print(distances)
            print(end='\n\n\n\n')

        print(minTime)
        print(totalTimes)
    elif (n > 2):
        # reverse kansas
        new_latitude = midpointCoord[0] + (kansasCoord[0]-midpointCoord[0])/25
        new_longitude = midpointCoord[1] + (kansasCoord[1]-midpointCoord[1])/25

        while (coorInOcean((new_latitude, new_longitude))):
            new_latitude += (kansasCoord[0]-midpointCoord[0])/25
            new_longitude += (kansasCoord[1]-midpointCoord[1])/25
            
        
        minTime = 10000000000
        totalTimes = []

        for i in range(10):
            midpointCoord, midpoint = (new_latitude, new_longitude), getAddress((new_latitude, new_longitude))

            matrix = getDistanceMatrix([midpoint], addresses)

            print(matrix)
            print()

            times = [matrix["rows"][0]["elements"][i]["duration"]["value"] for i in range(n)]
            prettyTimes = [matrix["rows"][0]["elements"][i]["duration"]["text"] for i in range(n)]
            distances = [matrix["rows"][0]["elements"][i]["distance"]["value"] for i in range(n)]

            longestTime = times.index(max(times))
            longestPlace, longestDistance, longestCoord = addresses[longestTime], distances[longestTime], coords[longestTime]
            
            print(longestTime, longestPlace, longestDistance)
            print()

            new_latitude = new_latitude + (longestCoord[0]-new_latitude)/25
            new_longitude = new_longitude + (longestCoord[1]-new_longitude)/25

            print(new_latitude, new_longitude)
            print()

            sumTime = sum(times)/60
            totalTimes.append(sumTime)
            if sumTime < minTime:
                minTime = sumTime
                bestLoc = midpoint
                bestDistances = distances
                bestPrettyTimes = prettyTimes

            print(prettyTimes)
            print(distances)
            print(end='\n\n\n\n')

        print(minTime)
        print(totalTimes)
    else:
        # perpendicular

        minTime = 10000000000
        totalTimes = []

        diff = (coords[0][0] - coords[1][0], coords[0][1] - coords[1][1])
        perp_vector = (-diff[1], diff[0])
        print(perp_vector)
        print()
        kansas_vector = (kansasCoord[0]-midpointCoord[0],kansasCoord[1]-midpointCoord[1])
        dot_prod = (perp_vector[0] * kansas_vector[0]) + (perp_vector[1] * kansas_vector[1])
        print(dot_prod)

        if (dot_prod < 0):
            perp_vector = (-perp_vector[0], -perp_vector[1])
        mag = (perp_vector[0] ** 2 + perp_vector[1] ** 2) ** 0.5
        perp_vector = (perp_vector[0] / mag, perp_vector[1] / mag)
        print(perp_vector)

        print("HERE")
        print(perp_vector[0] * diff[0] + perp_vector[1] * diff[1])
        
        new_latitude = midpointCoord[0] + (perp_vector[0])/25
        new_longitude = midpointCoord[1] + (perp_vector[1])/25

        while (coorInOcean((new_latitude, new_longitude))):
            new_latitude += (perp_vector[0])/25
            new_longitude += (perp_vector[1])/25

        for i in range(10):
            midpointCoord, midpoint = (new_latitude, new_longitude), getAddress((new_latitude, new_longitude))

            matrix = getDistanceMatrix([midpoint], addresses)

            print(matrix)
            print()

            times = [matrix["rows"][0]["elements"][i]["duration"]["value"] for i in range(n)]
            prettyTimes = [matrix["rows"][0]["elements"][i]["duration"]["text"] for i in range(n)]
            distances = [matrix["rows"][0]["elements"][i]["distance"]["value"] for i in range(n)]
            
            longestTime = times.index(max(times))
            longestPlace, longestDistance, longestCoord = addresses[longestTime], distances[longestTime], coords[longestTime]
            
            print(longestTime, longestPlace, longestDistance)
            print()

            new_latitude = new_latitude + (perp_vector[0])/20
            new_longitude = new_longitude + (perp_vector[1])/20

            print(new_latitude, new_longitude)
            print()

            sumTime = sum(times)/60
            totalTimes.append(sumTime)
            if sumTime < minTime:
                minTime = sumTime
                bestLoc = midpoint
                bestDistances = distances
                bestPrettyTimes = prettyTimes


            print(prettyTimes)
            print(distances)
            print(end='\n\n\n\n')

    print("FINAL SOLUTION")
    print(minTime)
    print(bestLoc)
    print(bestDistances)
    print(bestPrettyTimes)
    # print(totalTimes)
