import os
import requests
import math
from dotenv import load_dotenv

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

    addresses = ["5 N Front St, Allentown, PA 18102", "364 Palisade Avenue, Cliffside Park, NJ", "3330 Walnut Street, Philadelphia, PA", "54 Parry Drive, Hainesport, NJ", "3201 Cricket Circle, Edison, NJ"]
    coords = [getCoords(ad) for ad in addresses]

    n = len(addresses)

    midpointCoord, midpoint = findMidpoint(addresses, coords)

    print(midpointCoord)
    print()

    # print([getDistance(midpointCoord, getCoords(ad)) for ad in addresses])

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

        print(prettyTimes)
        print(distances)
        print(end='\n\n\n\n')

    print(minTime)
    print(totalTimes)