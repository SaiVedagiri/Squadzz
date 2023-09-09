from transformers import pipeline
import requests
import os
from dotenv import load_dotenv

load_dotenv()
def get_place_ids_from_latlon(lat, lon, radius='', type='', kwd=''):
    params = {
        'location' : '{},{}'.format(lat, lon),
        'key' : os.getenv('PENNAPPS_GOOGLE_API_KEY')
    }
    if radius != '':
        params['radius'] = radius
    if type != '':
        params['type'] = type
    if kwd != '':
        params['keyword'] = kwd

    results = requests.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', params=params).json()
    ids = [place['place_id'] for place in results['results']]
    return ids


def get_reviews_from_id(id):
    ret_fields = ['name', 'reviews']
    params = {
        'place_id' : id,
        'key' : os.getenv('PENNAPPS_GOOGLE_API_KEY'),
        'fields' : ','.join(ret_fields),
        'reviews_sort' : 'most_relevant'
    }

    results = requests.get('https://maps.googleapis.com/maps/api/place/details/json', params=params).json()

    name = results['result']['name']
    reviews = {name : []}
    for rev in results['result']['reviews']:
        rating_review = {}
        rating_review['rating'] = rev['rating']
        rating_review['review'] = rev['text']
        reviews[name].append(rating_review)

    return reviews



# qa_model = pipeline("question-answering")
# question = "How is this restaurant's yogurt?"
# context = "What a great place, you know you're in the right restaurant when they are non stop busy. We had a big group, got our salads/stir fry pretty fast. Be prepared to wait a bit as they seem to do a lot of take out/door dash orders. One of us had stir fry which came out very fast (super yummy) but the salads, which are made at the other end of the bar (this was confusing as to when our order was ready) but everything was very fresh. Love the touch screen ordering! Yikes, smallest portion $9 yogurt treat!! Don't get me wrong ... I love honeygrow and go often. Spent $70 for lunch and this is what I got. Was planning on sharing it ... ha.  Lil' disappointed. KOP location gives generously. This team really makes my day. I’m a regular here and sometimes when I come it isn’t just about the food … they smile, wave, if they aren’t super busy they’ll ask how I am. I love that. The service here is top tier. Place gets packed at lunch. Definitely download the app and pre-order during their lunch rush."
# result = qa_model(question = question, context = context)
# print(result['answer'])

if __name__ == '__main__':
    place_ids = get_place_ids_from_latlon(40.741482,-74.1827, radius=1000, type='restaurant')
    reviews = get_reviews_from_id(place_ids[0])
    print(reviews)