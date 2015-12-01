#!/usr/bin/python
from sys import argv
from subprocess import Popen
from argparse import ArgumentParser, FileType
from os import remove

# DEVNULL = open(os.devnull, 'wb')

def main(f):
    img = f.name
    cub = img[:-len('.IMG')] + '.cub'
    fits = img[:-len('.IMG')] + '.fits'
    pdslabel = img[:-len('.IMG')] + '.pdslabel'
    label = ''
    for line in f:
        label += line
        if line.strip() == 'END':
            break
    with open(pdslabel, 'w') as f:
        f.write(label)

    Popen(['pds2isis', 'from='+img, 'to='+cub]).communicate()
    Popen(['isis2fits', 'from='+cub, 'to='+fits]).communicate()
    remove(cub)


if __name__ == '__main__':
    parser = ArgumentParser(description='Transform an IMG HiRise DTM to a fits file without deleting the label file.')
    parser.add_argument('imgfile', metavar='IMG', type=FileType('r'), help='IMG containing DTM')
    args = parser.parse_args()
    if args.imgfile.name.lower().endswith('.img'):
        main(args.imgfile)
    else:
        raise parser.error('Argument was not an IMG file.')