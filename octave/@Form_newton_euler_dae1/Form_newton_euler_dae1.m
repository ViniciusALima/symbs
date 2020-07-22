% Implements Newton Euler equations in DAE-1 index form
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

classdef Form_newton_euler_dae1 < Formulation
% TODO doc

% This file is part of symbs.
%
% @author Vinicius de A. Lima
% @date 2019-10-10
%
properties
	mbs % Multibody system
	Maug % Augmented mass matrix [M Phiq'; Phiq 0]
	Qaug % Augmented force vector [Q; dPhiq*dq-dPhit]
	ne % Newton-Euler DAE-3
end

methods
	function obj = Form_newton_euler_dae1(mbs)
		obj.set_multibody(mbs);
	end

	function ccode_formulation(obj,output_file)
		states_symb = sym2cellstr([obj.mbs.q;obj.mbs.dq].');
		motors_symb = cellsym2cellstr(obj.mbs.motors);
		argin_symb = {states_symb motors_symb};
		argin_name = {'states','motors'};
		argin_type = {'const T*','const T*'};
		name = obj.mbs.name;
		
		cxx = Coder_cxx(output_file);
		cxx.define_function_from_matrix(obj.Maug,[name '_mass'],...
			'argin_symb',argin_symb,...
			'argin_name',argin_name,...
			'argin_type',argin_type);
		
		cxx.define_function_from_matrix(obj.Qaug,[name '_rhs'],...
			'argin_symb',argin_symb,...
			'argin_name',argin_name,...
			'argin_type',argin_type);
	end

	function set_multibody(obj,mbs)
		obj.mbs = mbs;
		obj.ne = Form_newton_euler_dae3(mbs);
		obj.Maug = [obj.mbs.M    obj.ne.Phiq.'
		            obj.ne.Phiq zeros(size(obj.ne.Phiq,1))];
		obj.Qaug = [obj.ne.Q;-obj.dPhiq*obj.mbs.dq]; % TODO: introduce dPhit
	end

	function out = dPhiq(obj)
		out = obj.ne.Phiq;
		for i=1:length(obj.mbs.q)
			out(:,i) = jacobian(obj.ne.Phiq(:,i),obj.mbs.q)*obj.mbs.dq;
		end
	end
end

end % end of class
