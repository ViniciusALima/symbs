% The multibody system model
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

classdef Symbs < handle
% mbs abstracts a multibody system model.

properties
	name                 % String to identify the model
	bodies               % Cell array of bodies.
	joints               % Cell array of joints
	motors               % Cell array of motors
end

methods
	function obj = Symbs(name)
	% mbs initialize properties types.
		obj.name = name;
		%obj.bodies = {};
		%obj.controls = [];
		%obj.explicit_constraints = @(mb) [];
		%obj.external_forces = @(mb) [];
		%obj.implicit_constraints = @(mb) [];
	end

	function [b, idx] = get_body_by_name(obj, name)
	% MBS.get_body_by_name(name) perform a linear search of the bodies list
	%   for a body named 'name'. Returns the body if found or a empty if
	%   not found. Optionally on return is possible to get the body index
	%   'idx' within the bodies list.
		b = [];
		for i=1:length(obj.bodies)
			if strcmp(obj.bodies{i}.name, name)
				b = obj.bodies{i};
				idx = i;
				break;
			end
		end
	end

	function add_body(obj, body)
	% MBS.add_body(name, mass, inertia) adds a body to the bodies list.
	%   The name of the body must be unique to avoid conflict between
	%   symbolic variables. The MBS objects does not keep track of
	%   duplicated names.
		obj.bodies{end+1} = body;
	end

	function add_motor(obj,symbol)
	% MBS.add_motor(name) add a motor symbolic variable to the motors list
	% named 'name'.
		obj.motors{end+1} = sym(symbol);
	end

	function add_joint(obj, joint)
		obj.joints{end+1} = joint;
	end

	function draw(obj,h,state)
		bodies = obj.bodies; % Copy to not override the symbols
		n=length(bodies);
		for i=1:n
			bodies{i}.origin = Point(state(i),state(n+i));
			bodies{i}.theta = state(2*n+i);
			bodies{i}.draw(h);
		end
	end

	function [q, x, y, th] = position_vector(obj)
	% position_vector returns a vector X with the position of all bodies.
	%   X = [ x1 ... xn y1 ... yn th1 ... thn ]'
		n = length(obj.bodies);
		x = sym(zeros(n,1));
		y = x;
		th = x;
		for i = 1:n
			x(i) = obj.bodies{i}.origin.x;
			y(i) = obj.bodies{i}.origin.y;
			th(i) = obj.bodies{i}.theta;
		end
		q = [x;y;th];
	end

	function q_ = q(obj)
	% q is alias for method position_vector.
		q_ = obj.position_vector;
	end

	function [dq, dx, dy, dth] = velocity_vector(obj)
	% velocity_vector returns a vector dX with the velocities of all bodies.
	%   dX = [ dx1 ... dxn dy1 ... dyn th1 ... dthn ]'
		n = length(obj.bodies);
		dx = sym(zeros(n,1));
		dy = dx;
		dth = dx;
		for i = 1:n
			dx(i) = obj.bodies{i}.origin.dx;
			dy(i) = obj.bodies{i}.origin.dy;
			dth(i) = obj.bodies{i}.dtheta;
		end
		dq = [dx;dy;dth];
	end

	function dq_ = dq(obj)
	% dq is alias for method velocity_vector.
		dq_ = obj.velocity_vector();
	end

	function [ddq, ddx, ddy, ddth] = acceleration_vector(obj)
	% acceleration_vector returns a vector ddX with the forces and torques of all bodies.
	%   ddX = [ ddx1 ... ddxn fy1 ... ddyn ddth ... ddthn ]'
		n = length(obj.bodies);
		ddx = sym(zeros(n,1));
		ddy = ddx;
		ddth = ddx;
		for i = 1:n
			ddx(i) = obj.bodies{i}.origin.ddx;
			ddy(i) = obj.bodies{i}.origin.ddy;
			ddth(i) = obj.bodies{i}.ddtheta;
		end
		ddq = [ddx;ddy;ddth];
	end

	function ddq_ = ddq(obj)
	% ddq is alias for method acceleration_vector.
		ddq_ = obj.acceleration_vector;
	end

	function [Qex, fx, fy, fth] = external_force_vector(obj)
	% external_force_vector returns a vector F with the forces and torques of all bodies.
	%   dX = [ fx1 ... fxn fy1 ... fyn l1 ... ln ]'
		n = length(obj.bodies);
		fx = sym(zeros(n,1));
		fy = fx;
		fth = fx;
		for i = 1:n
			fx(i) = obj.bodies{i}.force.fx;
			fy(i) = obj.bodies{i}.force.fy;
			fth(i) = obj.bodies{i}.torque;
		end
		Qex = [fx;fy;fth];
	end

	function Qex_ = Qex(obj)
	% Qex is alias for method external_force_vector.
		Qex_ = obj.external_force_vector;
	end

	function [M, m, mI] = mass_matrix(obj)
	% inertial_vector returns the mass and inertia vector of all bodies.
	%   M = [ m1 ... mn m1 ... mn I1 ... In ]'
		n = length(obj.bodies);
		m = sym(zeros(n,1));
		mI = m;
		for i = 1:n
			m(i) = obj.bodies{i}.mass;
			mI(i) = obj.bodies{i}.inertia;
		end
		M = diag([m; m; mI]);
	end

	function M_ = M(obj)
	% M is alias for method mass_matrix.
		M_ = obj.mass_matrix;
	end

	function Phi = constraint_equations(obj)
	% TODO help
		Phi = sym([]);
		m = length(obj.joints);
		for i=1:m
			Phi = [Phi; obj.joints{i}.get_constraints];
		end
	end

	function Phi_ = Phi(obj)
	% TODO help
		Phi_ = obj.constraint_equations;
	end
end

end
