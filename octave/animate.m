% Animate`s a multibody result
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

function h = animate(varargin)
	ip = inputParser;
	ip.addRequired('multibody',@(x)isa(x,'Symbs'));
	ip.addRequired('states',@isnumeric);
	ip.addRequired('range',@(x)(numel(x)==4)&(isvector(x)));
	ip.addParamValue('fps',5,@isscalar);
	ip.addParamValue('keep_frames',false,@islogical);
	ip.addParamValue('repeat',1,@isscalar);
	ip.addParamValue('skip_frames',1,@isscalar);
	ip.addParamValue('figure',[]);
	ip.parse(varargin{:});
	ir = ip.Results;
	ir.states = ir.states(:,1:ir.skip_frames:end);
	if isempty(ir.figure)
		h = figure;
	else
		h = ir.figure;
	end
	range = ir.range;
	for j=1:ir.repeat
		for i=1:size(ir.states,2)
			if not(ir.keep_frames)
				clf(h);
			end
			ir.multibody.draw(h,ir.states(:,i));
			plot([-3 3],[0 0],'k');
			range(1:2) = ir.range(1:2)+ir.states(1,i);
			axis(range);
			%axis('equal');
			%axis('square');
			drawnow;
			pause(1/ir.fps);
		end
	end
end
