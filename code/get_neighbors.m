function neighbors = get_neighbors(cp)
  % ns = [ 1 0 ; 0 1 ; -1 0 ; 0 -1 ];
  neighbors = [ 1 0 ; 0 1 ; -1 0 ; 0 -1 ];
  neighbors(:, 1) = neighbors(:,1) + cp(1);
  neighbors(:, 2) = neighbors(:,2) + cp(2);
  % for n = 1:4
  %   neighbors{n} = cp + ns(n,:);
  % end
end
