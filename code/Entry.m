classdef Entry < handle
  properties
    climb_angle
    % position
    pos
  end
  methods
    function self = Entry(climb_angle, pos)
      self.climb_angle = climb_angle;
      % self.position = position;
      self.pos = pos;
    end

    % function r =  lt(a,b)
    %   r = a.climb_angle < b.climb_angle;
    % end

    % function r =  gt(a,b)
    %   r = a.climb_angle > b.climb_angle;
    % end

    % function r =  le(a,b)
    %   r = a.climb_angle <= b.climb_angle;
    % end

    % function r =  ge(a,b)
    %   r = a.climb_angle >= b.climb_angle;
    % end

    function r =  eq(a,b)
      r = isequaln(a,b);
    end

    % function r =  ne(a,b)
    %   r = a.climb_angle ~= b.climb_angle;
    % end
  end
end
