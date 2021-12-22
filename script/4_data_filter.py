import re
import csv
import langid
from nltk.tokenize import RegexpTokenizer, word_tokenize
import logging
import traceback
logging.basicConfig(level=logging.INFO, format='%(asctime)s :: %(funcName)s - %(levelname)s :: %(message)s')


INPUT_FILE = 'data_clean.csv'
OUT_FILE = 'filtered_data.csv'

matches = ["todo", "copyright", "license"]

def detect_lang(comment):
    lang = None
    try:
        # classify method return lang and accuracy, with 0 index take only language of string
        lang = langid.classify(comment)[0]
    except:
        # can not detect language
        logging.warn(traceback.format_exc())

    return lang


def main():
    with open(INPUT_FILE, 'r', errors='ignore') as read_obj, open(OUT_FILE, 'w') as write_obj:
        lines = csv.DictReader(read_obj, delimiter=',')
        fieldnames = ['dockerfile_sha1', 'instruction', 'comment', 'instruction_number', 'comment_number', 'instruction_line', 'comment_line', 'instruction_type', 'comment_clean']
        writer = csv.DictWriter(write_obj, fieldnames=fieldnames, lineterminator='\n')
        writer.writeheader()

        try:
            for row in lines:
                logging.info('processing row: ' + row['dockerfile_sha1'])
                comment = row['comment_clean'].lower()
                words = word_tokenize(comment)
                if (detect_lang(comment) == 'en' and len(words) >= 2 and comment[0].isalpha()):

                    url = re.findall(r'(https?://[^\s]+)', comment)

                    if not url:
                        if not any(x in comment for x in matches):
                            tokenizer = RegexpTokenizer(r"\w+")
                            lst = tokenizer.tokenize(comment)
                            cleaned_comment = ' '.join(lst)

                            percentage = len(cleaned_comment) * 100/len(comment)

                            if (percentage >= 93):
                                writer.writerow(row) 
                url = []
        except:
            logging.error(traceback.format_exc())

    print("+++ Operation completed successfully +++")


if __name__ == '__main__':
    main()
