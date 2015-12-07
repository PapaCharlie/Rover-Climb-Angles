from astropy.io import fits
from numpy import amin, nan, inf, full, array, arctan, isnan, degrees
import scipy.io as sio
# from graph_tool.all import *

ares3_file = "../data/DTEEC_041277_2115_040776_2115_A01.fits"
dtm = fits.open(ares3_file)[0].data
bad = amin(dtm)
mask = dtm == bad
dtm[mask] = nan
dtm = dtm[dtm.shape[0]*2/10:dtm.shape[0]*8/10, dtm.shape[1]*2/10:dtm.shape[1]*8/10]
max_angles = full(dtm.shape, inf)

fits = lambda pos: 0 <= pos[0] < dtm.shape[0] and 0 <= pos[1] < dtm.shape[1]

startpos = tuple(map(lambda x: x/2, dtm.shape))
max_angles[startpos] = 0

def spiralizer():
    count = 0
    current = (startpos[0], startpos[1] + 1)
    size = max(dtm.shape)**2
    perc = int(size/100)
    while count <= size:
        count += 1
        if count % perc == 0:
            print count/perc, '% done'
        if fits(current) and not isnan(dtm[current]):
            yield current
        if current[0] == startpos[0] - 1 and current[1] >= startpos[1]:
            current = (current[0] + 1, current[1] + 2)
        elif current[0] < startpos[0] and current[1] >= startpos[1]:
            current = (current[0] + 1, current[1] + 1)
        elif current[0] >= startpos[0] and current[1] > startpos[1]:
            current = (current[0] + 1, current[1] - 1)
        elif current[0] > startpos[0] and current[1] <= startpos[1]:
            current = (current[0] - 1, current[1] - 1)
        elif current[0] <= startpos[0] and current[1] < startpos[1]:
            current = (current[0] - 1, current[1] + 1)

def get_spiral_neighbors(pos):
    if pos[0] == startpos[0]:
        if pos[1] < startpos[1]:
            return [(pos[0], pos[1] + 1)]
        else:
            return [(pos[0], pos[1] - 1)]

    if pos[1] == startpos[1]:
        if pos[0] < startpos[0]:
            return [(pos[0] + 1, pos[1])]
        else:
            return [(pos[0] - 1, pos[1])]

    if pos[0] < startpos[0]:
        if pos[1] < startpos[1]:
            return [(pos[0] + 1, pos[1]), (pos[0], pos[1] + 1)]
        else:
            return [(pos[0] + 1, pos[1]), (pos[0], pos[1] - 1)]

    if pos[0] > startpos[0]:
        if pos[1] < startpos[1]:
            return [(pos[0] - 1, pos[1]), (pos[0], pos[1] + 1)]
        else:
            return [(pos[0] - 1, pos[1]), (pos[0], pos[1] - 1)]


def get_neighbors(pos):
    neighbors = get_spiral_neighbors(pos)
    if neighbors:
        return filter(lambda n: fits(n) and not isnan(max_angles[n]) and max_angles[n] != inf, neighbors)
        # return neighbors
        # if len(neighbors) == 0:
        #     return None
        # else:
        #     return min(neighbors, key = lambda n: max_angles[n])

def compute_angles():
    for pos in spiralizer():
        if fits(pos):
            neighbors = get_neighbors(pos)
            if len(neighbors) > 0:
                if len(neighbors) == 0:
                    best = neighbors[0]
                else:
                    best = min(neighbors, key = lambda n: max(abs(max_angles[n]), abs(dtm[pos] - dtm[n])))
                    # for n in neighbors[1:]:
                    #     if min(abs(dtm[pos] - dtm[n]), abs(max_angles[n])) < min(abs(dtm[pos] - dtm[best]), abs(max_angles[best])):
                    #         best = n
                if max_angles[best] <= 0:
                    max_angles[pos] = min(dtm[pos] - dtm[best], max_angles[best])
                else:
                    max_angles[pos] = max(dtm[pos] - dtm[best], max_angles[best])
                # max_angles[best] = min(dtm[pos] - dtm[best], max_angles[best]) # round(degrees(arctan()), 4)
    sio.savemat("../data/DTEEC_041277_2115_040776_2115_A01.mat", {'max_angles': max_angles})

compute_angles()
