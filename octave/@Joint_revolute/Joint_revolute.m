% Implementation of a revolute joint (hinge)
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
classdef Joint_revolute < Joint
% Joint_revolute defines a revolute joint (hinge) between two bodies by
%   constraining its translationals degrees of freedom at a common
%   attachment point.

properties
	body1  % First body
	point1 % Attachment point on first body local coordinate system
	body2  % Second body
	point2 % Attachment point on second body local coordinate system
end

methods
	function obj = Joint_revolute(body1, point1, body2, point2)
	% Joint_revolute(body1, point1, body2, point2) defines a revolute
	%   joint (hinge) between two bodies by constraining its 
	%   translationals degrees of freedom at a commom attachment point.
	%   body1 and body2 are the bodies to be connected, point1 is the
	%   attachement point on body1 local coordinate system and point2
	%   is the attachement point on body2 local coordinate system.
	if nargin < 3
		body2 = [];
		point2 = [];
	end
	obj.body1 = body1;
	obj.point1 = point1;
	obj.body2 = body2;
	obj.point2 = point2;
	end

	function cons = get_constraints(obj)
	% Joint_revolute.get_constraints returns the two translational
	%   constraints associated with the hinge joint.
	if isempty(obj.body2)
		cons = obj.body1.point_to_parent(obj.point1).r;
	else
		cons =   obj.body1.point_to_parent(obj.point1).r ...
			- obj.body2.point_to_parent(obj.point2).r;
	end
	end
end

end
