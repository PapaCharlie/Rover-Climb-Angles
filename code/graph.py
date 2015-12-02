from astropy.io import fits
from numpy import amin, nan, inf, full, array, arctan, isnan, degrees
import scipy.io as sio
from frontier import spiral
# from graph_tool.all import *

ares3_file = "../data/DTEEC_041277_2115_040776_2115_A01.fits"
dtm = fits.open(ares3_file)[0].data
bad = amin(dtm)
mask = dtm == bad
dtm[mask] = nan
max_angles = full(dtm.shape, inf)

fits = lambda pos: 0 <= pos[0] <= dtm.shape[0] and 0 < pos[1] < dtm.shape[1]

startpos = tuple(map(lambda x: x/2, dtm.shape))
max_angles[startpos] = 0
# g = Graph()
# g.add_vertex(dtm.size - dtm[mask].size)
# angles = g.new_edge_property("double")

def spiralizer():
    count = 0
    current = (startpos[0], startpos[1] + 1)
    size = max(dtm.shape)**2
    perc = int(size/100)
    while count <= size:
        count += 1
        if count % perc == 0:
            print count/perc, '% done'
        if dtm[current] != nan:
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


def get_best_neighbor(pos):
    neighbors = get_spiral_neighbors(pos)
    if neighbors
        neighbors = filter(lambda n: fits(n) and not isnan(max_angles[n]) and max_angles[n] != inf, neighbors)
        if len(neighbors) == 0:
            return None
        else:
            return min(neighbors, key = lambda n: max_angles[n])

def compute_angles():
    count = 0
    for pos in spiralizer():
        if fits(pos):
            best = get_best_neighbor(pos)
            if best:
                max_angles[pos] = arctan(dtm[pos] - dtm[best]) # round(degrees(), 4)
        # if count % round(dtm.size/100) == 0:
        #     print count/int(dtm.size/100), '% done'
        count += 1
    sio.savemat("../data/DTEEC_041277_2115_040776_2115_A01.mat", {'max_angles': max_angles})

compute_angles()
