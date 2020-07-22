% A movable reference frame
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
%
classdef Frame
% Frame is a value class that represents a movable reference frame.
%   Every frame has an associated coordinate system used to determine the
%   frame position and orientation.
%   Every frame carries a list of points (cell array) with each point
%   defined in it. It is reponsible to perform frame changes in these
%   points when necessary.
%
%   Note: The point object is not responsible for knowing its frame of
%   reference.
%
properties
	origin   % Origin point of the frame (relative to any arbitrary Frame).
	theta   % Orientation angle of the frame.
	dtheta   % Angular velocity of the frame.
	ddtheta   % Angular acceleration of the frame.
	points   % List of points within the frame.
end

methods
	function obj = Frame (x,y,theta)
	% Frame(x,y,theta) define a frame object with origin at Point(x,y) and
	% orientation angle theta.
		if nargin < 3
			theta = 0;
		end
		if nargin < 2
			x = 0;
			y = 0;
		end
		obj.origin = Point(x,y);
		obj.theta = theta;
		obj.dtheta = 0;
		obj.ddtheta = 0;
		obj.points = {};
	end

	function r = position(obj)
	% Frame.position returns the position vector r of its origin.
		r = obj.origin.r;
	end

	function v = velocity(obj)
	% Frame.velocity returns the velocity vector dr of its origin.
		v = obj.origin.dr;
	end

	function a = acceleration(obj)
	% Frame.acceleration returns the acceleration vector ddr of its origin.
		a = obj.origin.ddr;
	end

	function p = get_point(obj, idx)
	% Frame.get_point(idx) returns the point in the points list at location
	% idx
		p = obj.points{idx};
	end

	function ar = angular_position(obj)
	% Frame.angular_position returns the frame angular orientation theta
		ar = obj.theta;
	end

	function av = angular_velocity(obj)
	% Frame.angular_velocity returns the frame angular velocity dtheta
		av = obj.dtheta;
	end

	function aa = angular_acceleration(obj)
	% Frame.angular_acceleration returns the frame angular acceleration
	%   ddtheta
		aa = obj.ddtheta;
	end

	function out = apply_function_over_points(obj,func)
		out = cell(size(obj.points));
		for i=1:length(obj.points)
			out{i} = func(obj.points{i});
		end
	end

	function q = point_to_parent(obj, p)
	% Frame.point_to_parent(p) takes the point p defined within this frame
	%   and change it to the parents frame.
		q = Point;
		q.r = obj.point_position_to_parent(p).r;
		q.dr = obj.point_velocity_to_parent(p).dr;
		q.ddr = obj.point_acceleration_to_parent(p).ddr;
	end

	function q = point_position_to_parent(obj,p)
		q = Point;
		q.r = obj.origin.r + Kine.R(obj.theta, p.r);
	end

	function q = point_velocity_to_parent(obj,p)
		q = Point;
		q.dr = obj.origin.dr + Kine.dR(obj.theta, obj.dtheta, p.r, p.dr);
	end

	function q = point_acceleration_to_parent(obj,p)
		q = Point;
		q.ddr = obj.origin.ddr + Kine.ddR(obj.theta,obj.dtheta,obj.ddtheta, ...
			p.r, p.dr, p.ddr);
	end

	function obj = to_parent(obj, parent_frame)
	% Frame.to_parent(parent) returns a copy of this frame coincident with
	%   its parent, updating the positions of the points to be conformant
	%   with the new origin and orientation.
		for i=1:length(obj.points)
			obj.points{i} = obj.point_to_parent(obj.points{i});
		end
		obj.origin = parent_frame.origin;
		obj.theta = parent_frame.theta;
		obj.dtheta = parent_frame.dtheta;
		obj.ddtheta = parent_frame.ddtheta;
	end
end

methods(Static)
end

end
