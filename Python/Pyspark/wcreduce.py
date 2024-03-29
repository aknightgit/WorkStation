#!/usr/bin/env python

from operator import itemgetter
import sys

current_word = None  
current_count = 0  #
word = None

for line in sys.stdin:
    words = line.strip()  #
    word, count = words.split('\t')  #

    try:
        count = int(count)  #
    except ValueError:
        continue

    if current_word == word:  #
        current_count += count  #
    else:
        if current_word:  # 
            print '%s\t%s' %(current_word, current_count)
        current_count = count  #
        current_word = word

if current_word == word:
    print '%s\t%s' %(current_word, current_count)
