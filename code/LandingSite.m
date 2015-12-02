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
      global frontier;
      self.fr = frontier.Frontier();
    end

    function add_entries(self, pos)
      ng = get_neighbors(pos);
      for n = 1:length(ng)
        height_diff = self.dtm(ng(n,1), ng(n, 2)) - self.dtm(pos(1),pos(2));
        % climb_angle = round(atand(height_diff/self.res), 1);
        % if climb_angle < 0
        %   climb_angle = 0;
        % end
        if height_diff < self.max_angles(ng(n, 1), ng(n, 2)) && ~isnan(self.dtm(ng(n, 1), ng(n, 2)))
          self.fr.add_entry(py.tuple([height_diff  ng(n, :)]));
        end
      end
    end

    function compute_max_angles(self, startpos)
      function frontier_search
        for i = 1:5000
          if mod(i, 50) == 0
            disp(i)
          end
          % self.fr.heap
          tops = self.fr.popall();
          % self.fr.heap
          for n = 1:length(tops)
            if self.max_angles(tops{n}{2}, tops{n}{3}) == Inf
              self.max_angles(tops{n}{2}, tops{n}{3}) = tops{n}{1};
              self.add_entries([tops{n}{2}, tops{n}{3}]);
            end
          end
        end
      end
      if nargin == 1
        startpos = round(size(self.dtm)./2.0);
      end

      global frontier;
      self.fr = frontier.new_frontier();

      self.max_angles(startpos(1), startpos(2)) = 0;
      self.add_entries(startpos);
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
      while iteration <= (self.good_pixels + 10)
        neighbors = get_neighbors(current);
        for n = 1:4
          neighbor = neighbors(n,:);
          if all(and(neighbor > 0, neighbor <= self.datasize)) && ~isnan(self.max_angles(neighbor(1), neighbor(2)))
            height_diff = self.dtm(neighbor(1), neighbor(2)) - self.dtm(current(1),current(2));
            % climb_angle = round(atand(height_diff/self.res), 4);
            if self.max_angles(neighbor(1), neighbor(2)) > height_diff
              self.max_angles(neighbor(1), neighbor(2)) = height_diff;
            end
          end
        end
        current = self.spiralize(startpos, current);
        iteration = iteration + 1;
        if mod(iteration, round(self.good_pixels/100)) == 0
          fprintf('%d%% done; ', iteration/round(self.good_pixels/100))
        end
      end
      angles = self.max_angles;
      save(strcat('../data', self.file, '.mat'), 'angles')
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
