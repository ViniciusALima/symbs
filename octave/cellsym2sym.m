% Convert a cell of symbolics into an array of symbolics
%
% @author: Vinicius de A. Lima
% @date: 2018-10-26


% This file is part of symbs.
%
% symbs is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% symbs is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with symbs.  If not, see <https://www.gnu.org/licenses/>.

function sy = cellsym2sym(csym)
	% cellsym2sym converts a cell of symbolic variebales into an symbolic
	% array
	[m,n] = size(csym);
	sy = sym('a',[m,n]);
	for i=1:m
		for j=1:n
			sy(i,j) = csym{i,j};
		end
	end
end
