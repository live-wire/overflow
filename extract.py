import re
import sys

headerq = "Id, OwnerUserId, CreationDate, LastActivityDate, Score, AcceptedAnswerId, AnswerCount, CommentCount, ViewCount, FavoriteCount"
headera = "Id, OwnerUserId, CreationDate, LastActivityDate, Score, ParentId, CommentCount"
qout = open('questions.csv','a')
qout.write(headerq+"\n")
aout = open('answers.csv','a')
aout.write(headera+"\n")

filepath = 'Posts.xml'


def extract(key, line):
    match = re.match(r'(.*)('+key+'=)(.*)', line)
    if match:
        ret = match.group(3)
        ret = ret.lstrip('"')
        ret = ret[:ret.find('"')]
        return ret
    else:
        return ""



with open(filepath, encoding='utf-8') as fp:
    line = fp.readline()
    cnt = 1
    cnttotal = 1
    while line:
        matchPython = re.match(r'(.*)(\&lt\;python\&gt\;)(.*)',line)
        matchPythonString = re.match(r'(.*)(python)(.*)',line)
        if matchPythonString:

            # print(line)
            matchId = re.match(r'(.*)(\ Id\=)(.*)(PostTypeId\=)(.*)',line)
            try:
                if matchId:
                    id = matchId.group(3)
                    id = int(id.replace('"','') or '0')
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

                        csvrow = str(id)+", "+str(owner)+', '+str(creationdate)+', '+str(lastactivity)+', '+str(score)+', '+str(acceptedanswer)+', '+str(answercount)+', '+str(commentcount)+', '+str(viewcount)
                        qout.write(csvrow+"\n")
                    else:
                        # Answer
                        parentid = int(extract('ParentId', line) or '0')

                        csvrow = str(id) + ", " + str(owner) + ', ' + str(creationdate) + ', ' + str(lastactivity) + ', ' + str(score) + ', ' + str(parentid) + ', ' + str(commentcount)
                        aout.write(csvrow + "\n")

            except:
                print(sys.exc_info())
            cnt = cnt + 1
        cnttotal = cnttotal + 1

        if cnttotal%100 == 0:
            print('Total Lines:',cnttotal,'  Python:',cnt)
        line = fp.readline()
    print(cnt)


qout.close()
aout.close()
