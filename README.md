# Overflow
## Analysis of Stackoverflow questions as a network
This is the dataset we're analysing [here](https://www.kaggle.com/stackoverflow/pythonquestions/data)
 
Setting up:
- Clone this repository
```
git clone https://github.com/live-wire/overflow.git
cd overflow/
```
- Download dataset from [here](https://www.kaggle.com/stackoverflow/pythonquestions/downloads/pythonquestions.zip/1)
- Unzip it
- Play with the Jupyter Notebook :pizza:


### Real(BIG AF) Dataset

[Link](https://archive.org/download/stackexchange) to all dumps from stackexchange.

[Link](stackoverflow.com-Posts.7z) to the stackoverflow `Posts.xml` dump.

[Link](https://meta.stackexchange.com/questions/2677/database-schema-documentation-for-the-public-data-dump-and-sede) to the schema of the available dumps. 

Extract Posts.xml in this folder.
```
python extract_questions.py
python extract_answers.py
```
This will extract the questions and then the answers to the extracted questions for the tags `Python`, `Java` and `R` in _csv_ formats. :beer: