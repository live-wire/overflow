import re
import sys
import numpy as np
import pandas as pd



filepath = 'Users.xml'

headera = "Id,Reputation,CreationDate,LastAccessDate,Views,UpVotes,DownVotes,Age,DisplayName"

categories = ['python','java','r']

single_outfile = "users.csv"


def main():

    initialize()
    open_files = []
    item_count = []
    acceptable_users = np.array([])
    for item in categories:
        que = pd.read_csv(item + '_questions.csv', encoding='iso-8859-1', error_bad_lines=False)
        ids = np.array(que[' OwnerUserId'])
        acceptable_users = np.concatenate((acceptable_users, ids), axis=0)

        que = pd.read_csv(item + '_answers.csv', encoding='iso-8859-1', error_bad_lines=False)
        ids = np.array(que[' OwnerUserId'])
        acceptable_users = np.concatenate((acceptable_users, ids), axis=0)
        acceptable_users = np.unique(acceptable_users)

    print(acceptable_users.shape)
    curr_file = open(single_outfile, 'a')

    with open(filepath, encoding='utf-8') as fp:
        line = fp.readline()
        cnt = 0
        cnttotal = 0
        while line:
            matchId = re.match(r'(.*)(\ Id\=)(.*)(Reputation\=)(.*)', line)
            try:
                if matchId:
                    id = matchId.group(3)
                    id = int(id.replace('"', '') or '0')

                    if id!=0 and id in acceptable_users:
                        #CreationDate, LastAccessDate, Views, UpVotes, DownVotes, Age
                        reputation = int(extract('Reputation', line) or 0)
                        creationdate = extract('CreationDate', line)
                        lastaccessdate = extract('LastAccessDate', line)
                        views = int(extract('Views', line) or 0)
                        upvotes = int(extract('UpVotes', line) or 0)
                        downvotes = int(extract('DownVotes', line) or 0)
                        age = int(extract('Age', line) or 0)
                        displayname = extract('DisplayName',line)

                        csvrow = str(id) + ',' + str(reputation) + ',' + str(creationdate) + ',' + str(
                            lastaccessdate) + ',' + str(views) + ',' + str(upvotes) + ',' + str(
                            downvotes)+ ',' + str(age)+','+str(displayname)

                        curr_file.write(csvrow + "\n")
                        cnt = cnt + 1

            except:
                print(sys.exc_info())

            cnttotal = cnttotal + 1

            if cnttotal % 1000 == 0:
                print('Done:',str(float(cnttotal)/8523670)+"%",' Total:', cnttotal, " Users:", cnt)
            line = fp.readline()
        print(cnt)
    curr_file.close()



def initialize():
    qout = open(single_outfile, 'w')
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
