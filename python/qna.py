from transformers import pipeline
import argparse
import os
import json
from dotenv import load_dotenv

parser = argparse.ArgumentParser()
parser.add_argument('question', help='the question to ask the chat model')
parser.add_argument('json_path', help='filepath to the json containing information about a place')

# usage: qna.py [-h] question json_path

# positional arguments:
#   question    the question to ask the chat model
#   json_path   filepath to the json containing information about a place

# options:
#   -h, --help  show this help message and exit


def qna(question, info_dict_path, model):
    info_dict = None
    with open(info_dict_path, 'r') as file:
        info_dict = json.load(file)

    context = ''
    if 'reviews' in info_dict:
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

# code to run
load_dotenv()
args = parser.parse_args()

model = pipeline("question-answering")
answer = qna(args.question, args.json_path, model)
print(answer.strip())