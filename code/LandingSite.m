classdef LandingSite < handle
  properties
    low
    high
    dtm
    label
    max_angles
    res
    mask
    good_pixels
    fr
    datasize
  end
  methods
    function self = LandingSite(file)
      self.label = pds_label_parse_v3(strcat(file, '.pdslabel'));
      dtm = fitsread(strcat(file, '.fits'));
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
      self.res = self.label.image_map_projection.mapscale;
    end

    function reset(self)
      self.max_angles = Inf(size(self.dtm));
      self.max_angles(~self.mask) = NaN;
    end

    function add_entries(self, pos)
      ng = get_neighbors(pos);
      for n = 1:length(ng)
        height_diff = self.dtm(ng{n}(1),ng{n}(2)) - self.dtm(pos(1),pos(2));
        climb_angle = round(atan(height_diff/self.res), 4);
        if climb_angle < 0
          climb_angle = 0;
        end
        if climb_angle < self.max_angles(ng{n}(1), ng{n}(2)) && ~isnan(self.dtm(ng{n}(1), ng{n}(2)))
          self.fr.insert(Entry(climb_angle, ng{n}));
        end
      end
    end

    function compute_max_angles(self, startpos)
      function frontier_search
        for i = 1:10
          i
          length(self.fr.entries)
          tops = self.fr.popall();
          for n = 1:length(tops)
            self.max_angles(tops{n}.pos(1), tops{n}.pos(2)) = tops{n}.climb_angle;
            self.add_entries(tops{n}.pos);
          end
        end
      end
      if nargin == 1
        startpos = round(size(self.dtm)./2.0);
      end
      self.max_angles(startpos(1), startpos(2)) = 0;
      self.fr = Frontier(self);
      self.add_entries(startpos);
      % current_max = 0;
      frontier_search;
    end

    function next = spiralize(self, center, current)
      if current(1) == center(1) - 1 && current(2) >= center(2)
        next = [current(1) + 1 current(2) + 2];

      elseif current(1) < center(1) && current(2) >= center(2)
        next = [current(1) + 1 current(2) + 1];

      elseif current(1) >= center(1) && current(2) > center(2)
        next = [current(1) + 1 current(2) - 1];

      elseif current(1) > center(1) && current(2) <= center(2)
        next = [current(1) - 1 current(2) - 1];

      elseif current(1) <= center(1) && current(2) < center(2)
        next = [current(1) - 1 current(2) + 1];

      end
    end

    function bad_compute_max_angles(self,startpos)
      if nargin == 1
        startpos = round(self.datasize./2.0);
      end
      self.max_angles(startpos(1), startpos(2)) = 0;
      current = startpos + [ 0  1 ];
      iteration = 1;
      % figure
      % hold on
      % imagesc(self.max_angles)
      while iteration <= (self.good_pixels + 10)
        neighbors = get_neighbors(current);
        for n = 1:4
          neighbor = neighbors(n,:);
          if all(and(neighbor > 0, neighbor <= self.datasize)) && ~isnan(self.max_angles(neighbor(1), neighbor(2)))
            height_diff = self.dtm(neighbor(1), neighbor(2)) - self.dtm(current(1),current(2));
            % climb_angle = round(atan(height_diff/self.res), 4);
            climb_angle = round(atan(height_diff/self.res), 4);
            if self.max_angles(neighbor(1), neighbor(2)) > climb_angle
              self.max_angles(neighbor(1), neighbor(2)) = climb_angle;
            end
          end
        end
        current = self.spiralize(startpos, current);
        iteration = iteration + 1;
        if mod(iteration, round(self.good_pixels/100)) == 0
          fprintf('%d%% done; ', iteration/round(self.good_pixels/100))
          % imagesc(self.max_angles)
        end
      end
      % hold off
      angles = self.max_angles;
      save(strcat(self.file, '.mat'), 'angles')
    end

  end
end

% function DFS(lp, cp) % last position, current position
%   % remember, dtm is distance from craft
%   if ~isnan(self.dtm(cp(1),cp(2)))
%     height_diff = self.dtm(lp(1),lp(2)) - self.dtm(cp(1),cp(2));
%     climb_angle = atan(height_diff/self.res);
%     if self.max_angles(cp(1), cp(2)) > climb_angle
%       neighbors = [ 1 0 ; 0 1 ; -1 0 ; 0 -1 ];
%       neighbors(:, 1) = neighbors(:,1) + cp(1);
%       neighbors(:, 2) = neighbors(:,2) + cp(2);
%       for n = 1:4
%         DFS(cp, neighbors(n,:))
%       end
%     end
%   end
% end
