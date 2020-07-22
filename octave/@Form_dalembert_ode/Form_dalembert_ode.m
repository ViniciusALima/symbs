% Implements the D`Alemberts ODE Formulation
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

classdef Form_dalembert_ode < Formulation
% Form_dalembert_ode calculates the equation of motion of a constrained
%	multibody system based on the D'Alemberts principle, achieving a
%	ODE system with the minimum number of coordinates (generalized
%	coordinates).
%
% R.'*Mdiag*R*ddz = R.'*Qex-R.'*M*dR*dz
%        M(z)*ddz = Q(z,dz);
%

% This file is part of symbs
%
% @author: Vinicius de A. Lima
% @date: 2018-11-29
%
properties
	mbs % multibody system
	M % Generalized mass matrix
	Q % Generalized force vector
	R % Projection Matrix, basis of the subspace of possible motions
	dR % Time derivative of the projection matrix
	z % Independent coordinates
	dz % Independent velocities
	ddz % Independent accelerations
	z_q % Independent coordinates as function of dependents
	%TODO dz_q % Independent velocities as function of dependents
	%TODO ddz_q % Independent accelerations as function of dependents
	q_z % Dependent coordinates as function of independents
	dq_z % Dependent velocities as function of independents
	ddq_z % Dependent accelerations as function of independents
end

methods
	function obj = Form_dalembert_ode(mbs, z_q)
		obj.set_multibody(mbs, z_q);
	end
	
	function ccode_formulation(obj,output_file)
		states_symb = sym2cellstr([obj.z;obj.dz].');
		motors_symb = cellsym2cellstr(obj.mbs.motors);
		dep_states_symb = sym2cellstr([obj.mbs.q;obj.mbs.dq].');
		acc_symb = sym2cellstr(obj.ddz.');
		name = obj.mbs.name;
		
		cxx = Coder_cxx(output_file);
		cxx.define_function_from_matrix(obj.M,[name '_mass'],...
			'argin_symb',{states_symb,motors_symb,dep_states_symb},...
			'argin_name',{'states'   ,'motors'   ,'dep_states'},...
			'argin_type',{'const T*' ,'const T*' ,'const T*'});
		
		cxx.define_function_from_matrix(obj.Q,[name '_rhs'],...
			'argin_symb',{states_symb,motors_symb,dep_states_symb},...
			'argin_name',{'states'   ,'motors'   ,'dep_states'},...
			'argin_type',{'const T*' ,'const T*' ,'const T*'});
		
		cxx.define_function_from_matrix(obj.q_z,[name '_dep_pos'],...
			'argin_symb',{states_symb},...
			'argin_name',{'states'},...
			'argin_type',{'const T*'});
		
		cxx.define_function_from_matrix(obj.dq_z,[name '_dep_vel'],...
			'argin_symb',{states_symb},...
			'argin_name',{'states'},...
			'argin_type',{'const T*'});
		
		cxx.define_function_from_matrix(obj.ddq_z,[name '_dep_acc'],...
			'argin_symb',{states_symb,acc_symb},...
			'argin_name',{'states','gen_acc'},...
			'argin_type',{'const T*','const T*'});
	end

	function set_multibody(obj, mbs, z_q)
		obj.mbs = mbs;
		obj.z_q = z_q;
		dof = length(z_q);
		obj.z = sym('z',[dof,1]);
		obj.dz = sym('dz',[dof,1]);
		obj.ddz = sym('ddz',[dof,1]);
		
		Z = z_q -obj.z;
		obj.q_z = solve([Z;mbs.Phi]==0,mbs.q);
		obj.q_z = orderfields(obj.q_z,sym2cellstr(mbs.q));
		obj.q_z = struct2cell(obj.q_z);
		obj.q_z = cellsym2sym(obj.q_z);
		
		obj.R = jacobian(obj.q_z,obj.z);
		obj.dq_z = obj.R*obj.dz;
		
		obj.dR = obj.R;
		for i=1:length(obj.z)
			obj.dR(:,i) = jacobian(obj.R(:,i),obj.z)*obj.dz;
		end
		obj.ddq_z = obj.R*obj.ddz + obj.dR*obj.dz;
		
		Rt = obj.R.';
		obj.M = Rt*mbs.M*obj.R;
		obj.Q = Rt*mbs.Qex - Rt*mbs.M*obj.dR*obj.dz;
	end
	
	function q = generalized_to_cartesian_position(obj,gen)
		ncart = length(obj.q_z);
		ngen = size(gen,2);
		q = zeros(ncart,ngen);
		for i=1:ngen
			q(:,i) = eval(subs(obj.q_z,obj.z,gen(:,i)));
		end
	end
	
	function dq = generalized_to_cartesian(obj,gen)
		ncart = length([obj.q_z;obj.dq_z]);
		ngen = size(gen,2);
		dq = zeros(ncart,ngen);
		for i=1:ngen
			dq(:,i) = eval(subs([obj.q_z;obj.dq_z],[obj.z;obj.dz],gen(:,i)));
		end
	end
end

end
