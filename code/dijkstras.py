
# coding: utf-8

# In[27]:

from astropy.io import fits as fitsreader
from numpy import amin, amax, nanmax, nanmin, nan, inf,     array, arctan, isnan, degrees, histogram, save, load, empty_like, full, isfinite
from scipy.io import savemat, loadmat
from heapq import heappush as push, heappop as pop
import matplotlib.pyplot as plt


# In[31]:

datasets = [
  'DTEEC_011417_1755_011562_1755_U01',
  'DTEEC_011844_1855_002812_1855_A01',
  'DTEEC_015985_2040_016262_2040_U01',
  'DTEEC_018854_1755_018920_1755_U01',
  'DTEEC_019045_1530_019322_1530_U01',
  'DTEEC_019612_1535_019678_1535_U01',
  'DTEEC_019757_1560_020034_1560_U01',
  'DTEEC_019823_1530_019889_1530_U01',
  'DTEEC_020324_1555_020390_1555_U01',
  'DTEEC_023957_1755_024023_1755_U01',
  'DTEEC_024234_1755_024300_1755_U01',
  'DTEEC_028011_2055_028288_2055_A01',
  'DTEEC_041277_2115_040776_2115_A01'
]

class Frontier:
    def __init__(self):
        self.heap = []
        self.keys = set()
    
    def push(self, (v,k)):
        if k not in self.keys:
            push(self.heap, (v,k))
            self.keys.add(k)
    
    def pop(self):
        if self.heap:
            (v,k) = pop(self.heap)
            self.keys.remove(k)
            return (v,k)

def load_data(d, cut = True):
    global dtm
    global max_angles
    global res
    global dataset
    if type(d) == type(1):
        dataset = datasets[d]
    else:
        dataset = d
    dtm = fitsreader.open('../data/' + dataset + '.fits')[0].data
    if cut:
#         dtm = dtm[dtm.shape[0]*1/4:dtm.shape[0]*3/4, dtm.shape[1]*1/4:dtm.shape[1]*3/4]
        dtm = dtm[dtm.shape[0]*4/100:dtm.shape[0]*6/100, dtm.shape[1]*48/100:dtm.shape[1]*49/100]
    for line in open('../data/' + dataset + '.pdslabel'):
        if 'MAP_SCALE' in line and '<METERS/PIXEL>' in line:
            res = float(line.split('=')[1].split('<')[0].strip())
    bad = amin(dtm)
    mask = dtm == bad
    dtm[mask] = nan
    dtm -= nanmin(dtm)
    max_angles = empty_like(dtm)
    max_angles.fill(inf)


# In[32]:

def isvalid(pos):
    global dtm
    return 0 <= pos[0] < dtm.shape[0] and 0 <= pos[1] < dtm.shape[1] and not isnan(dtm[pos])

def dijkstra(startpos):
    global dtm
    global max_angles
    global res
    neighbors = [(1,0),(0,1),(-1,0),(0,-1)]
    max_angles[startpos] = 0
    fr = Frontier()
    fr.push((0, startpos))
    while fr.heap:
        (height_diff, (px,py)) = fr.pop()
        for n in map(lambda (x,y): (px + x, py + y), neighbors):
            if isvalid(n):
                alt = max([height_diff, dtm[n] - dtm[px,py]], key = abs)
                if abs(alt) < abs(max_angles[n]):
                    max_angles[n] = alt
#                     print n
                    fr.push((alt, n))

def compute_angles():
    global dtm
    global max_angles
    global res
    global dataset
    startpos = tuple(map(lambda x: x/2, dtm.shape))
    dijkstra(startpos)
    arctan(degrees(max_angles))
    savemat('../data/' + dataset + '.mat', {'max_angles': max_angles})


# In[33]:

load_data(datasets[-1], False)
compute_angles()


# In[34]:

# fig = plt.figure(figsize=(6, 12))
# max_angles[max_angles == inf] = nan
# plt.imshow(max_angles)
# plt.imshow(degrees(arctan(max_angles)))
# plt.colorbar()


# In[ ]:



