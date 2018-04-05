import re
import sys
import numpy as np
import pandas as pd



filepath = 'Posts.xml'

headera = "Id, OwnerUserId, CreationDate, LastActivityDate, Score, ParentId, CommentCount"

categories = ['python','java','r']

def main():

    initialize()
    open_files = []
    item_count = []
    questions = {}
    for item in categories:
        qout = open(item + '_answers.csv', 'a')
        open_files.append(qout)
        item_count.append(0)

        que = pd.read_csv(item + '_questions.csv',encoding = 'iso-8859-1')
        ids = np.array(que['Id'])
        questions[item] = ids


    with open(filepath, encoding='utf-8') as fp:
        line = fp.readline()
        cnt = 0
        cnttotal = 0
        while line:
            curr_file = open_files[0]
            item_index = -1
            curr_item = categories[0]

            for i,item in enumerate(categories):
                parent = int(extract('ParentId', line) or '0')
                if parent in questions[curr_item]:
                    curr_file = open_files[i]
                    item_index = i
                    break

            if item_index >= 0:
                # print(line)
                matchId = re.match(r'(.*)(\ Id\=)(.*)(PostTypeId\=)(.*)', line)
                try:
                    if matchId:
                        id = matchId.group(3)
                        id = int(id.replace('"', '') or '0')
                        type = int(matchId.group(5)[1])
                        if type == 1:
                            # Question
                            pass
                        else:
                            # Answer
                            parentid = int(extract('ParentId', line) or '0')
                            owner = int(extract('OwnerUserId', line) or '0')
                            score = int(extract('Score', line) or '0')
                            commentcount = int(extract('CommentCount', line) or '0')
                            creationdate = extract('CreationDate', line)
                            lastactivity = extract('LastActivityDate', line)

                            csvrow = str(id) + ", " + str(owner) + ', ' + str(creationdate) + ', ' + str(
                                lastactivity) + ', ' + str(score) + ', ' + str(parentid) + ', ' + str(
                                commentcount)
                            curr_file.write(csvrow + "\n")
                            item_count[item_index] = item_count[item_index] + 1
                            cnt = cnt + 1

                except:
                    print(sys.exc_info())

            cnttotal = cnttotal + 1

            if cnttotal % 1000 == 0:
                print('Total:', cnttotal, cnt," Category:", item_count)
            line = fp.readline()
        out = str(categories)+str(item_count)
        print(out)
        outfile = open('extract_answers_output','w')
        outfile.write(out)
        outfile.close()
        for item in open_files:
            item.close()



def initialize():
    for item in categories:
        qout = open(item+'_answers.csv', 'w')
        qout.write(headera + "\n")
        qout.close()

def extract(key, line):
    match = re.match(r'(.*)('+key+'=)(.*)', line)
    if match:
        ret = match.group(3)
        ret = ret.lstrip('"')
        ret = ret[:ret.find('"')]
        return ret
    else:
        return ""


if __name__ == "__main__":
    main()
