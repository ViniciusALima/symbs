% Abstract force to be inherited by any other force element
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

classdef Force
% Force is an abstract class to be inherited by any force element.

% @author Vinicius de A. Lima
% @date 2018-12-06
properties
	fx % component along x axis
	fy % component along y axis
end

methods
	function obj = Force(varargin)
		val = @(x) isnumeric(x) || isa(x,'sym');
		ip=inputParser;
		ip.addOptional('fx',0,val);
		ip.addOptional('fy',0,val);
		ip.parse(varargin{:});
		ir = ip.Results;
		obj.fx = ir.fx;
		obj.fy = ir.fy;
	end

	function out = plus(obj1,obj2)
		out = Force(obj1.x+obj2.x,obj1.y+obj2.y);
	end

	function out = minus(obj1,obj2)
		out = Force(obj1.x-obj2.x,obj1.y-obj2.y);
	end

	function out = torque(obj1,obj2)
		out = obj1.x*obj2.y-obj1.y*obj2.x;
	end
end
end
