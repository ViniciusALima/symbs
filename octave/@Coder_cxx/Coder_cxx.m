% Use to translate Octave`s objects into C++ code.
%
% @author: Vinicius de A. Lima
% @date: 2018-11-29

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

classdef Coder_cxx < handle
% Coder_cxx implements methods to write Octave`s objects into C++ code.

properties
	file_path
	code % handle to an output file
end

methods
	function obj = Coder_cxx(file_path)
		obj.file_path = file_path;
		obj.code = fopen(file_path,'wt');
		obj.add_banner;
		obj.add_include('<cmath>');
	end
	
	function delete(obj)
		fclose(obj.code);
	end
	
	function append_code(obj, str)
		fprintf(obj.code,'%s',str);
	end
	
	function add_banner(obj)
	% add_banner adds a banner indicating that the file was created
	%	automatically at the current time and date.
		obj.append_code('/*----------------------------------------------------------------------------');
		obj.add_newline;
		obj.add_newline;
		obj.append_code('               This file was automatically created by Symbs');
		obj.add_newline;
		obj.append_code(sprintf('                             %i-%i-%i %i:%i:%i',round(clock)));
		obj.add_newline;
		obj.add_newline;
		obj.append_code('----------------------------------------------------------------------------*/');
		obj.add_newline;
	end

	function add_function_signature(obj, ret, name, ctypes, args)
	% add_function_signature adds a generic function signature.
	%	function_signature(ret,name,args,types) adds a signature where ret is
	%	the return ctype, name is the name for calling the function, types a cell
	%	array of strings with the types of the arguments, args a cell array of
	%	strings with the names of the arguments.
		obj.append_code(sprintf('%s %s(%s %s', ret, name, ctypes{1}, args{1}));
		if length(args) > 1
			for i = 2:length(args)
				obj.append_code(sprintf(', %s %s', ctypes{i}, args{i}));
			end
		end
		obj.append_code(sprintf(')'));
	end

	function add_include(obj, include_file)
	% add_include adds a include to the c file.
	%	include_file may be a string which must contain the apropriate enclosing
	%	characters '" "' or '< >' according to the desired behavior.
	%
	%	include file may be a cell array of strings, which will create a include
	%	line for each string.
		if iscellstr(include_file)
			obj.append_code(sprintf('#include %s\n',include_file{:}));
		else
			obj.append_code(sprintf('#include %s\n',include_file));
		end
	end

	function add_newline(obj)
	% add_newline adds a newline character to the c file.
		obj.append_code(sprintf('\n'));
	end

	function add_semicolon(obj)
	% add_semicolon adds a semicolon to the c file.
		obj.append_code(';');
	end
	
	function add_template(obj, typename)
	% add_template adds template types definitions to the cxx file.
		if iscellstr(typename)
			obj.append_code('template<');
			obj.append_code(sprintf('typename %s,', typename{:}));
			fseek(obj.code,-1,'cof');
			obj.append_code('> ');
		else
			obj.append_code(sprintf('template<typename %s> ', typename));
		end
	end

	function ccode(obj, varargin)
	% ccode adds the c-code that evaluate all elements of a symbolic matrix.
	%
	%	ccode(M) M is a matlab symbolic matrix, it will be stored in a c-array
	%	in column major order.
	%
	%	ccode(M,PARAM) The parameter 'identifier' gives a name for the c-array
	%	that will store M. Default is A0.
	%
	%	The logical parameter 'optimize' flags if optimization must be done
	%	to the code, default is false. As for Octave 4.2.2 optimization is
	%	not available so setting the flag to true will take no effect.
	%
	%	The parameter 'ctype' can be used to define the type of the variables
	%	used in code otimization. Only available when 'optimize' is set true.
	%
		ip = inputParser;
		issym = @(x) isa(x,'sym');
		ip.addRequired('M', issym);
		ip.addParamValue('identifier', 'A0', @ischar);
		ip.addParamValue('optimize', false, @islogical);
		ip.addParamValue('ctype', 'T', @ischar);
		ip.addParamValue('indentation', 0, @isnumeric);
		ip.parse(varargin{:});
		M = ip.Results.M;
		identifier = ip.Results.identifier;
		optimize = ip.Results.optimize;
		ctype = ip.Results.ctype;
		inden = ip.Results.indentation;
		% Create non optimized C-code
		if is_octave || ~optimize
			M = reshape(M,numel(M),1);
			for i = 1:length(M)
				% C-code must be generated elementwise as for Octave 4.2.2.
				cc = ccode(M(i));
				% Erase matlab t0 and ; to be compatible with Octave 4.2.2 ccode.
				cc = strrep(cc, '  t0 = ', '');
				cc = strrep(cc, ';', '');
				% Erase Octave verbose
				cc_lines = textscan(cc,'%s','delimiter','\n');
				cc = cc_lines{end}{end};
				% Substitute cxx placeholders
				cc = obj.subs_cxx_placeholders(cc);
				obj.indent(inden);
				obj.append_code(sprintf('%s[%i] = %s;\n',identifier,i-1,cc));
			end
			% Create optimized C-code
		else
			obj.ccode_optimized(ctype, M, identifier);
		end
	end

	function ccode_optimized(obj, ctype, M, mname)
	% add_optimized_ccode_matrix add c code that evaluates a matrix A0.
	%   Only compatible with MATLAB. For Octave see add_ccode_matrix.
		M = reshape(M,numel(M),1);
		% Create a temporary file with the optimized code.
		ccode(M,'file','temp_ccode');
		temp_ccode = fopen('temp_ccode');
		% Parse the file linewize
		while (not(feof(temp_ccode)))
			code_line = fgets(temp_ccode);
			% 2D array to 1D array
			if contains(code_line,'[0][0]')
				code_line = strrep(code_line,'[0][0]','[0]');
			else
				code_line = erase(code_line,'[0]');
			end
			% Add ctype to tx scalars
			if strcmp(code_line(3),'t')
				code_line = ['  ' ctype ' ' code_line(3:end)];
			end
			% Substitute cxx placeholders
			code_line = obj.subs_cxx_placeholders(code_line);
			% Substitute default matrix M name
			if nargin == 4
				code_line = strrep(code_line,'A0',mname);
			end
			% Write code to file
			obj.append_code(code_line);
		end
		fclose(temp_ccode);
		delete temp_ccode;
	end

	function close_curly(obj)
	% close_curly add a close curly bracket to the cxx file and a newline.
		obj.append_code(sprintf('}\n'));
	end
	
	% TODO: create function declare_function
	% TODO: create function declare_variable
	
	function define_function_from_matrix(obj, varargin)
		ip = inputParser;
		issym = @(x) isa(x,'sym');
		ip.addRequired('M',issym);
		ip.addRequired('func_name',@ischar);
		ip.addParamValue('argin_type',{},@iscellstr);
		ip.addParamValue('argin_name',{},@iscellstr);
		ip.addParamValue('argin_symb',{}, @iscell);
		ip.addParamValue('argout_type','T*',@ischar);
		ip.addParamValue('argout_name','out',@ischar);
		ip.addParamValue('template',{'T'},@iscellstr);
		ip.parse(varargin{:});
		ir = ip.Results;
		
		obj.add_template(ir.template);
		arg_type = [ir.argin_type {ir.argout_type}];
		arg_name = [ir.argin_name {ir.argout_name}];
		obj.add_function_signature('void',ir.func_name,arg_type,arg_name);
		obj.open_curly;
		for i=1:length(ir.argin_name)
			argin_type = strrep(ir.argin_type{i},'const ','');
			argin_type = strrep(argin_type,'&','');
			argin_type = strrep(argin_type,'*','');
			obj.define_variables_from_array(argin_type,ir.argin_symb{i},...
				ir.argin_name{i},1);
		end
		obj.ccode(ir.M,'identifier',ir.argout_name,'indentation',1);
		obj.close_curly;
		obj.add_newline;
	end

	function define_variable(obj, ctype, identifier, value, inden)
	% define_variable add a c variable definition to the c file.
		if nargin < 5
			inden = 0;
		end
		obj.indent(inden);
		obj.append_code(sprintf('%s %s = %s;\n',ctype,identifier,value));
	end
	
	function define_variables_from_array(obj,ctype,identifiers,array_name,inden)
	% define_variables_from_array add a c variable definition for each array
	%	element of array named array_name.
	%
		if nargin < 5
			inden = 0;
		end
		for i=1:length(identifiers)
			array_idx = ['[' num2str(i-1) ']'];
			array_elem = [array_name array_idx];
			obj.define_variable(ctype,identifiers{i},array_elem,inden);
		end
	end
	
	function indent(obj, n)
	% indent adds n indentations to the file
		if nargin < 2
			n = 1;
		end
		for i=1:n
			obj.append_code(sprintf('\t'));
		end
	end
	
	function open_curly(obj)
	% open_curly add a open curly bracket to the cxx file and a newline.
		obj.append_code(sprintf('{\n'));
	end

	function code = subs_cxx_placeholders(~, code)
	% Substitue namespace __ and template _T_ placeholders.
	%	Use the these placeholders in the symbols to represent cxx special
	%	tokens:
	%
	%	MATLAB	|	CXX
	%	-----------------
	%	__		|	::
	%	_T_		|	<T>
	%
		code = strrep(code,'__','::');
		code = strrep(code,'_T_','<T>');
	end
end % end of methods

end % end of classdef
