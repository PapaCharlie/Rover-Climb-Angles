addpath('../data');
close all

ares3 = LandingSite('DTEEC_041277_2115_040776_2115_A01');
figure
imagesc(ares3.dtm, [ ares3.low, ares3.high ]);
colormap([ 0 0 0; jet ]);
% clear all
% mawrth_vallis = LandingSite('DTEEC_028011_2055_028288_2055_A01')
