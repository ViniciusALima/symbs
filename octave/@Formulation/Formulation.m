% Abstract class (Interface) to be inherited by any impelementation
% of an multibody equations formulation
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

classdef Formulation < handle

methods
	function ccode_formulation(obj,output_dir)
	% ccode_formulation abstract method to implement c-code generation for
	%	inherited formulations.
	end

	function set_multibody(obj, mbs)
	% set_multibody pass a new multibody to the formulation and updates its
	%   matrices and vectors.
	end
end

end
