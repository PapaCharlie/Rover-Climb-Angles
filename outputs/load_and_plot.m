function load_and_plot(ds)
  % Assuming ds argument is of the type DTEEC_xxxxxx_xxxx_yyyyyy_yyyy_yyy
  % Then ESP name will ESP_xxxxxx_xxxx
  esp = strsplit(ds, '_');
  esp = strcat('ESP_', esp(2), '_', esp(3))
  mkdir('../figures/maps/', char(esp));
  ds = strrep(strrep(ds, '.fits',''), 'data/', '')
  site = LandingSite(ds);
  data_size = [site.label.image.lines, site.label.image.linesamples];
  fileID = fopen(strcat(ds, '.bin'));
  required = fread(fileID, data_size, 'double', 0, 'b');

  required(required == Inf) = NaN;
  required = required./site.res;
  required = atand(required);
  low = max(min(required(:)), -20);
  high = min(max(required(:)), 20);
  fig = figure;
  imagesc(required, [ low high ]);
  colormap([ 0 0 0; jet ]);
  axis equal;
  h = colorbar;
  ylabel(h, 'Angle required to access');
  xlim([0 size(required,2)]);
  set(gca,'xtick',[]);
  set(gca,'xticklabel',[]);
  set(gca,'ytick',[]);
  set(gca,'yticklabel',[]);
  saveas(fig, char(strcat('../figures/maps/', char(esp), '/', char(ds), '-traversability_map.pdf')));

  fig = figure;
  histogram(required, 50);
  xlabel 'Required angle';
  ylabel 'Num pixels';
  xlim([-40 40]);
  saveas(fig, char(strcat('../figures/maps/', char(esp), '/', char(ds), '-hist.pdf')));
end
