% Perform kinematic transformations in 2D Space
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

classdef Kine
% Kine defines methods to perform kinematic transformations in 2D space

methods(Static)
	function r = nullvector()
	% nullvector Returns a 2D null column vector.
		r = [0;0];
	end

	function r = R(theta, p)
	% R(theta, p) Relative position of a point in an rotated frame.
	%
	% See also dR, ddR
		c = cos(theta);
  		s = sin(theta);
		r = [c -s; s c]*p;
	end

	function dr = dR(theta, dtheta, p, dp)
	% dR Relative velocity of a point fixed in a rotating frame.
	%
	%   dR(p, theta, dtheta) returns the velocity vector dr of a point p within a
	%   rotatig frame with orientation theta and angular velocity dtheta
	%
	% See also R, ddR
		c = cos(theta);
		s = sin(theta);
		dr = dtheta*[-s -c; c -s]*p + [c -s; s c]*dp;
	end

	function ddr = ddR(theta, dtheta, ddtheta, p, dp, ddp)
	% ddR Relative acceleration of a point fixed in a rotating frame.
	%
	%  dR(p, theta, dtheta) returns the acceleration vector ddr of a point p within
	%   a rotatig frame with orientation theta, angular velocity dtheta and
	%   acceleration ddtheta.
	%
	% See also R, dR
		c = cos(theta);
		s = sin(theta);
		ddr = (ddtheta*[-s -c; c -s] + dtheta*[-c s; -s -c])*p ...
		+ 2*dtheta*[-s -c; c -s]*dp + [c -s; s c]*ddp;
	end
end

end
