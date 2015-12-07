function [max_angles] = load_and_plot(ds)
  fileID = fopen(strcat('../outputs/', ds, '.bin'));
  site = LandingSite(ds);
  data_size = [site.label.image.lines, site.label.image.linesamples];
  max_angles = fread(fileID, data_size, 'double', 0, 'b');

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
  xlim([0 size(max_angles,2)]);
  saveas(fig, strcat('../figures/traversal_maps/', ds, '-angles.pdf'));

  fig = figure;
  histogram(max_angles, 50);
  xlabel 'Required angle';
  ylabel 'Num pixels';
  saveas(fig, strcat('../figures/histograms/', ds, '-hist.pdf'));
end
