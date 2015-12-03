function load_and_plot(ds)
  load(strcat('../data/', ds, '.mat'));
  max_angles(max_angles == Inf) = NaN;
  max_angles = atand(max_angles);
  low = max(min(max_angles(:)), -20);
  high = min(max(max_angles(:), 20), 20);
  figure
  imagesc(max_angles, [ low high ]);
  colormap([ 0 0 0; jet ]);
  axis equal;
  colorbar;
  export_fig(strcat('../outputs/', ds, '.pdf'));
end
