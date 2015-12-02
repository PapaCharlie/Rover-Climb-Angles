addpath('../data');
close all

global frontier;
frontier = py.importlib.import_module('frontier');

datasets = {
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
};

ares3 = LandingSite(datasets{end});
% figure
% imagesc(ares3.dtm, [ ares3.low, ares3.high ]);
% colormap([ 0 0 0; jet ]);
% clear all
% mawrth_vallis = LandingSite('DTEEC_028011_2055_028288_2055_A01')
