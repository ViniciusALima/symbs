% Abstraction of a physical body of an multibody system
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

classdef Body < Frame
% Body abstracts a body of a multibody system.
%   Every Body has a fixed local coordinate system with origin on its center of
%   gravity (CG).
properties
	name    % String to store the name of the body
	mass    % Total mass of the body.
	inertia % Body inertia with respect to its CG.
	shape   % Cell array of points forming the shape of the object
	force   % Total force applied on the CG
	torque  % Total torque applied on the body
end

methods
	function obj = Body(name)
	% Body creates a symbolic body object and initialize cell array types.
		obj.name = name;
		obj.mass = sym(strcat('m_', name));
		obj.inertia = sym(strcat('mI_', name));
		obj.force = Force;
		obj.torque = 0;
		obj.origin.r = [sym(strcat('x_', name));sym(strcat('y_', name))];
		obj.origin.dr = [sym(strcat('dx_', name));sym(strcat('dy_', name))];
		obj.origin.ddr = [sym(strcat('ddx_', name));sym(strcat('ddy_', name))];
		obj.theta = sym(strcat('th_', name));
		obj.dtheta = sym(strcat('dth_', name));
		obj.ddtheta = sym(strcat('ddth_', name));
		obj.points = {};
		obj.shape  = Shape();
	end

	function draw(obj, h)
		obj.shape.draw(h,obj);
	end
end

end
