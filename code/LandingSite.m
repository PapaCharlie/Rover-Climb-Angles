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
    fr
    datasize
  end
  methods
    function self = LandingSite(file)
      self.file = file;
      self.label = pds_label_parse_v3(strcat(file, '.pdslabel'));
    end

    function dijkstra(self, startpos)
      neighbors = [ 1 0 ; 0 1 ; -1 0 ; 0 -1 ];
      if nargin == 1
        startpos = round(size(self.dtm)./2.0);
      end
      self.max_angles(startpos(1), startpos(2)) = 0;
      heap = cFibHeap;
      heap.insert(Entry(0, startpos));
      count = 0;
      while heap.n
        count = count + 1;
        if mod(count, round(self.good_pixels/100)) == 0
          fprintf('%d%% done; ', count/round(self.good_pixels/100))
        end
        node = heap.extractMin;
        ns = [ neighbors(:,1) + node.pos(1), neighbors(:,2) + node.pos(2) ];
        for n = 1:4
          neighbor = ns(n,:);
          if all(and(ns(n,:) > 0, ns(n,:) <= self.datasize)) && ~isnan(self.dtm(ns(n,1), ns(n,2)))
            if abs(node.height_diff) < abs(self.dtm(ns(n,1), ns(n,2)) - self.dtm(node.pos(1),node.pos(2)))
              alt = self.dtm(ns(n,1), ns(n,2)) - self.dtm(node.pos(1),node.pos(2));
            else
              alt = node.height_diff;
            end
            if abs(alt) < abs(self.max_angles(ns(n,1), ns(n,2)))
              self.max_angles(ns(n,1), ns(n,2)) = alt;
              heap.insert(Entry(alt, ns(n,:)));
            end
          end
        end
      end
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
      self.res = self.label.image_map_projection.mapscale;
    end

    function add_entries(self, pos)
      ng = get_neighbors(pos);
      for n = 1:length(ng)
        height_diff = self.dtm(ng(n,1), ng(n, 2)) - self.dtm(pos(1),pos(2));
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
          tops = self.fr.popall();
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

    function BFS(self,startpos)
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
