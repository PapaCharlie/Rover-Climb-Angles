classdef Frontier < handle
  properties
    entries
    landingsite
  end
  methods
    function self = Frontier(landingsite)
      if nargin < 2
        landingsite = [];
      end
      self.entries = cell(0);
      self.landingsite = landingsite;
    end

    function insert(self, entry)
      if isempty(self.entries)
        self.entries{1} = entry;
      else
        inserted = false;
        n = 1;
        while n <= length(self.entries)
          if ~inserted
            if entry.climb_angle < self.entries{n}.climb_angle
              self.entries = {self.entries{1:n-1} entry self.entries{n:end}};
              inserted = true;
            elseif entry == self.entries{n}
              inserted = true;
            end
            n = n + 1;
            continue
          end
          if inserted && isequaln(self.entries{n}.pos, entry.pos)
            self.entries = {self.entries{1:n-1} self.entries{n+1:end}};
          end
          n = n + 1;
        end
        if ~inserted
          self.entries = {self.entries{1:end} entry};
        end
      end
    end

    function top = peek(self)
      if ~isempty(self.entries)
        top = self.entries{1};
      else
        top = [];
      end
    end

    function top = pop(self)
      if ~isempty(self.entries)
        top = self.entries{1};
        self.entries = {self.entries{2:end}};
      else
        top = [];
      end
    end

    function tops = popall(self)
      tops{1} = self.pop();
      if ~isempty(self.entries)
        for n = 1:length(self.entries)
          if self.entries{n}.climb_angle == tops{1}.climb_angle
            tops{n+1} = self.entries{n};
          else
            break
          end
        end
      end
    end

  end
end
