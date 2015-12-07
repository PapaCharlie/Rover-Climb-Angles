classdef LandingSite < handle
  properties
    file
    low
    high
    dtm
    label
    max_angles
    res
    mask
    good_pixels
    datasize
  end
  methods
    function self = LandingSite(file)
      self.file = file;
      self.label = pds_label_parse_v3(strcat(file, '.pdslabel'));
      self.res = self.label.image_map_projection.mapscale;
    end

    function setup(self, cut)
      if nargin < 2
        cut = false;
      end
      dtm = fitsread(strcat(self.file, '.fits'));
      if cut
        s = size(dtm);
        dtm = dtm(round(s(1)*4/10):round(s(1)*5/10), round(s(2)*4/10):round(s(2)*5/10));
      end
      self.mask = dtm ~= min(dtm(:));
      self.low = min(dtm(self.mask));
      self.high = max(dtm(self.mask));
      dtm(~self.mask) = NaN;
      if ~all(isnan(dtm(1,:)))
        dtm = padarray(dtm,[1 0], NaN, 'pre');
      end
      if ~all(isnan(dtm(end,:)))
        dtm = padarray(dtm,[1 0], NaN, 'post');
      end
      if ~all(isnan(dtm(:,1)))
        dtm = padarray(dtm,[0 1], NaN, 'pre');
      end
      if ~all(isnan(dtm(:,end)))
        dtm = padarray(dtm,[0 1], NaN, 'post');
      end
      self.dtm = dtm;
      self.datasize = size(self.dtm);
      self.max_angles = Inf(self.datasize);
      self.max_angles(~self.mask) = NaN;
      self.good_pixels = numel(find(self.mask));
    end
  end
end
