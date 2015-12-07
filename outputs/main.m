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

pixels = zeros(size(datasets));

for n = 1:length(datasets)
  site = LandingSite(datasets{n});
  site.setup()
  pixels(n) = site.good_pixels;
  % Name & Pixels & Resolution & Area covered & Size in memory
  fprintf('%s & %.2e & %.6f & $\\SI{%.2f}{\\kilo\\meter\\squared}$ & %.3f MB\\\\\n',...
    datasets{n},...
    site.good_pixels,...
    site.res,...
    site.good_pixels/site.res * 1e-6,...
    site.good_pixels*8/(1024^3) ...
  )
end
% for n = 1:length(datasets)
%   disp(sprintf('Drawing %s', datasets{n}));
%   load_and_plot(datasets{n});
% end
