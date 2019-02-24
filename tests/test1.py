import sys
import os

def main():
    f = open('./test.txt','w')
    f.write('It works!')
    f.flush()
    f.close()
    print('It works!')

if __name__ == '__main__':
    main()
