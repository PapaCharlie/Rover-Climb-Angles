classdef Entry < handle
  properties
    height_diff
    pos
  end
  methods
    function self = Entry(height_diff, pos)
      self.height_diff = height_diff;
      self.pos = pos;
    end

    function r =  lt(a,b)
      r = a.height_diff < b.height_diff;
    end

    function r =  gt(a,b)
      r = a.height_diff > b.height_diff;
    end

    function r =  le(a,b)
      r = a.height_diff <= b.height_diff;
    end

    function r =  ge(a,b)
      r = a.height_diff >= b.height_diff;
    end

    function r =  eq(a,b)
      r = a.height_diff == b.height_diff;
    end

    % function r =  ne(a,b)
    %   r = a.height_diff ~= b.height_diff;
    % end
  end
end
