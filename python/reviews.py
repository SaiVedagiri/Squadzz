from transformers import pipeline
import os
from dotenv import load_dotenv

load_dotenv()
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


def qna(question, info_dict, model):
    context = ''
    for review in info_dict['reviews']:
        context += review['review'] + ' '

    other_info = ''
    info_fields = set(['delivery', 'dine in', 'reservable', 'serves breakfast', 'serves brunch', 'serves dinner', 'serves lunch', 'serves vegetarian food', 'takeout'])
    for field in info_fields:
        if field in info_dict:
            yes_no = "Yes"
            if info_dict[field] == 'False':
                yes_no = 'No'
            other_info += yes_no + ' ' + field + '. '


    context = '{}\n\n{}'.format(context, other_info)

    result = model(question=question, context=context)
    return result['answer']

if __name__ == '__main__':
    qna_model = pipeline("question-answering")
    place_ids = get_place_ids_from_latlon(40.741482, -74.1827, radius=1000, type='restaurant')
    name, info = get_info_from_id(place_ids[0])

    print(qna('How are the smoothies?', info, qna_model))
    print(qna('Do they serve vegetarian food?', info, qna_model))
    print(qna('Do they serve breakfast?', info, qna_model))