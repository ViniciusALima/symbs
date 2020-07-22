% Implements Newton Euler equations in DAE-3 index form
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

classdef Form_newton_euler_dae3 < Formulation
% Form_Newton_Euler_DAE calculates the equation of motion of a constrained
%	multibody system based on the Newton-Euler equations and contraint
%	equations, achieving a DAE system of index 3.
%
%   ddq = Minv * ( Q - Phiq'*lambda )
%   Phi = 0
%
%   where ddq is the vector of cartesian coordinates, Minv the inverse
%   of the mass matrix M, Q the vector of external, non-conservative
%   and inertial forces, Phix the Jacobian of the constraints and
%   lambda the Lagrange multipliers. The term Phix'*lambda represents
%   the internal constraints forces.

properties
	mbs % Multibody system
	Minv % Inverse of mass matrix
	Q % Forces vector
	Phi % Constraints
	Phiq % Jacobian of the constraints
	lambda % Vector of Lagrange multipliers
end

methods
	function obj = Form_newton_euler_dae3(mbs)
		obj.set_multibody(mbs);
	end

	function ccode_formulation(obj,output_file)
		states_symb = sym2cellstr([obj.mbs.q;obj.mbs.dq].');
		motors_symb = cellsym2cellstr(obj.mbs.motors);
		lambdas_symb = sym2cellstr(obj.lambda.');
		argin_symb = {states_symb motors_symb lambdas_symb};
		argin_name = {'states','motors','lambdas'};
		argin_type = {'const T*','const T*','const T*'};
		name = obj.mbs.name;
		
		cxx = Coder_cxx(output_file);
		cxx.define_function_from_matrix(obj.rhs,[name '_differential'],...
			'argin_symb',argin_symb,...
			'argin_name',argin_name,...
			'argin_type',argin_type);
		
		cxx.define_function_from_matrix(obj.Phi,[name '_algebraic'],...
			'argin_symb',argin_symb,...
			'argin_name',argin_name,...
			'argin_type',argin_type);
	end
	
	function rh = rhs(obj)
		if isempty(obj.Phi)
			rh = obj.Minv*obj.Q;
		else
			rh = obj.Minv*(obj.Q-obj.Phiq.'*obj.lambda);
		end
	end
	
	function set_multibody(obj, mbs)
		obj.mbs = mbs;
		obj.Minv = diag(1./diag(mbs.M));
		obj.Q = mbs.Qex;
		obj.Phi = mbs.Phi;
		if isempty(obj.Phi)
			obj.lambda = obj.Phi;
			obj.Phiq = obj.Phi;
		else
			m = length(mbs.Phi);
			obj.lambda = sym('lambda',[m,1]);
			obj.Phiq = jacobian(mbs.Phi,mbs.q);
		end	
	end
end

end
