import re
import sys


filepath = 'Posts.xml'

headerq = "Id, OwnerUserId, CreationDate, LastActivityDate, Score, AcceptedAnswerId, AnswerCount, CommentCount, ViewCount, FavoriteCount"

categories = ['python','java','r']


def main():

    initialize()
    open_files = []
    item_count = []
    for item in categories:
        qout = open(item + '_questions.csv', 'a')
        open_files.append(qout)
        item_count.append(0)


    with open(filepath, encoding='utf-8') as fp:
        line = fp.readline()
        cnt = 1
        cnttotal = 1
        while line:
            curr_file = open_files[0]
            item_index = 0
            matchItem = None
            for i,item in enumerate(categories):
                matchItem = re.match(r'(.*)(\&lt\;'+item+'\&gt\;)(.*)', line)
                if matchItem:
                    curr_file = open_files[i]
                    item_index = i
                    break

            if matchItem:
                # print(line)
                matchId = re.match(r'(.*)(\ Id\=)(.*)(PostTypeId\=)(.*)', line)
                try:
                    if matchId:
                        id = matchId.group(3)
                        id = int(id.replace('"', '') or '0')
                        type = int(matchId.group(5)[1])

                        owner = int(extract('OwnerUserId', line) or '0')
                        score = int(extract('Score', line) or '0')
                        commentcount = int(extract('CommentCount', line) or '0')

                        creationdate = extract('CreationDate', line)
                        lastactivity = extract('LastActivityDate', line)

                        if type == 1:
                            # Question
                            viewcount = int(extract('ViewCount', line) or '0')
                            favouritecount = int(extract('FavoriteCount', line) or '0')
                            answercount = int(extract('AnswerCount', line) or '0')
                            acceptedanswer = int(extract('AcceptedAnswerId', line) or '0')

                            csvrow = str(id) + ", " + str(owner) + ', ' + str(creationdate) + ', ' + str(
                                lastactivity) + ', ' + str(score) + ', ' + str(acceptedanswer) + ', ' + str(
                                answercount) + ', ' + str(commentcount) + ', ' + str(viewcount) + ', ' + str(favouritecount)
                            curr_file.write(csvrow + "\n")
                            item_count[item_index] = item_count[item_index] + 1

                except:
                    print(sys.exc_info())

            cnttotal = cnttotal + 1

            if cnttotal % 1000 == 0:
                print('Total:', cnttotal, cnt," Category:", item_count)
            line = fp.readline()
        print(categories,item_count)
        for item in open_files:
            item.close()

def initialize():
    for item in categories:
        qout = open(item+'_questions.csv', 'w')
        qout.write(headerq + "\n")
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
