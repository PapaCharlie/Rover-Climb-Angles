from astropy.io import fits
from numpy import amin, nan
from graph_tool.all import *

ares3_file = "../data/DTEEC_041277_2115_040776_2115_A01.fits"
dtm = fits.open(ares3_file)[0].data
bad = amin(dtm)
mask = dtm == bad
dtm[mask] = nan

startpos = tuple(map(lambda x: x/2, dtm.shape))
g = Graph()
g.add_vertex(dtm.size - dtm[mask].size)

