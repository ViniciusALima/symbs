% Implements a Point in 2D Euclidean space
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

classdef Point
% Point is a value class that represents a point in 2D Euclidean space.
%
%   Note: The point object is not responsible for knowing its frame of
%   reference.
%

properties
	r % Positon vector relative to its origin
	dr % Velocity vector relative to its origin
	ddr % Acceleration vector relative to its origin
end

methods
	function obj = Point(x,y)
	% Point(x,y) define a point object at coordinates x and y.
		if nargin < 1;
			obj.r = [0;0];
		else
			obj.r = [x;y];
		end
		obj.dr = [0;0];
		obj.ddr = [0;0];
	end

	function x_ = x(obj)
	% Point.x returns the x coordinate of position vector r
		x_ = obj.r(1);
	end

	function dx_ = dx(obj)
	% Point.dx returns the x coordinate of velocity vector dr
		dx_ = obj.dr(1);
	end

	function ddx_ = ddx(obj)
	% Point.ddx returns the x coordinate of acceleration vector ddr
		ddx_ = obj.ddr(1);
	end

	function y_ = y(obj)
	% Point.y returns the y coordinate of position vector r  
		y_ = obj.r(2);
	end

	function dy_ = dy(obj)
	% Point.dy returns the y coordinate of velocity vector dr
		dy_ = obj.dr(2);
	end

	function ddy_ = ddy(obj)
	% Point.ddy returns the y coordinate of acceleration vector ddr
		ddy_ = obj.ddr(2);
	end
end

methods(Static)
	function bool = is_Point(p)
		bool = isa(p,'Point');
	end
end

end
