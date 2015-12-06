function load_and_plot(ds)
  % load(strcat('../data/', ds, '.mat'));
  fileID = fopen(strcat('../data/', ds, '.mat'));
  site = LandingSite(ds);
  data_size = [site.label.image.lines, site.label.image.linesamples];
  max_angles = fread(fileID, data_size, 'double');
  max_angles(max_angles == Inf) = NaN;
  max_angles = atand(max_angles);
  low = max(min(max_angles(:)), -20);
  high = min(max(max_angles(:)), 20);
  fig = figure;
  imagesc(max_angles, [ low high ]);
  colormap([ 0 0 0; jet ]);
  axis equal;
  h = colorbar;
  ylabel(h, 'Angle required to access');
  % export_fig(strcat('../outputs/', ds, '.png'));
  xlim([0 size(max_angles,2)]);
  saveas(fig, strcat('../outputs/', ds, '-angles.png'));

  fig = figure;
  histogram(max_angles, 50);
  xlim([-20 20]);
  xlabel 'Required angle';
  ylabel 'Num pixels';
  % set(fig,'yscale','log');
  saveas(fig, strcat('../outputs/', ds, '-hist.png'));
end
