function [max_angles] = load_and_plot(ds)
  % Assuming ds argument is of the type DTEEC_xxxxxx_xxxx_yyyyyy_yyyy_yyy
  % Then ESP name will ESP_xxxxxx_xxxx
  esp = strsplit(ds, '_');
  esp = strcat('ESP_', esp(2), '_', esp(3))
  p = strcat('../figures/maps/', esp, '/')
  mkdir(p);
  ds = strrep(strrep(ds, '.fits',''), 'data/', '')
  site = LandingSite(ds);
  data_size = [site.label.image.lines, site.label.image.linesamples];
  fileID = fopen(strcat(ds, '.bin'));
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
  % disp(strcat('../figures/maps/', esp, '/', ds, '-traversability_map.pdf'));
  saveas(fig, strcat('../figures/maps/', esp, '/', ds, '-traversability_map.pdf'));

  fig = figure;
  histogram(max_angles, 50);
  xlabel 'Required angle';
  ylabel 'Num pixels';
  saveas(fig, strcat('../figures/maps/', esp, '/', ds, '-hist.pdf'));
  return
end
