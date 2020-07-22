% Defines the shape of a body, some basic shapes are pre implemented
% as static methods for convinience
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

classdef Shape
properties
	color % color of shape
	filled % fill flag
	sub_shapes % cell array of shapes overlayed.
	vertices % cell array of Points for the vertices of the shape
end

methods
	function obj = Shape(varargin)
		ip = inputParser;
		ip.addParamValue('vertices', {Point()}, @iscell);
		ip.addParamValue('color', 'k', @ischar);
		ip.addParamValue('filled', false, @islogical);
		ip.parse(varargin{:});
		obj.vertices = ip.Results.vertices;
		obj.color = ip.Results.color;
		obj.filled = ip.Results.filled;
	end

	function h = draw(obj,h,frame)
		h_ = [];
		frame_ = Frame;
		if nargin > 1
			h_ = h;
		else
			h_ = figure();
		end
		if nargin > 2
			frame_ = frame;
		end
		figure(h_);
		hold_status = obj.get_hold_status(h_);
		if not(isempty(obj.vertices))
			if not(isempty(obj.vertices{1})) % TODO: Octave struct array differs from matlab.
				% update frame
				frame_.points = obj.vertices;
				func = @(x) frame_.point_position_to_parent(x);
				points = frame_.apply_function_over_points(func);
				[x, y] = obj.cellPoint2xy(points);
				% plot current shape
				if obj.filled
					fill(x,y,obj.color,'EdgeColor',obj.color);
				else
					plot([x x(1)],[y y(1)],obj.color);
				end
			end
		end
		% plot sub shapes
		hold on;
		for i=1:length(obj.sub_shapes)
			obj.sub_shapes{i}.draw(h_,frame_);
		end
		obj.set_hold_status(hold_status);
	end
end

methods(Static)
	function [x,y] = cellPoint2xy(cpoint)
	% cellPoint2xy receives a cell array of Points and return the x and y
	%	coordinates of the points.
		x = zeros(size(cpoint));
		y = x;
		for i=1:length(x)
			x(i) = cpoint{i}.x;
			y(i) = cpoint{i}.y;
		end
	end

	function shape = circle(varargin)
	% circle returns a circular shape.
	% circle(R,P) returns a circular shape of radius R with center at position P
	% circle(R,P,params) params can be 'color' (@ischar) and 'filled'
	%	(@islogical)
		ip = inputParser;
		isPoint = @(x) Point.is_Point(x);
		ip.addRequired('radius',@isnumeric);
		ip.addRequired('position',isPoint);
		ip.addParamValue('color','k',@ischar);
		ip.addParamValue('filled',false,@islogical);
		ip.parse(varargin{:});
		t = linspace(0,2*pi,32);
		x = ip.Results.radius*cos(t) + ip.Results.position.x;
		y = ip.Results.radius*sin(t) + ip.Results.position.y;
		shape = Shape("vertices", Shape.xy2cellPoint(x,y),
        "color", ip.Results.color,...
        "filled", ip.Results.filled);
	end

	function cpoint = xy2cellPoint(x,y)
	% xy2cellPoint receives x and y coordinates vectors and returns a cell array
	%	of Points at positions x,y.
		cpoint = cell(size(x));
		for i=1:length(cpoint)
			cpoint{i} = Point(x(i),y(i));
		end
	end

	function hold_status = get_hold_status(h)
		hold_status = ishold(h);
	end

	function set_hold_status(hold_status)
		if hold_status
			hold on;
		else
			hold off;
		end
	end

	function shape = rectangle(varargin)
	% rectangle returns a shape of a rectangle.
	% rectangle(B,H,P) returns a rectangle of base B, height H with cg position
	%	at P.
	% rectangle(B,H,P,params) params can be 'color' (@ischar) and 'filled'
	%	(@isnumeric).
		ip = inputParser;
		isPoint = @(x) Point.is_Point(x);
		ip.addRequired('base',@isnumeric);
		ip.addRequired('height',@isnumeric);
		ip.addRequired('position',isPoint);
		ip.addParamValue('color','k',@ischar);
		ip.addParamValue('filled',false,@islogical);
		ip.parse(varargin{:});
		base = ip.Results.base;
		height = ip.Results.height;
		position = ip.Results.position;
		x = [-base/2   base/2    base/2   -base/2] + position.x;
		y = [-height/2 -height/2 height/2 height/2] + position.y;
		shape = Shape("vertices", Shape.xy2cellPoint(x,y),...
        "color", ip.Results.color,...
        "filled", ip.Results.filled);
	end
end
end
