% Abstract class (Interface) to be inherited by any new Joint constraint
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

classdef Joint
% Abstract class for Joint objects.
%   Inherited Joint must overload the get_contraint method returning the
%   symbolic constraint equation of the joint.

methods
	function cons = get_constraint(obj)
	% Joint.get_constraint returns the symbolic constraint equation of this
	%   joint.
	end
end

end
