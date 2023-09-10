import cv2
import os
import face_recognition
import faiss
import argparse
import numpy as np
from urllib.request import urlretrieve
from google.cloud import vision

parser = argparse.ArgumentParser()
parser.add_argument('-image_path', nargs='+')
parser.add_argument('-trip_id', nargs='+')

args = parser.parse_args()

def find_face_encodings(image_path):
    # reading image
    image = cv2.imread(image_path)    # get face encodings from the image
    face_enc = face_recognition.face_encodings(image)    # return face encodings
    return face_enc


def detect_faces(path):
    """Detects faces in an image."""
    client = vision.ImageAnnotatorClient()

    with open(path, "rb") as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations
    
    vertices = []

    for face in faces:
        vertices.append([(int(vertex.x), int(vertex.y)) for vertex in face.bounding_poly.vertices])

    return vertices


urlretrieve(args.image_path[0], "upload." + args.image_path[0][-3:])

imagePath = "upload." + args.image_path[0][-3:]
image = cv2.imread(imagePath)

names = ["rushi", "sai", "shri", "vignesh"]

#get list of all faces in uploaded image
faces = detect_faces(imagePath)

index = faiss.read_index("face.index")

# print(len(faces))

predictionNames = []

for i in range(len(faces)):
    face = faces[i]

    #crop individual face from image
    crop_img = image[face[0][1]:face[2][1], face[0][0]:face[1][0]]

    cv2.imwrite("temp.png", crop_img)

    new_face_embedding = np.array([find_face_encodings("temp.png")])

    if len(new_face_embedding[0]) < 1:
        predictionNames.append("unknown")
        continue

    D, I = index.search(new_face_embedding[0], 1)

    if D[0][0] > 0.25:
        predictionNames.append("unknown")
        continue

    predictionNames.append(names[I[0][0]])

import firebase_admin
from firebase_admin import db

trip_id = args.trip_id[0]

cred_obj = firebase_admin.credentials.Certificate('firebase.json')
default_app = firebase_admin.initialize_app(cred_obj, {
    'databaseURL':'https://squadzz-default-rtdb.firebaseio.com/'
})

ref = db.reference("/trips/" + trip_id + "/photos")

# print(ref.get())

ref.push({"url": args.image_path[0], "people": predictionNames})

# ref.set([{"url": args.image_path[0], "people": predictionNames}])

# print(ref.get())